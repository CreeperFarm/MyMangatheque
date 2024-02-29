import 'package:flutter/material.dart';

class AuthorPage extends StatefulWidget {
  final String authorName;
  const AuthorPage({required this.authorName, super.key});

  @override
  State<AuthorPage> createState() => _AuthorPageState();
}

class _AuthorPageState extends State<AuthorPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Author"),
      ),
      body: const Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Author",
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
