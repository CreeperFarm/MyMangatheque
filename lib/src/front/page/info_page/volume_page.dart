import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs_lite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mymangatheque/l10n/app_localizations.dart';
import 'package:mymangatheque/src/back/provider/manga_owned_provider.dart';
import 'package:mymangatheque/src/back/services/appwrite.dart';
import 'package:mymangatheque/src/const/assets.dart';
import 'package:mymangatheque/src/const/own_icon.dart';
import 'package:mymangatheque/src/const/routes.dart';
import 'package:mymangatheque/src/front/components/my_author_tile.dart';
import 'package:mymangatheque/src/front/components/my_editor_show.dart';
import 'package:mymangatheque/src/front/components/my_icon_text_label.dart';
import 'package:mymangatheque/src/front/components/my_line.dart';
import 'package:mymangatheque/src/front/components/my_picture_display.dart';
import 'package:mymangatheque/src/front/components/my_scroll_column.dart';
import 'package:mymangatheque/src/front/components/my_series_tile.dart';
import 'package:mymangatheque/src/front/components/my_volume_tile.dart';
import 'package:mymangatheque/src/function/auto_push_or_go.dart';
import 'package:mymangatheque/src/models/local_storage/local_storage.dart';

class VolumePage extends ConsumerStatefulWidget {
  final String volumeId;
  final String initRoute;

  const VolumePage({required this.volumeId, required this.initRoute, super.key});

  @override
  ConsumerState<VolumePage> createState() => _VolumePageState();
}

class _VolumePageState extends ConsumerState<VolumePage> {
  static const String signInRoute = '/profile/signin';
  static const String _volumeExpandFields = 'subSeries.authors,subSeries.editors';

  // TODO: If contains is not empty then get the info via requests for those ids

  bool isVolumeOwned = false;
  bool isSubSeriesFollowed = false;
  bool isVolumeReaded = false;
  bool showMore = false;
  int _reviewsReloadNonce = 0;
  bool _adultContentEnabled = false;
  bool _isUpdatingOwned = false;
  bool _isUpdatingFollowed = false;

  final AppwriteConnector connector = AppwriteConnector();
  late Future<List<RecordModel>> _volumeFuture;

  String? _connectedUserId() => connector.getConnectedUser()?.id;

  Future<List<RecordModel>> _fetchVolumeData() {
    return connector.getOneExpand('volumes', widget.volumeId, _volumeExpandFields);
  }

  void switchShowMoreState() {
    setState(() {
      showMore = !showMore;
    });
  }

