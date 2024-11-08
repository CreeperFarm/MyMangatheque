import 'package:flutter/material.dart';

class VolumePage extends StatefulWidget {
  final String volumeId;

  const VolumePage({required this.volumeId, super.key});

  @override
  State<VolumePage> createState() => _VolumePageState();
}

class _VolumePageState extends State<VolumePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tomes"),
      ),
      body: const SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Tomes",
              style: TextStyle(
                fontSize: 25,
              ),
            ),
            Image(
              image: AssetImage("assets/images/splash_bg.png"),
            ),
          ],
        ),
      ),
    );
  }
}
