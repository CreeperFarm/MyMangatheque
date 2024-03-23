import 'package:flutter/material.dart';

class TomesPages extends StatefulWidget {
  final String tomesId;
  const TomesPages({required this.tomesId, super.key});

  @override
  State<TomesPages> createState() => _TomesPagesState();
}

class _TomesPagesState extends State<TomesPages> {
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