  void _checkVolumeOwnership() async {
    final userId = _connectedUserId();
    if (userId != null) {
      bool owned = false;
      try {
        owned = await connector.isVolumeOwned(userId, widget.volumeId);
      } catch (e) {
        debugPrint('Unable to resolve owned state for volume: $e');
      }
      if (!mounted) return;
      setState(() {
        isVolumeOwned = owned;
      });
      if (owned) {
        bool readed = false;
        try {
          readed = await connector.isVolumeReaded(userId, widget.volumeId);
        } catch (e) {
          debugPrint('Unable to resolve read state for volume: $e');
        }
        if (!mounted) return;
        setState(() {
          isVolumeReaded = readed;
        });
      }
    } else {
      if (!mounted) return;
      setState(() {
        isVolumeOwned = false;
      });
    }
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  List<Map<String, dynamic>> _asMapList(dynamic value) {
    if (value is List) {
      return value.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
    }
    if (value is Map) {
      return <Map<String, dynamic>>[Map<String, dynamic>.from(value)];
    }
    return const <Map<String, dynamic>>[];
  }

  Map<String, dynamic> _pickFirstMap(dynamic primary, [dynamic secondary]) {
    final primaryMap = _asMap(primary);
    if (primaryMap.isNotEmpty) return primaryMap;

    final primaryList = _asMapList(primary);
    if (primaryList.isNotEmpty) return primaryList.first;

    final secondaryMap = _asMap(secondary);
    if (secondaryMap.isNotEmpty) return secondaryMap;

    final secondaryList = _asMapList(secondary);
    if (secondaryList.isNotEmpty) return secondaryList.first;

    return <String, dynamic>{};
  }

  void _checkSubSeriesFollowing() async {
    final userId = _connectedUserId();
    if (userId != null) {
      try {
        final result = await _volumeFuture;
        final data = result.isNotEmpty ? Map<String, dynamic>.from(result.first.data) : <String, dynamic>{};
        final expand = _asMap(data['expand']);
        final subSeries = _pickFirstMap(expand['sub_series'], expand['subseries']);
        final subSeriesId = subSeries['id']?.toString() ?? '';
        if (subSeriesId.isEmpty) {
          if (!mounted) return;
          setState(() {
            isSubSeriesFollowed = false;
          });
          return;
        }
        final owned = await connector.isSubSeriesFollowed(userId, subSeriesId);
        if (!mounted) return;
        setState(() {
          isSubSeriesFollowed = owned;
        });
      } catch (e) {
        debugPrint('Unable to resolve sub-series follow state: $e');
        if (!mounted) return;
        setState(() {
          isSubSeriesFollowed = false;
        });
      }
    } else {
      if (!mounted) return;
      setState(() {
        isSubSeriesFollowed = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _volumeFuture = _fetchVolumeData();
    _loadAdultContentPreference();
    _checkVolumeOwnership();
    _checkSubSeriesFollowing();
  }

  @override
  void didUpdateWidget(covariant VolumePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.volumeId != widget.volumeId) {
      _volumeFuture = _fetchVolumeData();
      _checkVolumeOwnership();
      _checkSubSeriesFollowing();
    }
  }

  Future<void> _loadAdultContentPreference() async {
    final enabled = await LocalStorage().getAdultContentEnabled();
    if (!mounted) return;
    setState(() {
      _adultContentEnabled = enabled;
    });
  }

  Future<void> _handleOwnedPressed(String volumeId, String subSeriesId) async {
    if (_isUpdatingOwned) return;
    final userId = _connectedUserId();
    if (userId == null) {
      pushOrGo(context, signInRoute);
      return;
    }

    setState(() {
      _isUpdatingOwned = true;
    });

    try {
      if (!isVolumeOwned) {
        final result = await connector.addVolumeToOwned(
          userId,
          volumeId,
          false,
          subSeriesId: subSeriesId,
        );
        await _refreshOwnedLibrary();
        if (!mounted) return;
        setState(() {
          isVolumeOwned = true;
          if (result.subSeriesFollowed) isSubSeriesFollowed = true;
        });
        if (result.followError != null) {
          _showMutationError(result.followError!);
        }
        return;
      }

      await connector.removeVolumeFromOwned(userId, volumeId);
      await _refreshOwnedLibrary();
      if (!mounted) return;
      setState(() {
        isVolumeOwned = false;
      });
    } catch (error) {
      if (!mounted) return;
      _showMutationError(error);
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingOwned = false;
        });
      }
    }
  }

