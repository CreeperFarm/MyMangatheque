import 'dart:convert';
import 'dart:math';

import 'package:mymangatheque/src/back/language/runtime_localization.dart';
import 'package:mymangatheque/src/back/services/api/mobile_api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PromotionSource { sponsored, editorial, organic }

class PromotionAttribution {
  const PromotionAttribution({
    required this.source,
    this.campaignId,
    this.placement,
  });

  final PromotionSource source;
  final String? campaignId;
  final String? placement;

  bool get isSponsored =>
      source == PromotionSource.sponsored && (campaignId ?? '').isNotEmpty;
  bool get isEditorial => source == PromotionSource.editorial;
}

PromotionAttribution promotionAttributionFromManga(
  Map<String, dynamic> manga,
) {
  final sponsorship = _asMap(
    manga['sponsorshipMeta'] ?? manga['sponsored'] ?? manga['sponsorship'],
  );
  final editorial = _asMap(
    manga['editorialMeta'] ?? manga['editorial'] ?? manga['editorialPlacement'],
  );
  final recommendation = _asMap(manga['recommendationMeta']);
  final source = _firstText(<dynamic>[
    manga['source'],
    sponsorship?['source'],
    editorial?['source'],
    recommendation?['source'],
  ]).toLowerCase();
  final campaignId = _firstText(<dynamic>[
    sponsorship?['campaignId'],
    sponsorship?['id'],
    manga['campaignId'],
    if (source == 'sponsored') recommendation?['campaignId'],
  ]);
  final placement = _firstText(<dynamic>[
    sponsorship?['placement'],
    editorial?['placement'],
    recommendation?['placement'],
  ]);

  if (campaignId.isNotEmpty || source == 'sponsored') {
    return PromotionAttribution(
      source: PromotionSource.sponsored,
      campaignId: campaignId.isEmpty ? null : campaignId,
      placement: placement.isEmpty ? null : placement,
    );
  }
  if (editorial != null || source == 'editorial') {
    return PromotionAttribution(
      source: PromotionSource.editorial,
      placement: placement.isEmpty ? null : placement,
    );
  }
  return const PromotionAttribution(source: PromotionSource.organic);
}

class PromotionTrackingService {
  PromotionTrackingService._internal();

  static final PromotionTrackingService _singleton =
      PromotionTrackingService._internal();

  factory PromotionTrackingService() => _singleton;

  static const String _anonymousIdKey = 'mmt_promotion_anonymous_id';
  static const String _attributionPrefix = 'mmt_sponsor_attribution:';
  static const Duration _attributionWindow = Duration(days: 7);

  final MobileApiClient _api = MobileApiClient();
  final Set<String> _sessionImpressions = <String>{};
  final Random _random = Random.secure();

  Future<void> trackImpression(Map<String, dynamic> manga) async {
    final attribution = promotionAttributionFromManga(manga);
    final campaignId = attribution.campaignId;
    if (!attribution.isSponsored || campaignId == null) return;
    final volumeId = _firstText(<dynamic>[manga['id'], manga[r'$id']]);
    final deduplicationKey = '$campaignId:$volumeId:${attribution.placement}';
    if (!_sessionImpressions.add(deduplicationKey)) return;
    await _send(campaignId, 'impression');
  }

  Future<void> trackClick(Map<String, dynamic> manga) async {
    final attribution = promotionAttributionFromManga(manga);
    final campaignId = attribution.campaignId;
    if (!attribution.isSponsored || campaignId == null) return;
    final volumeId = _firstText(<dynamic>[manga['id'], manga[r'$id']]);
    if (volumeId.isNotEmpty) {
      await _storeAttribution(volumeId, campaignId);
    }
    await _send(campaignId, 'click');
  }

  Future<void> trackConversionForVolume(String volumeId) async {
    final safeVolumeId = volumeId.trim();
    if (safeVolumeId.isEmpty) return;
    try {
      final preferences = await SharedPreferences.getInstance();
      final key = '$_attributionPrefix$safeVolumeId';
      final raw = preferences.getString(key);
      if (raw == null || raw.isEmpty) return;
      final decoded = jsonDecode(raw);
      final attribution = _asMap(decoded);
      final campaignId = attribution?['campaignId']?.toString() ?? '';
      final clickedAt = DateTime.tryParse(
        attribution?['clickedAt']?.toString() ?? '',
      );
      await preferences.remove(key);
      if (campaignId.isEmpty || clickedAt == null) return;
      if (DateTime.now().toUtc().difference(clickedAt.toUtc()) >
          _attributionWindow) {
        return;
      }
      await _send(campaignId, 'conversion');
    } catch (error) {
      RuntimeLocalization.debug(
        en: 'Sponsored conversion tracking failed: $error',
        fr: 'Le suivi de conversion sponsorisée a échoué : $error',
      );
    }
  }

  Future<void> _storeAttribution(String volumeId, String campaignId) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(
        '$_attributionPrefix$volumeId',
        jsonEncode(<String, dynamic>{
          'campaignId': campaignId,
          'clickedAt': DateTime.now().toUtc().toIso8601String(),
        }),
      );
    } catch (error) {
      RuntimeLocalization.debug(
        en: 'Sponsored click attribution storage failed: $error',
        fr: 'Le stockage de l’attribution du clic sponsorisé a échoué : $error',
      );
    }
  }

  Future<void> _send(String campaignId, String eventName) async {
    try {
      final response = await _api.post(
        '/api/admin/sponsorship/campaigns/$campaignId/events',
        body: <String, dynamic>{
          'eventId': _newIdentifier(),
          'eventName': eventName,
          'occurredAt': DateTime.now().toUtc().toIso8601String(),
          'anonymousUserId': await _anonymousId(),
        },
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        RuntimeLocalization.debug(
          en: 'Sponsored event rejected (${response.statusCode}).',
          fr: 'Événement sponsorisé refusé (${response.statusCode}).',
        );
      }
    } catch (error) {
      RuntimeLocalization.debug(
        en: 'Sponsored event tracking failed: $error',
        fr: 'Le suivi d’un événement sponsorisé a échoué : $error',
      );
    }
  }

  Future<String> _anonymousId() async {
    final preferences = await SharedPreferences.getInstance();
    final existing = preferences.getString(_anonymousIdKey);
    if (existing != null && existing.isNotEmpty) return existing;
    final generated = _newIdentifier();
    await preferences.setString(_anonymousIdKey, generated);
    return generated;
  }

  String _newIdentifier() {
    final bytes = List<int>.generate(24, (_) => _random.nextInt(256));
    return base64UrlEncode(bytes).replaceAll('=', '');
  }
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

String _firstText(Iterable<dynamic> values) {
  for (final value in values) {
    final text = value?.toString().trim() ?? '';
    if (text.isNotEmpty && text != 'null') return text;
  }
  return '';
}
