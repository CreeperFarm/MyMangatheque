import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:mobile_scanner/mobile_scanner.dart';

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
    /*
      MobileScannerController cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      formats: [BarcodeFormat.ean13],
    );*/

    dynamic ean;

    return Scaffold(
        appBar: AppBar(
          title: const Text("Scan EAN"),
          backgroundColor: Colors.transparent,
        ),
        body: Text('data'));
  }
}
