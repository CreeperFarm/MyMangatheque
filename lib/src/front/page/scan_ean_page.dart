import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymangatheque/l10n/app_localizations.dart';
import 'package:mymangatheque/src/back/provider/last_ean.dart';
import 'package:mymangatheque/src/back/services/appwrite.dart';
import 'package:mymangatheque/src/function/auto_push_or_go.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class ScanEanPage extends ConsumerStatefulWidget {
  const ScanEanPage({super.key});

  @override
  ConsumerState<ScanEanPage> createState() => _ScanEanPageState();
}

class _ScanEanPageState extends ConsumerState<ScanEanPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
    if (!AppwriteConnector().isLoggedIn()) {
      pushOrGo(context, '/profile/signin');
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    } else {
      if (Platform.isAndroid || Platform.isIOS) {
        return Scaffold(
          appBar: AppBar(
            title: Text(localizations.scanEAN),
            backgroundColor: Colors.transparent,
          ),
          body: Column(
            // TODO: Add the code to add the scanned EAN to the database
            children: [
              ElevatedButton(
                onPressed: () async {
                  var res = await SimpleBarcodeScanner.scanBarcode(
                    context,
                    barcodeAppBar: const BarcodeAppBar(
                      enableBackButton: true,
                      backButtonIcon: Icon(Icons.arrow_back_ios),
                    ),
                    isShowFlashIcon: true,
                    delayMillis: 2000,
                    cameraFace: CameraFace.front,
                  );
                  setState(() {
                    if (res is String) {
                      ref.read(lastEANProvider.notifier).setLastEAN(res);
                    }
                  });
                },
                child: Text(localizations.openScan),
              ),
              Text(ref.read(lastEANProvider) ?? "No data"),
            ],
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
