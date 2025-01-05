import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mymangatheque/src/back/services/pocketbase.dart';
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
    /*return Scaffold(
      appBar: AppBar(
        title: const Text('Scan EAN'),
      ),
      body: Center(
        child: Text("Malheureusement, le scan EAN n'est pas disponible pour le moment."),
      ),
    );*/
    if (!PocketBaseConnector().isLoggedIn()) {
      context.go('/profile/signin');
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      if (Platform.isAndroid || Platform.isIOS) {
        dynamic ean;

        return Scaffold(
          appBar: AppBar(
            title: const Text("Scan EAN"),
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
                      ean = res;
                    }
                  });
                },
                child: const Text('Open Scanner'),
              ),
              Text(ean ?? "No data"),
            ],
          ),
        );
      } else {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Scan EAN"),
            backgroundColor: Colors.transparent,
          ),
          body: Center(
            child: Text("Platform not supported"),
          ),
        );
      }
    }
  }
}
