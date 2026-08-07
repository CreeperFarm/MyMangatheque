import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mymangatheque/l10n/app_localizations.dart';
import 'package:mymangatheque/src/back/services/appwrite.dart';
import 'package:mymangatheque/src/const/assets.dart';
import 'package:mymangatheque/src/function/auto_push_or_go.dart';

class MyMangaShowTile extends StatefulWidget {
  final Map<String, dynamic> mangaData;
  final String initRoute;
  final double width;
  final double height;

  const MyMangaShowTile({required this.mangaData, required this.initRoute, required this.width, required this.height, super.key});

  @override
  State<MyMangaShowTile> createState() => _MyMangaShowTileState();
}

class _MyMangaShowTileState extends State<MyMangaShowTile> {
  bool isOwned = false;
  final AppwriteConnector _connector = AppwriteConnector();

  bool get _isLoggedIn => _connector.isLoggedIn();

  String get _coverUrl {
    return (widget.mangaData['coverUrl'] ?? '').toString().trim();
  }

  Widget _buildCoverImage({required double? height, BoxFit fit = BoxFit.fill}) {
    if (_coverUrl.isEmpty) {
      return Image.asset(Assets.images.unknown, height: height, fit: fit);
    }

    return Image.network(_coverUrl, height: height, fit: fit, errorBuilder: (context, error, stackTrace) => const SizedBox.shrink());
  }

  Future<void> _checkIfOwned() async {
    if (_isLoggedIn) {
      final connectedUser = _connector.getConnectedUser();
      if (connectedUser == null) {
        if (!mounted) return;
        setState(() {
          isOwned = false;
        });
        return;
      }

      bool isOwnedData = false;
      try {
        isOwnedData = await _connector.isVolumeOwned(connectedUser.id, widget.mangaData['id']);
      } catch (e) {
        debugPrint('Unable to resolve owned state: $e');
        isOwnedData = false;
      }
      if (!mounted) return;
      setState(() {
        isOwned = isOwnedData;
      });
    } else {
      if (!mounted) return;
      setState(() {
        isOwned = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _checkIfOwned();
  }

  @override
  Widget build(BuildContext context) {
    // Get localization - return early if not available
    var localizations = AppLocalizations.of(context);
    if (localizations == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Padding(
      padding: const EdgeInsets.only(right: 10.0, bottom: 10.0),
      child: GestureDetector(
        onTap: () {
          pushOrGo(context, '${(widget.initRoute == "/") ? "" : widget.initRoute}/volume/${widget.mangaData['id']}');
        },
        child: OverflowBox(
          maxWidth: widget.width,
          maxHeight: widget.height,
          minWidth: widget.width,
          minHeight: widget.height,
          child: Container(
            constraints: BoxConstraints(maxWidth: widget.width, maxHeight: widget.height, minWidth: widget.width, minHeight: widget.height),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.5),
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
                                padding: const EdgeInsets.only(top: 10.0, bottom: 10.0, right: 10.0, left: 20.0),
                                child: SizedBox(
                                  height: widget.height * 0.74 - 10,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: Wrap(
                                      children: [
                                        _buildCoverImage(height: widget.height * 0.74 - 10, fit: BoxFit.fill),
                                        BackdropFilter(
                                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                          child: Container(alignment: Alignment.center, color: Colors.grey.withValues(alpha: .4)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Display the image
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.5)), // Added border color
                                ),
                                height: widget.height * 0.74 - 10,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: _buildCoverImage(height: widget.height * 0.74 - 10, fit: BoxFit.fill),
                                ),
                              ),
                            ),

                            // Show a badge if the volume is owned
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
                                        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.0),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.check, color: Colors.white, size: 20),
                                            Text(localizations.owned, style: const TextStyle(color: Colors.white, fontSize: 15)),
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
                      child: Text(
                        widget.mangaData['title'].toString().replaceAll(' - Tome ${widget.mangaData['tome_number']}', ""),
                        style: const TextStyle(fontSize: 17),
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 10.0, left: 10.0, bottom: 10.0),
                      child: Text(
                        localizations.volumeNum(widget.mangaData['tome_number']),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
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
}
