import 'package:flutter/material.dart';

class EditorPage extends StatefulWidget {
  final String editorName;
  final String initRoute;

  const EditorPage({required this.editorName, required this.initRoute, super.key});

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editorName),
      ),
      body: const Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Editor",
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
      ),
    );
  }
}
