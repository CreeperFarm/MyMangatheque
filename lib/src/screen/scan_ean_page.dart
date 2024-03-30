import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

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

    MobileScannerController cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      formats: [BarcodeFormat.ean13],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan EAN"),
        backgroundColor: Colors.transparent,
      ),
      body: MobileScanner(
        controller: cameraController,
        onDetect: (captureObject) {
          final List<Barcode> barcodes = captureObject.barcodes;
          if (barcodes.first.rawValue != null) {
            print(barcodes.first.rawValue);
          }
        },
        overlay: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [ // TODO: Replace this images by the tome that are scanned but not already in the user collection
                Image.network(
                  "https://upload.wikimedia.org/wikipedia/commons/thumb/1/13/Barcode-scanner.jpg/220px-Barcode-scanner.jpg",
                  width: 10,
                )
              ],
            ),
            const Padding(padding: EdgeInsets.only(bottom: 20)),
            ElevatedButton(
              onPressed: () {
                cameraController.toggleTorch();
              },
              child: ValueListenableBuilder(
                valueListenable: cameraController.torchState,
                builder: (context, isTorchOn, child) {
                  switch (isTorchOn) {
                    case TorchState.on:
                      return const Icon(Icons.flash_on);
                    case TorchState.off:
                      return const Icon(Icons.flash_off);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
