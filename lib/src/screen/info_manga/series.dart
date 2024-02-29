import 'package:flutter/material.dart';

class SeriesPages extends StatefulWidget {
  final String seriesName;
  const SeriesPages({required this.seriesName, super.key});

  @override
  State<SeriesPages> createState() => _SeriesPagesState();
}

class _SeriesPagesState extends State<SeriesPages> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Series"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Series",
              ),
              Text(
                widget.seriesName,
                style: const TextStyle(
                  fontSize: 25,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