  Future<void> _handleFollowPressed(String subSeriesId) async {
    if (_isUpdatingFollowed) return;
    final userId = _connectedUserId();
    if (userId == null) {
      pushOrGo(context, signInRoute);
      return;
    }
    if (subSeriesId.isEmpty) return;

    setState(() {
      _isUpdatingFollowed = true;
    });
    try {
      if (!isSubSeriesFollowed) {
        await connector.addSubSeriesToFollowed(userId, subSeriesId);
        if (!mounted) return;
        setState(() {
          isSubSeriesFollowed = true;
        });
        return;
      }

      await connector.removeSubSeriesToFollowed(userId, subSeriesId);
      if (!mounted) return;
      setState(() {
        isSubSeriesFollowed = false;
      });
    } catch (error) {
      if (!mounted) return;
      _showMutationError(error);
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingFollowed = false;
        });
      }
    }
  }

  Future<void> _refreshOwnedLibrary() async {
    final user = connector.getConnectedUser();
    if (user == null) return;
    await ref
        .read(mangaOwnedProvider.notifier)
        .initData(user, forceRefresh: true);
  }

  void _showMutationError(Object error) {
    if (!mounted) return;
    final localizations = AppLocalizations.of(context);
    final message = localizations?.errorOccurredMessage(error.toString()) ??
        error.toString();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _handleReadPressed(String volumeId) async {
    final userId = _connectedUserId();
    if (userId == null) {
      pushOrGo(context, signInRoute);
      return;
    }

    connector.changeReadState(userId, volumeId, !isVolumeReaded);
    setState(() {
      isVolumeReaded = !isVolumeReaded;
    });
  }

  Future<void> _openReviewQuestionnaire(String volumeId) async {
    final userId = _connectedUserId();
    if (userId == null) {
      pushOrGo(context, signInRoute);
      return;
    }

    final localizations = AppLocalizations.of(context);
    if (localizations == null) return;

    final existing = await connector.getMyVolumeReview(volumeId);
    var stars = (existing?['stars'] as int?) ?? 0;
    if (stars < 1 || stars > 5) stars = 3;
    final commentController = TextEditingController(text: existing?['comment']?.toString() ?? '');
    final favCharactersController = TextEditingController(
      text: ((existing?['favCharacters'] as List<dynamic>?) ?? const <dynamic>[])
          .map((item) => item.toString())
          .where((item) => item.isNotEmpty)
          .join(', '),
    );

    var saving = false;
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: Text(localizations.reviewQuestionnaireTitle),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(localizations.reviewStars(stars)),
                    Slider(
                      value: stars.toDouble(),
                      min: 1,
                      max: 5,
                      divisions: 4,
                      label: '$stars',
                      onChanged: saving
                          ? null
                          : (value) {
                              setDialogState(() {
                                stars = value.round().clamp(1, 5);
                              });
                            },
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: favCharactersController,
                      enabled: !saving,
                      decoration: InputDecoration(labelText: localizations.favoriteCharacters, hintText: localizations.favoriteCharactersHint),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: commentController,
                      enabled: !saving,
                      maxLines: 4,
                      decoration: InputDecoration(labelText: localizations.comment, hintText: localizations.reviewCommentHint),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: saving
                      ? null
                      : () {
                          Navigator.of(dialogContext).pop();
                        },
                  child: Text(localizations.cancel),
                ),
                ElevatedButton(
                  onPressed: saving
                      ? null
                      : () async {
                          setDialogState(() {
                            saving = true;
                          });
                          try {
                            await connector.upsertVolumeReview(
                              volumeId: volumeId,
                              stars: stars,
                              comment: commentController.text,
                              favCharacters: favCharactersController.text
                                  .split(',')
                                  .map((item) => item.trim())
                                  .where((item) => item.isNotEmpty)
                                  .toList(),
                            );
                            if (dialogContext.mounted) {
                              Navigator.of(dialogContext).pop();
                            }
                            if (!mounted) return;
                            setState(() {
                              _reviewsReloadNonce += 1;
                            });
                            ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(localizations.reviewSubmittedSuccess)));
                          } catch (e) {
                            if (!mounted) return;
                            setDialogState(() {
                              saving = false;
                            });
                            ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(localizations.reviewSubmitFailed('$e'))));
                          }
                        },
                  child: saving
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(localizations.confirm),
                ),
              ],
            );
          },
        );
      },
    );

    commentController.dispose();
    favCharactersController.dispose();
  }

  String _formatSellerName(String seller) {
    switch (seller.toLowerCase()) {
      case 'amazon':
        return 'Amazon';
      case 'bdfugue':
        return 'BDFugue';
      case 'fnac':
        return 'Fnac';
      default:
        return seller;
    }
  }

  Map<String, String> _normalizeBookLink(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return <String, String>{
        'url': raw['url']?.toString() ?? '',
        'seller': raw['seller']?.toString() ?? '',
        'available': raw['available']?.toString() ?? '',
      };
    }

    final url = raw?.toString() ?? '';
    final host = Uri.tryParse(url)?.host ?? '';
    return <String, String>{'url': url, 'seller': host.isEmpty ? '' : host.replaceFirst('www.', ''), 'available': ''};
  }

  bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final normalized = value?.toString().trim().toLowerCase() ?? '';
    return normalized == 'true' || normalized == '1' || normalized == 'yes';
  }

  void _debugPrintFullData(Map<String, dynamic> data) {
    assert(() {
      final fullJson = const JsonEncoder.withIndent('  ').convert(data);
      const chunkSize = 800;
      for (var i = 0; i < fullJson.length; i += chunkSize) {
        final end = (i + chunkSize < fullJson.length) ? i + chunkSize : fullJson.length;
        debugPrint(fullJson.substring(i, end));
      }
      return true;
    }());
  }

  @override
  Widget build(BuildContext context) {
    // Get localization - return early if not available
    var localizations = AppLocalizations.of(context);
    if (localizations == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return FutureBuilder<List<RecordModel>>(
      future: _volumeFuture,
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: Text(localizations.loading)),
            body: const Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.connectionState == ConnectionState.none) {
          return Scaffold(
            appBar: AppBar(title: Text(localizations.noConnection)),
            body: Center(child: Text(localizations.noConnection)),
          );
        } else if (snapshot.hasError) {
          debugPrint(snapshot.error.toString());
          return Scaffold(
            appBar: AppBar(title: Text(localizations.errorOccurred)),
            body: Center(child: Text(localizations.errorOccurred)),
          );
        } else if (snapshot.hasData && snapshot.data != null) {
          // ? Declaring variables
          final data = snapshot.data!.isNotEmpty ? Map<String, dynamic>.from(snapshot.data!.first.data) : <String, dynamic>{};
          final expand = _asMap(data['expand']);
          _debugPrintFullData(data);
          final contain = (data['contain'] as List<dynamic>?) ?? const <dynamic>[];
          final containsExpanded = _asMapList(expand['contains']);
          final authors = expand['authors'] is List ? expand['authors'] as List<dynamic> : _asMapList(expand['authors']);
          final subSeries = _pickFirstMap(expand['sub_series'], expand['subseries']);
          final subSeriesExpand = _asMap(subSeries['expand']);
          final expandedEditor = _pickFirstMap(expand['editor'], expand['editors']);
          final nestedEditor = _pickFirstMap(subSeriesExpand['editor'], subSeriesExpand['editors']);
          final editor = expandedEditor.isNotEmpty ? expandedEditor : nestedEditor;
          final series =
              _pickFirstMap(
                expand['series'],
                expand['serie'],
              ).isNotEmpty
              ? _pickFirstMap(expand['series'], expand['serie'])
              : _pickFirstMap(
                  _pickFirstMap(subSeriesExpand['series'], subSeriesExpand['serie']),
                );
          final releaseRaw = data['release']?.toString() ?? data['publicationDate']?.toString();
          final release = releaseRaw == null ? null : DateTime.tryParse(releaseRaw);
          final volumeId = data['id']?.toString() ?? widget.volumeId;
          final subSeriesId = subSeries['id']?.toString() ?? data['sub_series']?.toString() ?? '';
          final title = data['title']?.toString() ?? data['titleFr']?.toString() ?? '';
          final image = data['image']?.toString() ?? data['coverUrl']?.toString();
          final resume = data['resume']?.toString() ?? '';
          final bookLinksRaw = (data['book_link'] as List<dynamic>?) ?? const <dynamic>[];
          final bookLinks = bookLinksRaw.map(_normalizeBookLink).where((entry) => entry['url']?.isNotEmpty == true).toList();
          final isAdultVolume = _toBool(data['over18']);
          final shouldBlurAdultCover = isAdultVolume && !_adultContentEnabled;
          final priceValue = num.tryParse(data['price']?.toString() ?? '') ?? -1;
          final eanValue = data['ean']?.toString().trim() ?? '';
          final pageNumber = data['info'] is Map<String, dynamic> ? (data['info'] as Map<String, dynamic>)['pageNumber'] : null;
          double widthAddAndFollowButton = MediaQuery.of(context).size.width * 0.5 - 15;

          // ? Return Scaffold
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              title: Text(
                title,
                textAlign: TextAlign.left,
                style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w300),
              ),
            ),
            body: MyScrollColumn(
              columnMainAxisAlignment: MainAxisAlignment.start,
              children: [
                MyPictureDisplay(
                  pictureUrl: image ?? '',
                  blurMainPicture: shouldBlurAdultCover,
                  blurOverlay: shouldBlurAdultCover
                      ? Container(
                          color: Colors.black.withValues(alpha: 0.25),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Center(
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.78,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(12)),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    localizations.adultContentWarning,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(localizations.adultContentBlockedDescription, textAlign: TextAlign.center),
                                  const SizedBox(height: 12),
                                  ElevatedButton(
                                    onPressed: () => pushOrGo(context, Routes.profile.base),
                                    child: Text(localizations.openContentSettings),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : null,
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        textAlign: TextAlign.left,
                        style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w300),
                      ),
                      (data['support'] == null || data['support'] == "manga")
                          ? const SizedBox()
                          : Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Text(
                                localizations.supportIs(data['support'].toString()),
                                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w200),
                              ),
                            ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: widthAddAndFollowButton,
                            height: 32 * 5 / 6 + 10,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: Container(
                                decoration: BoxDecoration(color: const Color(0xFF1780A3)),
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor: (!isVolumeOwned)
                                          ? WidgetStateProperty.all<Color>(Theme.of(context).colorScheme.surface)
                                          : WidgetStateProperty.all<Color>(const Color(0xFF1780A3)),
                                      iconColor: (!isVolumeOwned)
                                          ? WidgetStateProperty.all<Color>(Theme.of(context).colorScheme.primary)
                                          : WidgetStateProperty.all<Color>(Theme.of(context).colorScheme.onPrimary),
                                      elevation: WidgetStateProperty.all<double>(0),
                                    ),
                                    onPressed: _isUpdatingOwned
                                        ? null
                                        : () => _handleOwnedPressed(volumeId, subSeriesId),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        (!isVolumeOwned) ? const Icon(Icons.add) : const Icon(Icons.check),
                                        Text(
                                          (!isVolumeOwned) ? localizations.add : localizations.remove,
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: (!isVolumeOwned) ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: widthAddAndFollowButton,
                            height: 32 * 5 / 6 + 10,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: Container(
                                decoration: BoxDecoration(color: Colors.green),
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor: (!isSubSeriesFollowed)
                                          ? WidgetStateProperty.all<Color>(Theme.of(context).colorScheme.surface)
                                          : WidgetStateProperty.all<Color>(Colors.green),
                                      iconColor: (!isSubSeriesFollowed)
                                          ? WidgetStateProperty.all<Color>(Theme.of(context).colorScheme.primary)
                                          : WidgetStateProperty.all<Color>(Theme.of(context).colorScheme.onPrimary),
                                      elevation: WidgetStateProperty.all<double>(0),
                                    ),
                                    onPressed: _isUpdatingFollowed
                                        ? null
                                        : () => _handleFollowPressed(subSeriesId),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        (!isSubSeriesFollowed) ? const Icon(Icons.bookmark_border) : const Icon(Icons.bookmark),
                                        Text(
                                          (!isSubSeriesFollowed) ? localizations.follow : localizations.followed,
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: (!isSubSeriesFollowed)
                                                ? Theme.of(context).colorScheme.primary
                                                : Theme.of(context).colorScheme.onPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      (isVolumeOwned)
                          ? Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: 32 * 5 / 6 + 10,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: Container(
                                    decoration: BoxDecoration(color: Colors.red),
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: ElevatedButton.icon(
                                        style: ButtonStyle(
                                          backgroundColor: (!isVolumeReaded)
                                              ? WidgetStateProperty.all<Color>(Theme.of(context).colorScheme.surface)
                                              : WidgetStateProperty.all<Color>(Colors.red),
                                          iconColor: (!isVolumeReaded)
                                              ? WidgetStateProperty.all<Color>(Theme.of(context).colorScheme.primary)
                                              : WidgetStateProperty.all<Color>(Theme.of(context).colorScheme.onPrimary),
                                          elevation: WidgetStateProperty.all<double>(0),
                                        ),
                                        onPressed: () => _handleReadPressed(volumeId),
                                        label: Text(
                                          (!isVolumeReaded) ? localizations.read : localizations.readed,
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: (!isVolumeReaded)
                                                ? Theme.of(context).colorScheme.primary
                                                : Theme.of(context).colorScheme.onPrimary,
                                          ),
                                        ),
                                        icon: (!isVolumeReaded) ? const Icon(Icons.bookmark_add_rounded) : const Icon(Icons.bookmark_remove_rounded),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox(),
                      (isVolumeOwned && isVolumeReaded)
                          ? Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(localizations.reviewQuestionnaireTitle, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 6),
                                    Text(localizations.reviewQuestionnaireDescription),
                                    const SizedBox(height: 10),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: ElevatedButton.icon(
                                        onPressed: () => _openReviewQuestionnaire(volumeId),
                                        icon: const Icon(Icons.rate_review),
                                        label: Text(localizations.openQuestionnaire),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : const SizedBox(),
                      MyLine(width: MediaQuery.of(context).size.width, vertical: 10, horizontal: 0),
                      (authors.isEmpty)
                          ? const SizedBox()
                          : (authors.length == 1)
                          ? Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Text('${localizations.author} :', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            )
                          : Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Text('${localizations.authors} :', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            ),
                      for (var i = 0; i < authors.length; i += 1)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyAuthorTile(authorData: authors[i], initRoute: widget.initRoute),
                            (i != authors.length - 1 && authors.length > 1)
                                ? MyLine(width: MediaQuery.of(context).size.width, vertical: 5, horizontal: 0)
                                : const SizedBox(),
                          ],
                        ),
                      (resume.isEmpty)
                          ? const SizedBox()
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyLine(width: MediaQuery.of(context).size.width, vertical: 10, horizontal: 0),
                                Text('${localizations.summary} :', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 5),
                                  child: Text(
                                    resume,
                                    style: const TextStyle(fontSize: 15),
                                    textAlign: TextAlign.justify,
                                    maxLines: (showMore) ? null : 3,
                                    softWrap: true,
                                    overflow: (showMore) ? TextOverflow.visible : TextOverflow.ellipsis,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                  child: GestureDetector(
                                    onTap: () => setState(() {
                                      showMore = !showMore;
                                    }),
                                    child: Text(
                                      (showMore) ? localizations.seeLess : localizations.seeMore,
                                      style: const TextStyle(color: Colors.blue, fontSize: 15),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                      MyLine(width: MediaQuery.of(context).size.width, vertical: 10, horizontal: 0),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${localizations.editor} :', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            (editor['id']?.toString().isNotEmpty == true)
                                ? MyEditorShow(editor: editor, initRoute: widget.initRoute)
                                : Text(localizations.notAvailable),
                          ],
                        ),
                      ),
                      MyLine(width: MediaQuery.of(context).size.width, vertical: 10, horizontal: 0),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${localizations.series} :', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            (series['id']?.toString().isNotEmpty == true)
                                ? MySeriesTile(seriesData: series, initRoute: widget.initRoute)
                                : Text(localizations.notAvailable),
                          ],
                        ),
                      ),
                      MyLine(width: MediaQuery.of(context).size.width, vertical: 10, horizontal: 0),
                      (priceValue <= 0 && bookLinks.isEmpty)
                          ? Text(localizations.volumeNotAvailableAnymore, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                (priceValue > 0)
                                    ? Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${localizations.price} : ${NumberFormat.currency(locale: localizations.localeName, symbol: "€", decimalDigits: 2).format(priceValue)}',
                                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      )
                                    : Text(
                                        localizations.volumeNotAvailableForSale,
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                      ),
                                (bookLinks.isEmpty)
                                    ? const SizedBox()
                                    : Column(
                                        children: [
                                          const SizedBox(height: 10),
                                          for (var i = 0; i < bookLinks.length; i += 1)
                                            Builder(
                                              builder: (context) {
                                                final available = bookLinks[i]["available"]?.toString() ?? '';
                                                final sellerRaw = bookLinks[i]["seller"]?.toString() ?? '';
                                                final seller = _formatSellerName(sellerRaw);
                                                final linkUrl = bookLinks[i]["url"]?.toString() ?? '';
                                                final normalizedAvailable = available.trim();
                                                final hasShippingUnder = normalizedAvailable.toLowerCase().contains("shippingunder");
                                                final availabilityText = normalizedAvailable.isEmpty
                                                    ? localizations.availabilityUnknown
                                                    : (!hasShippingUnder)
                                                    ? localizations.availability(normalizedAvailable)
                                                    : (normalizedAvailable.toLowerCase().contains("days"))
                                                    ? localizations.shippingUnderDays(
                                                        num.tryParse(
                                                              normalizedAvailable
                                                                  .toLowerCase()
                                                                  .replaceAll("shippingunder", "")
                                                                  .replaceAll("days", "")
                                                                  .replaceAll(" ", ""),
                                                            ) ??
                                                            0,
                                                      )
                                                    : localizations.shippingUnderWeeks(
                                                        normalizedAvailable
                                                            .toLowerCase()
                                                            .replaceAll("shippingunder", "")
                                                            .replaceAll("week", "")
                                                            .replaceAll("s", "")
                                                            .replaceAll(" ", ""),
                                                      );
                                                final availabilityColor = normalizedAvailable.isEmpty
                                                    ? Theme.of(context).colorScheme.primary
                                                    : (normalizedAvailable == "inStock" || normalizedAvailable == "availanle")
                                                    ? Colors.green
                                                    : (normalizedAvailable == "onPreorder" || normalizedAvailable == "preorder")
                                                    ? Colors.blue
                                                    : (hasShippingUnder)
                                                    ? Colors.orange
                                                    : Colors.red;
                                                return Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Text(availabilityText, style: TextStyle(fontSize: 15, color: availabilityColor)),
                                                        Text(localizations.soldAndShippedBy(seller.isEmpty ? localizations.notAvailable : seller)),
                                                      ],
                                                    ),
                                                    ElevatedButton(
                                                      style: ButtonStyle(backgroundColor: WidgetStateProperty.all<Color>(Colors.red)),
                                                      onPressed: linkUrl.isEmpty
                                                          ? null
                                                          : () {
                                                              launchUrl(Uri.parse(linkUrl));
                                                            },
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Transform.translate(
                                                            offset: const Offset(0, 3.5),
                                                            child: OwnIcon(
                                                              iconColor: Theme.of(context).colorScheme.primary,
                                                              iconSrc: Assets.icons.shoppingCart,
                                                            ),
                                                          ),
                                                          const SizedBox(width: 10),
                                                          Text(
                                                            localizations.buyOn(seller.isEmpty ? localizations.notAvailable : seller),
                                                            style: TextStyle(
                                                              color: Theme.of(context).colorScheme.primary,
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    if (i != bookLinks.length - 1) const SizedBox(height: 12),
                                                  ],
                                                );
                                              },
                                            ),
                                        ],
                                      ),
                              ],
                            ),
                      MyLine(width: MediaQuery.of(context).size.width, vertical: 10, horizontal: 0),
                      Text('${localizations.informations} :', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            (release == null)
                                ? const SizedBox()
                                : Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 5),
                                    child: MyIconTextLabel(
                                      iconSrc: Assets.icons.calendar,
                                      text: '${localizations.publicationDate} : ${DateFormat.yMMMMd(localizations.localeName).format(release)}',
                                      heightIcon: 30,
                                    ),
                                  ),
                            (eanValue.isEmpty || eanValue == '0')
                                ? const SizedBox()
                                : Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 5),
                                    child: MyIconTextLabel(iconSrc: Assets.icons.barcode, text: '${localizations.ean} : $eanValue', heightIcon: 30),
                                  ),
                            (pageNumber == null)
                                ? const SizedBox()
                                : Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 5),
                                    child: MyIconTextLabel(
                                      iconSrc: Assets.icons.bookOpen,
                                      text: "${localizations.numberOfPages} : ${pageNumber.toString()}",
                                      heightIcon: 30,
                                    ),
                                  ),
                            (contain.isEmpty && containsExpanded.isEmpty)
                                ? const SizedBox()
                                : Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      MyLine(width: MediaQuery.of(context).size.width, vertical: 10, horizontal: 0),
                                      Text('${localizations.contentOfBoxSet} :', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 5),
                                      (containsExpanded.isEmpty)
                                          ? Text(contain.map((item) => item.toString()).join(', '))
                                          : Column(
                                              children: [
                                                for (var i = 0; i < containsExpanded.length; i += 1)
                                                  Column(
                                                    children: [
                                                      MyVolumeTile(
                                                        volumeData: containsExpanded[i],
                                                        subSerieData: subSeries,
                                                        isVolumeOwned: null,
                                                        initRoute: widget.initRoute,
                                                      ),
                                                      if (i != containsExpanded.length - 1)
                                                        MyLine(width: MediaQuery.of(context).size.width, vertical: 4, horizontal: 0),
                                                    ],
                                                  ),
                                              ],
                                            ),
                                    ],
                                  ),
                          ],
                        ),
                      ),
                      MyLine(width: MediaQuery.of(context).size.width, vertical: 10, horizontal: 0),
                      Text('${localizations.reviews} :', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      FutureBuilder<List<Map<String, dynamic>>>(
                        key: ValueKey('$volumeId-$_reviewsReloadNonce'),
                        future: connector.getVolumeReviews(volumeId, includePendingForUserId: _connectedUserId()),
                        builder: (context, reviewsSnapshot) {
                          if (reviewsSnapshot.connectionState == ConnectionState.waiting) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          final reviews = reviewsSnapshot.data ?? const [];
                          if (reviews.isEmpty) {
                            return Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text(localizations.noReviewsForThisVolumeYet));
                          }

                          final connectedUserId = _connectedUserId();
                          return Column(
                            children: [
                              for (var i = 0; i < reviews.length; i += 1)
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  margin: const EdgeInsets.symmetric(vertical: 6),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          for (var starIndex = 0; starIndex < 5; starIndex += 1)
                                            Icon(
                                              starIndex < ((reviews[i]['stars'] as int?) ?? 0) ? Icons.star : Icons.star_border,
                                              size: 18,
                                              color: Colors.amber,
                                            ),
                                          const SizedBox(width: 8),
                                          ((reviews[i]['commentChecked'] != true) && (reviews[i]['userId']?.toString() == connectedUserId))
                                              ? Text(
                                                  localizations.pendingModeration,
                                                  style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
                                                )
                                              : const SizedBox(),
                                        ],
                                      ),
                                      ((reviews[i]['comment']?.toString() ?? '').trim().isEmpty)
                                          ? const SizedBox()
                                          : Padding(padding: const EdgeInsets.only(top: 8), child: Text(reviews[i]['comment'].toString())),
                                      ((reviews[i]['favCharacters'] as List<dynamic>?) ?? const <dynamic>[]).isEmpty
                                          ? const SizedBox()
                                          : Padding(
                                              padding: const EdgeInsets.only(top: 8),
                                              child: Text(
                                                localizations.favoriteCharactersLabel(
                                                  ((reviews[i]['favCharacters'] as List<dynamic>?) ?? const <dynamic>[]).join(', '),
                                                ),
                                                style: const TextStyle(fontSize: 13),
                                              ),
                                            ),
                                    ],
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(title: Text(localizations.volumeDoesNotExist)),
            body: Center(child: Text(localizations.volumeDoesNotExist)),
          );
        }
      },
    );
  }
}
