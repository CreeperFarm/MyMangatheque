import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:mymangatheque/l10n/app_localizations.dart';
import 'package:mymangatheque/src/back/provider/last_ean.dart';
import 'package:mymangatheque/src/back/provider/manga_owned_provider.dart';
import 'package:mymangatheque/src/back/services/appwrite.dart';
import 'package:mymangatheque/src/const/layout.dart';
import 'package:mymangatheque/src/front/components/safe_network_image.dart';
import 'package:mymangatheque/src/function/auto_push_or_go.dart';
import 'package:mymangatheque/src/function/show_message_function.dart';
import 'package:mymangatheque/src/models/local_storage/local_storage.dart';

class ScanEanPage extends ConsumerStatefulWidget {
  const ScanEanPage({super.key});

  @override
  ConsumerState<ScanEanPage> createState() => _ScanEanPageState();
}

class _ScanEanPageState extends ConsumerState<ScanEanPage> {
  final AppwriteConnector _connector = AppwriteConnector();
  final List<RecordModel> _scannedVolumes = <RecordModel>[];
  final Set<String> _scannedVolumeIds = <String>{};
  final Set<String> _suggestedSubSeriesIds = <String>{};
  bool _isScanningSession = false;
  bool _isResolvingScan = false;
  bool _isPreparingSuggestions = false;
  bool _isAddingVolumes = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> _startScanSession(AppLocalizations localizations) async {
    if (_isScanningSession || _isAddingVolumes) return;

    setState(() {
      _isScanningSession = true;
    });

    try {
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (context) => _ContinuousEanScannerPage(
            localizations: localizations,
            onEanDetected: _resolveScannedEan,
          ),
        ),
      );
    } catch (error) {
      if (mounted) {
        showMessage(
          localizations.errorOccurredMessage(error.toString()),
          context,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isScanningSession = false;
          _isResolvingScan = false;
        });
      }
    }

    if (!mounted) return;
    if (_scannedVolumes.isNotEmpty) {
      await _offerPreviousVolumes(localizations);
      if (!mounted) return;
      await _confirmAddScannedVolumes(localizations);
    }
  }

  Future<RecordModel?> _resolveScannedEan(String ean) async {
    ref.read(lastEANProvider.notifier).setLastEAN(ean);
    setState(() {
      _isResolvingScan = true;
    });

    try {
      final foundVolume = await _connector.getVolumeByEan(
        ean,
        expand: '[subSeries.volumes]',
      );
      if (foundVolume == null) return null;

      var volume = foundVolume;
      if (_subSeriesIdForVolume(volume).isEmpty ||
          _volumeNumber(volume) == null) {
        final volumeId = volume.id;
        try {
          final hydratedVolumes = await _connector.getOneExpand(
            'volumes',
            volumeId,
            '[subSeries.volumes]',
          );
          if (hydratedVolumes.isNotEmpty) volume = hydratedVolumes.first;
        } catch (error) {
          debugPrint('Unable to hydrate scanned volume $volumeId: $error');
        }
      }
      if (!mounted) return null;

      if (_scannedVolumeIds.contains(volume.id)) {
        return volume;
      }

      setState(() {
        _scannedVolumes.add(volume);
        _scannedVolumeIds.add(volume.id);
      });
      return volume;
    } finally {
      if (mounted) {
        setState(() {
          _isResolvingScan = false;
        });
      }
    }
  }

  Future<void> _confirmAddScannedVolumes(
    AppLocalizations localizations,
  ) async {
    if (_scannedVolumes.isEmpty || _isAddingVolumes) return;

    final shouldAdd = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(localizations.addScannedVolumesTitle),
          content: Text(
            localizations.addScannedVolumesConfirmation(_scannedVolumes.length),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(localizations.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(localizations.add),
            ),
          ],
        );
      },
    );

    if (shouldAdd != true) return;

    final user = _connector.getConnectedUser();
    if (user == null) {
      if (!mounted) return;
      pushOrGo(context, '/profile/signin');
      return;
    }

    setState(() {
      _isAddingVolumes = true;
    });

    try {
      final ownedVolumeIds = await _connector.getOwnedVolumeIds(
        forceRefresh: true,
      );
      final volumesToAdd = _scannedVolumes
          .where((volume) => !ownedVolumeIds.contains(volume.id))
          .toList();
      final addedVolumeIds = <String>{};
      final addErrors = <Object>[];
      final followErrors = <Object>[];
      for (final volume in volumesToAdd) {
        try {
          final result = await _connector.addVolumeToOwned(
            user.id,
            volume.id,
            false,
            subSeriesId: _subSeriesIdForVolume(volume),
          );
          addedVolumeIds.add(volume.id);
          if (result.followError != null) {
            followErrors.add(result.followError!);
          }
        } catch (error) {
          addErrors.add(error);
          debugPrint('Unable to add scanned volume ${volume.id}: $error');
        }
      }

      if (addedVolumeIds.isNotEmpty) {
        try {
          await ref
              .read(mangaOwnedProvider.notifier)
              .initData(user, forceRefresh: true);
        } catch (error) {
          debugPrint('Unable to refresh the owned library after scan: $error');
        }
      }

      if (!mounted) return;
      setState(() {
        final completedIds = <String>{...ownedVolumeIds, ...addedVolumeIds};
        _scannedVolumes.removeWhere(
          (volume) => completedIds.contains(volume.id),
        );
        _scannedVolumeIds.removeAll(completedIds);
      });

      if (addedVolumeIds.isNotEmpty || volumesToAdd.isEmpty) {
        showMessage(localizations.scannedVolumesAdded, context);
      }
      if (addErrors.isNotEmpty) {
        showMessage(
          localizations.errorOccurredMessage(addErrors.first.toString()),
          context,
        );
      } else if (followErrors.isNotEmpty) {
        showMessage(
          localizations.errorOccurredMessage(followErrors.first.toString()),
          context,
        );
      }
    } catch (e) {
      if (!mounted) return;
      showMessage(localizations.errorOccurredMessage(e.toString()), context);
    } finally {
      if (mounted) {
        setState(() {
          _isAddingVolumes = false;
        });
      }
    }
  }

  Future<void> _offerPreviousVolumes(
    AppLocalizations localizations,
  ) async {
    final suggestionsEnabled = await LocalStorage()
        .getScanPreviousVolumesSuggestionEnabled();
    if (!suggestionsEnabled || !mounted) return;

    setState(() {
      _isPreparingSuggestions = true;
    });
    try {
      await _preparePreviousVolumeSuggestions(localizations);
    } finally {
      if (mounted) {
        setState(() {
          _isPreparingSuggestions = false;
        });
      }
    }
  }

  Future<void> _preparePreviousVolumeSuggestions(
    AppLocalizations localizations,
  ) async {
    final user = _connector.getConnectedUser();
    if (user == null) return;

    final ownedVolumeIds = await _connector.getOwnedVolumeIds(
      forceRefresh: true,
    );
    final triggersBySubSeries = <String, RecordModel>{};

    for (final volume in List<RecordModel>.from(_scannedVolumes)) {
      if (ownedVolumeIds.contains(volume.id)) continue;
      final subSeriesId = _subSeriesIdForVolume(volume);
      final number = _volumeNumber(volume);
      if (subSeriesId.isEmpty || number == null || number <= 1) continue;

      final current = triggersBySubSeries[subSeriesId];
      final currentNumber = current == null ? null : _volumeNumber(current);
      if (currentNumber == null || number > currentNumber) {
        triggersBySubSeries[subSeriesId] = volume;
      }
    }

    for (final entry in triggersBySubSeries.entries) {
      if (!mounted) return;
      final subSeriesId = entry.key;
      if (_suggestedSubSeriesIds.contains(subSeriesId)) continue;

      final triggerVolume = entry.value;
      final triggerNumber = _volumeNumber(triggerVolume);
      if (triggerNumber == null) continue;

      late final List<RecordModel> subSeriesVolumes;
      try {
        subSeriesVolumes = await _connector.getSubSeriesVolumes(
          subSeriesId,
          sourceVolume: triggerVolume,
        );
      } catch (error) {
        debugPrint(
          'Unable to load previous volumes for sub-series $subSeriesId: $error',
        );
        continue;
      }
      final candidatesById = <String, RecordModel>{
        for (final volume in subSeriesVolumes) volume.id: volume,
        triggerVolume.id: triggerVolume,
      };
      final candidates =
          candidatesById.values.where((volume) {
            final number = _volumeNumber(volume);
            return number != null &&
                number > 0 &&
                number <= triggerNumber &&
                !ownedVolumeIds.contains(volume.id);
          }).toList()..sort((a, b) {
            return _volumeNumber(a)!.compareTo(_volumeNumber(b)!);
          });

      if (candidates.length <= 1) continue;
      _suggestedSubSeriesIds.add(subSeriesId);

      final selection = await _showPreviousVolumesSheet(
        localizations,
        candidates,
        triggerNumber,
      );
      if (selection == null || !mounted) continue;

      if (selection.disableSuggestions) {
        await LocalStorage().setScanPreviousVolumesSuggestionEnabled(false);
        return;
      }

      setState(() {
        for (final volume in candidates) {
          if (!selection.selectedVolumeIds.contains(volume.id) ||
              !_scannedVolumeIds.add(volume.id)) {
            continue;
          }
          _scannedVolumes.add(volume);
        }
      });
    }
  }

  Future<_PreviousVolumesSelection?> _showPreviousVolumesSheet(
    AppLocalizations localizations,
    List<RecordModel> candidates,
    num triggerNumber,
  ) {
    final initiallySelectedIds = candidates.map((volume) => volume.id).toSet();
    final lockedIds = initiallySelectedIds.intersection(_scannedVolumeIds);

    return showModalBottomSheet<_PreviousVolumesSelection>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        final selectedIds = Set<String>.from(initiallySelectedIds);

        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              top: false,
              child: FractionallySizedBox(
                heightFactor: 0.82,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              localizations.completeScannedSubSeriesTitle,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(sheetContext).pop(),
                            tooltip: localizations.cancel,
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        localizations.completeScannedSubSeriesDescription(
                          triggerNumber,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              setSheetState(() {
                                selectedIds.addAll(
                                  candidates.map((volume) => volume.id),
                                );
                              });
                            },
                            icon: const Icon(Icons.select_all_rounded),
                            label: Text(localizations.selectAllVolumes),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              setSheetState(() {
                                selectedIds
                                  ..clear()
                                  ..addAll(lockedIds);
                              });
                            },
                            icon: const Icon(Icons.deselect_rounded),
                            label: Text(localizations.clearSelection),
                          ),
                        ],
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: ListView.builder(
                          itemCount: candidates.length,
                          itemBuilder: (context, index) {
                            final volume = candidates[index];
                            final isLocked = lockedIds.contains(volume.id);
                            final data = volume.data;
                            final number = _volumeNumber(volume);
                            final title =
                                data['title']?.toString().trim() ?? '';
                            final coverUrl =
                                data['coverUrl']?.toString() ??
                                data['image']?.toString() ??
                                '';

                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: SafeNetworkImage(
                                  imageUrl: coverUrl,
                                  width: 40,
                                  height: 58,
                                ),
                              ),
                              title: Text(
                                title.isEmpty
                                    ? '${localizations.volume} ${_formatVolumeNumber(number)}'
                                    : title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                '${localizations.volume} ${_formatVolumeNumber(number)}',
                              ),
                              trailing: Checkbox(
                                value: selectedIds.contains(volume.id),
                                onChanged: isLocked
                                    ? null
                                    : (selected) {
                                        setSheetState(() {
                                          if (selected == true) {
                                            selectedIds.add(volume.id);
                                          } else {
                                            selectedIds.remove(volume.id);
                                          }
                                        });
                                      },
                              ),
                              onTap: isLocked
                                  ? null
                                  : () {
                                      setSheetState(() {
                                        if (!selectedIds.remove(volume.id)) {
                                          selectedIds.add(volume.id);
                                        }
                                      });
                                    },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      FilledButton.icon(
                        onPressed: selectedIds.isEmpty
                            ? null
                            : () => Navigator.of(sheetContext).pop(
                                _PreviousVolumesSelection(
                                  selectedVolumeIds: Set<String>.from(
                                    selectedIds,
                                  ),
                                ),
                              ),
                        icon: const Icon(Icons.library_add_check_rounded),
                        label: Text(localizations.addSelectedVolumes),
                      ),
                      TextButton.icon(
                        onPressed: () => Navigator.of(sheetContext).pop(
                          const _PreviousVolumesSelection(
                            disableSuggestions: true,
                          ),
                        ),
                        icon: const Icon(Icons.notifications_off_outlined),
                        label: Text(localizations.neverShowAgain),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  num? _volumeNumber(RecordModel volume) {
    final value = volume.data['tome_number'] ?? volume.data['tomeNumber'];
    if (value is num) return value;
    return num.tryParse(value?.toString().replaceAll(',', '.') ?? '');
  }

  String _formatVolumeNumber(num? number) {
    if (number == null) return '-';
    return number == number.roundToDouble()
        ? number.toInt().toString()
        : number.toString();
  }

  String _subSeriesIdForVolume(RecordModel volume) {
    final data = volume.data;
    const keys = <String>[
      'subSeries',
      'subSeriesId',
      'subseries',
      'sub_series',
      'sub_serie',
      'sub_series_id',
    ];

    for (final key in keys) {
      final id = _relationId(data[key]);
      if (id.isNotEmpty) return id;
    }

    final expand = data['expand'];
    if (expand is Map) {
      for (final key in keys) {
        final id = _relationId(expand[key]);
        if (id.isNotEmpty) return id;
      }
    }
    return '';
  }

  String _relationId(dynamic value) {
    if (value is String) return value.trim();
    if (value is Map) {
      return (value['id'] ?? value[r'$id'])?.toString().trim() ?? '';
    }
    if (value is List && value.isNotEmpty) return _relationId(value.first);
    return '';
  }

  void _removeScannedVolume(RecordModel volume) {
    setState(() {
      _scannedVolumes.removeWhere((item) => item.id == volume.id);
      _scannedVolumeIds.remove(volume.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get localization - return early if not available
    var localizations = AppLocalizations.of(context);
    if (localizations == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    /*return Scaffold(
      appBar: AppBar(
        title: const Text('Scan EAN'),
      ),
      body: Center(
        child: Text("Malheureusement, le scan EAN n'est pas disponible pour le moment."),
      ),
    );*/
    if (!_connector.isLoggedIn()) {
      pushOrGo(context, '/profile/signin');
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    } else {
      if (Platform.isAndroid || Platform.isIOS) {
        return Scaffold(
          appBar: AppBar(
            title: Text(localizations.scanEAN),
            backgroundColor: Colors.transparent,
          ),
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed:
                              _isScanningSession ||
                                  _isResolvingScan ||
                                  _isPreparingSuggestions ||
                                  _isAddingVolumes
                              ? null
                              : () => _startScanSession(localizations),
                          icon:
                              _isScanningSession ||
                                  _isResolvingScan ||
                                  _isPreparingSuggestions
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.qr_code_scanner_rounded),
                          label: Text(localizations.openScan),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      localizations.lastScannedEan(
                        ref.watch(lastEANProvider).isEmpty
                            ? '-'
                            : ref.watch(lastEANProvider),
                      ),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          localizations.scannedVolumesPreview,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Text(
                        localizations.scannedVolumesCount(
                          _scannedVolumes.length,
                        ),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _scannedVolumes.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              localizations.noScannedVolumesYet,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _scannedVolumes.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final volume = _scannedVolumes[index];
                            return _ScannedVolumeTile(
                              volume: volume,
                              onRemove: () => _removeScannedVolume(volume),
                            );
                          },
                        ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    16,
                    16,
                    16 +
                        (MediaQuery.sizeOf(context).width <=
                                phoneNavigationMaxWidth
                            ? phoneBottomNavigationClearance
                            : 0),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isAddingVolumes || _scannedVolumes.isEmpty
                              ? null
                              : () {
                                  setState(() {
                                    _scannedVolumes.clear();
                                    _scannedVolumeIds.clear();
                                  });
                                },
                          child: Text(localizations.cancel),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: _isAddingVolumes || _scannedVolumes.isEmpty
                              ? null
                              : () => _confirmAddScannedVolumes(localizations),
                          child: _isAddingVolumes
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(localizations.add),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Scan EAN"),
            backgroundColor: Colors.transparent,
          ),
          body: const Center(child: Text("Platform not supported")),
        );
      }
    }
  }
}

class _PreviousVolumesSelection {
  const _PreviousVolumesSelection({
    this.selectedVolumeIds = const <String>{},
    this.disableSuggestions = false,
  });

  final Set<String> selectedVolumeIds;
  final bool disableSuggestions;
}

typedef _EanResolver = Future<RecordModel?> Function(String ean);

class _ContinuousEanScannerPage extends StatefulWidget {
  const _ContinuousEanScannerPage({
    required this.localizations,
    required this.onEanDetected,
  });

  final AppLocalizations localizations;
  final _EanResolver onEanDetected;

  @override
  State<_ContinuousEanScannerPage> createState() =>
      _ContinuousEanScannerPageState();
}

class _ContinuousEanScannerPageState extends State<_ContinuousEanScannerPage> {
  late final MobileScannerController _scannerController =
      MobileScannerController(
        detectionSpeed: DetectionSpeed.noDuplicates,
        facing: CameraFacing.back,
        formats: const <BarcodeFormat>[BarcodeFormat.ean13],
      );

  final Set<String> _seenEans = <String>{};
  final Set<String> _recognizedVolumeIds = <String>{};
  Future<void> _lookupQueue = Future<void>.value();
  RecordModel? _lastVolume;
  String? _lastEan;
  String? _lastError;
  bool _isResolving = false;
  bool _isFinishing = false;

  void _handleCapture(BarcodeCapture capture) {
    for (final barcode in capture.barcodes) {
      final rawValue = barcode.rawValue?.trim() ?? '';
      final ean = rawValue.replaceAll(RegExp(r'\D'), '');
      if (ean.length != 13 || !_seenEans.add(ean)) continue;

      unawaited(HapticFeedback.selectionClick());
      _lookupQueue = _lookupQueue.then((_) => _resolveEan(ean));
      break;
    }
  }

  Future<void> _resolveEan(String ean) async {
    if (!mounted) return;
    setState(() {
      _isResolving = true;
      _lastEan = ean;
      _lastError = null;
    });

    try {
      final volume = await widget.onEanDetected(ean);
      if (!mounted) return;

      if (volume == null) {
        setState(() {
          _lastError = widget.localizations.scannedVolumeNotFound(ean);
        });
        return;
      }

      setState(() {
        _lastVolume = volume;
        _recognizedVolumeIds.add(volume.id);
      });
      unawaited(HapticFeedback.mediumImpact());
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _lastError = widget.localizations.errorOccurredMessage(
          error.toString(),
        );
      });
    } finally {
      if (mounted) {
        setState(() {
          _isResolving = false;
        });
      }
    }
  }

  Future<void> _finishScanning() async {
    if (_isFinishing) return;
    setState(() {
      _isFinishing = true;
    });

    await _lookupQueue;
    try {
      await _scannerController.stop();
    } catch (_) {
      // The controller can already be stopped while the route is closing.
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    unawaited(_scannerController.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = widget.localizations;

    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final showsPhoneNavigation =
              constraints.maxWidth <= phoneNavigationMaxWidth;
          final scanWidth = (constraints.maxWidth - 48).clamp(240.0, 420.0);
          const scanHeight = 150.0;
          final scanWindow = Rect.fromCenter(
            center: Offset(
              constraints.maxWidth / 2,
              constraints.maxHeight * 0.42,
            ),
            width: scanWidth,
            height: scanHeight,
          );

          return Stack(
            fit: StackFit.expand,
            children: [
              MobileScanner(
                controller: _scannerController,
                scanWindow: scanWindow,
                scanWindowUpdateThreshold: 1,
                tapToFocus: true,
                onDetect: _handleCapture,
                placeholderBuilder: (context) => const ColoredBox(
                  color: Colors.black,
                  child: Center(child: CircularProgressIndicator()),
                ),
                errorBuilder: (context, error) => const ColoredBox(
                  color: Colors.black,
                  child: Center(
                    child: Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.white,
                      size: 42,
                    ),
                  ),
                ),
              ),
              Positioned.fromRect(
                rect: scanWindow,
                child: IgnorePointer(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _lastError != null
                            ? Theme.of(context).colorScheme.error
                            : _lastVolume != null
                            ? Colors.greenAccent
                            : Colors.white,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton.filled(
                          onPressed: _isFinishing ? null : _finishScanning,
                          tooltip: localizations.cancel,
                          icon: const Icon(Icons.close_rounded),
                        ),
                        ValueListenableBuilder<MobileScannerState>(
                          valueListenable: _scannerController,
                          builder: (context, scannerState, child) {
                            final torchIsOn =
                                scannerState.torchState == TorchState.on;
                            return IconButton.filled(
                              onPressed: scannerState.isInitialized
                                  ? _scannerController.toggleTorch
                                  : null,
                              tooltip: 'Flash',
                              icon: Icon(
                                torchIsOn
                                    ? Icons.flash_on_rounded
                                    : Icons.flash_off_rounded,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: showsPhoneNavigation
                        ? phoneBottomNavigationClearance
                        : 0,
                  ),
                  child: SafeArea(
                    top: false,
                    child: ColoredBox(
                      color: Colors.black.withValues(alpha: 0.86),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    localizations.scannedVolumesCount(
                                      _recognizedVolumeIds.length,
                                    ),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(color: Colors.white),
                                  ),
                                ),
                                if (_isResolving)
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            _buildLastScanPreview(context),
                            const SizedBox(height: 12),
                            FilledButton.icon(
                              onPressed: _isFinishing ? null : _finishScanning,
                              icon: _isFinishing
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.check_rounded),
                              label: Text(localizations.confirm),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLastScanPreview(BuildContext context) {
    final localizations = widget.localizations;
    final error = _lastError;
    if (error != null) {
      return Row(
        children: [
          Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      );
    }

    final volume = _lastVolume;
    if (volume == null) {
      return Text(
        _lastEan == null
            ? localizations.noScannedVolumesYet
            : localizations.lastScannedEan(_lastEan!),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Colors.white70),
      );
    }

    final data = volume.data;
    final title = data['title']?.toString().trim() ?? '';
    final tomeNumber = data['tome_number'] ?? data['tomeNumber'] ?? '-';
    final coverUrl =
        data['coverUrl']?.toString() ?? data['image']?.toString() ?? '';

    return SizedBox(
      height: 64,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SafeNetworkImage(
              imageUrl: coverUrl,
              width: 44,
              height: 64,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.isEmpty ? '${localizations.volume} $tomeNumber' : title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${localizations.ean} : ${_lastEan ?? ''}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle, color: Colors.greenAccent),
        ],
      ),
    );
  }
}

class _ScannedVolumeTile extends StatelessWidget {
  const _ScannedVolumeTile({
    required this.volume,
    required this.onRemove,
  });

  final RecordModel volume;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final data = volume.data;
    final expand = _asMap(data['expand']);
    final subSeries = _asMap(
      expand['subSeries'] ?? expand['sub_series'] ?? expand['sub_serie'],
    );
    final tomeNumber = data['tome_number'] ?? data['tomeNumber'] ?? '-';
    final title = data['title']?.toString().trim().isNotEmpty == true
        ? data['title'].toString()
        : subSeries['title']?.toString() ?? '';
    final coverUrl = data['coverUrl']?.toString().trim().isNotEmpty == true
        ? data['coverUrl'].toString()
        : data['image']?.toString().trim().isNotEmpty == true
        ? data['image'].toString()
        : subSeries['coverUrl']?.toString() ??
              subSeries['image']?.toString() ??
              '';
    final ean = data['ean']?.toString() ?? '';

    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SafeNetworkImage(
                imageUrl: coverUrl,
                width: 52,
                height: 76,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.isEmpty
                        ? '${localizations?.volume ?? 'Volume'} $tomeNumber'
                        : title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${localizations?.volume ?? 'Volume'} $tomeNumber',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (ean.isNotEmpty)
                    Text(
                      '${localizations?.ean ?? 'EAN'} : $ean',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
            IconButton(
              onPressed: onRemove,
              tooltip: localizations?.remove ?? 'Remove',
              icon: const Icon(Icons.close_rounded),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return const <String, dynamic>{};
  }
}
