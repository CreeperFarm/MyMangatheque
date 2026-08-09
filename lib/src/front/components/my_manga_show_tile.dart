import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mymangatheque/l10n/app_localizations.dart';
import 'package:mymangatheque/src/back/language/runtime_localization.dart';
import 'package:mymangatheque/src/back/services/appwrite.dart';
import 'package:mymangatheque/src/back/services/analytics/promotion_tracking_service.dart';
import 'package:mymangatheque/src/back/services/recommendations/recommendation_preferences_service.dart';
import 'package:mymangatheque/src/const/assets.dart';
import 'package:mymangatheque/src/front/components/safe_network_image.dart';
import 'package:mymangatheque/src/function/auto_push_or_go.dart';

class MyMangaShowTile extends StatefulWidget {
  final Map<String, dynamic> mangaData;
  final String initRoute;
  final double width;
  final double height;
  final String recommendationReason;
  final ValueChanged<RecommendationFeedbackAction>? onRecommendationFeedback;

  const MyMangaShowTile({
    required this.mangaData,
    required this.initRoute,
    required this.width,
    required this.height,
    this.recommendationReason = '',
    this.onRecommendationFeedback,
    super.key,
  });

  @override
  State<MyMangaShowTile> createState() => _MyMangaShowTileState();
}

class _MyMangaShowTileState extends State<MyMangaShowTile> {
  bool isOwned = false;
  int _ownedCheckGeneration = 0;
  final AppwriteConnector _connector = AppwriteConnector();
  final PromotionTrackingService _promotionTracking =
      PromotionTrackingService();

  bool get _isLoggedIn => _connector.isLoggedIn();

  PromotionAttribution get _promotion =>
      promotionAttributionFromManga(widget.mangaData);

  String get _coverUrl {
    return (widget.mangaData['coverUrl'] ?? '').toString().trim();
  }

  String get _volumeId => (widget.mangaData['id'] ?? '').toString();

  Widget _buildCoverImage({required double? height, BoxFit fit = BoxFit.fill}) {
    if (_coverUrl.isEmpty) {
      return Image.asset(Assets.images.unknown, height: height, fit: fit);
    }

    return SafeNetworkImage(
      imageUrl: _coverUrl,
      height: height,
      fit: fit,
    );
  }

  Future<void> _checkIfOwned() async {
    final generation = ++_ownedCheckGeneration;
    if (_isLoggedIn) {
      final connectedUser = _connector.getConnectedUser();
      if (connectedUser == null) {
        if (!mounted || generation != _ownedCheckGeneration) return;
        setState(() {
          isOwned = false;
        });
        return;
      }

      bool isOwnedData = false;
      try {
        isOwnedData = await _connector.isVolumeOwned(
          connectedUser.id,
          widget.mangaData['id'],
        );
      } catch (e) {
        RuntimeLocalization.debug(
          en: 'Unable to resolve the owned state: $e',
          fr: 'Impossible de déterminer l’état de possession : $e',
        );
        isOwnedData = false;
      }
      if (!mounted || generation != _ownedCheckGeneration) return;
      setState(() {
        isOwned = isOwnedData;
      });
    } else {
      if (!mounted || generation != _ownedCheckGeneration) return;
      setState(() {
        isOwned = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _checkIfOwned();
    _trackImpressionAfterLayout();
  }

  void _trackImpressionAfterLayout() {
    final mangaData = widget.mangaData;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(_promotionTracking.trackImpression(mangaData));
      }
    });
  }

  @override
  void didUpdateWidget(covariant MyMangaShowTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldVolumeId = (oldWidget.mangaData['id'] ?? '').toString();
    if (oldVolumeId == _volumeId) return;
    isOwned = false;
    _checkIfOwned();
    _trackImpressionAfterLayout();
  }

  @override
  void dispose() {
    _ownedCheckGeneration += 1;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get localization - return early if not available
    var localizations = AppLocalizations.of(context);
    if (localizations == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final rawTomeNumber =
        widget.mangaData['tome_number'] ?? widget.mangaData['tomeNumber'];
    final tomeNumber = rawTomeNumber is num
        ? rawTomeNumber
        : num.tryParse(rawTomeNumber?.toString() ?? '');
    final coverHeight =
        widget.height * (widget.recommendationReason.isEmpty ? 0.74 : 0.69) -
        10;

    return Padding(
      padding: const EdgeInsets.only(right: 10.0, bottom: 10.0),
      child: GestureDetector(
        onTap: () {
          unawaited(_promotionTracking.trackClick(widget.mangaData));
          pushOrGo(
            context,
            '${(widget.initRoute == "/") ? "" : widget.initRoute}/volume/${widget.mangaData['id']}',
          );
        },
        child: OverflowBox(
          maxWidth: widget.width,
          maxHeight: widget.height,
          minWidth: widget.width,
          minHeight: widget.height,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: widget.width,
              maxHeight: widget.height,
              minWidth: widget.width,
              minHeight: widget.height,
            ),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.onPrimary.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: OverflowBox(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: SizedBox(
                        width: widget.width,
                        child: Stack(
                          alignment: AlignmentDirectional.center,
                          children: [
                            Positioned(
                              top: 5,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  top: 10.0,
                                  bottom: 10.0,
                                  right: 10.0,
                                  left: 20.0,
                                ),
                                child: SizedBox(
                                  height: coverHeight,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: Wrap(
                                      children: [
                                        _buildCoverImage(
                                          height: coverHeight,
                                          fit: BoxFit.fill,
                                        ),
                                        BackdropFilter(
                                          filter: ImageFilter.blur(
                                            sigmaX: 5,
                                            sigmaY: 5,
                                          ),
                                          child: Container(
                                            alignment: Alignment.center,
                                            color: Colors.grey.withValues(
                                              alpha: .4,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Display the image
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10.0,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.onPrimary
                                      .withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary
                                        .withValues(alpha: 0.5),
                                  ), // Added border color
                                ),
                                height: coverHeight,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: _buildCoverImage(
                                    height: coverHeight,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                            ),

                            // Show a badge if the volume is owned
                            if (_promotion.isSponsored ||
                                _promotion.isEditorial)
                              Positioned(
                                top: 10,
                                left: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _promotion.isSponsored
                                        ? const Color(0xFF7B4D00)
                                        : Theme.of(
                                            context,
                                          ).colorScheme.tertiary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _promotion.isSponsored
                                            ? Icons.campaign_outlined
                                            : Icons.auto_awesome_outlined,
                                        size: 15,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _promotionLabel(context),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            (_isLoggedIn && isOwned)
                                ? Positioned(
                                    top: 10,
                                    right: 10,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1780A3),
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(10.0),
                                          topLeft: Radius.circular(10.0),
                                          bottomRight: Radius.circular(10.0),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 5.0,
                                          vertical: 2.0,
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                            Text(
                                              localizations.owned,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.mangaData['title'].toString().replaceAll(
                                ' - Tome ${widget.mangaData['tome_number']}',
                                "",
                              ),
                              style: const TextStyle(fontSize: 17),
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.left,
                            ),
                          ),
                          if (widget.onRecommendationFeedback != null)
                            PopupMenuButton<RecommendationFeedbackAction>(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              tooltip: context.localized(
                                en: 'Recommendation options',
                                fr: 'Options de recommandation',
                              ),
                              onSelected: widget.onRecommendationFeedback,
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: RecommendationFeedbackAction.hidden,
                                  child: Text(
                                    context.localized(
                                      en: 'Hide this title',
                                      fr: 'Masquer ce titre',
                                    ),
                                  ),
                                ),
                                PopupMenuItem(
                                  value:
                                      RecommendationFeedbackAction.irrelevant,
                                  child: Text(
                                    context.localized(
                                      en: 'Not relevant to me',
                                      fr: 'Pas pertinent pour moi',
                                    ),
                                  ),
                                ),
                              ],
                              icon: const Icon(Icons.more_vert, size: 19),
                            ),
                        ],
                      ),
                    ),
                    if (widget.recommendationReason.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.auto_awesome_outlined,
                              size: 13,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                widget.recommendationReason,
                                style: Theme.of(context).textTheme.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (tomeNumber != null)
                      Padding(
                        padding: const EdgeInsets.only(
                          right: 10.0,
                          left: 10.0,
                          bottom: 10.0,
                        ),
                        child: Text(
                          localizations.volumeNum(tomeNumber),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                          ),
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _promotionLabel(BuildContext context) {
    final french = Localizations.localeOf(context).languageCode == 'fr';
    if (_promotion.isSponsored) return french ? 'Sponsorisé' : 'Sponsored';
    return french ? 'Sélection éditoriale' : 'Editorial pick';
  }
}
