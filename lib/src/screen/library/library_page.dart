import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mymangatheque/src/provider/theme_color_provider.dart';

class LibraryPage extends ConsumerStatefulWidget {
  const LibraryPage({super.key});

  @override
  ConsumerState<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends ConsumerState<LibraryPage> {

  final controller = PageController(initialPage: 1);

  @override
  void initState() {
    super.initState();
    ref.read(themeBgColorProvider);
  }

  @override
  Widget build(BuildContext context) {

    final colorOut = Colors.deepPurpleAccent.shade100;
    final colorIn = ref.watch(themeBgColorProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        child: Expanded(
          child: PageView(
            physics: const NeverScrollableScrollPhysics(),
            controller: controller,
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            height: 30,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: colorOut,
                                  width: 3.0
                              ),
                              borderRadius: BorderRadius.circular(360),
                            ),
                            child: Material(
                              color: colorIn,
                              borderRadius: BorderRadius.circular(360),
                              child: InkWell(
                                onTap: (){},
                                borderRadius: BorderRadius.circular(360),
                                splashColor: Colors.grey,
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Transform.translate(
                                    offset: const Offset(0,-1.5),
                                    child: Text(
                                      "Pile à Lire",
                                      style: TextStyle(
                                        color: colorOut,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Padding(padding: EdgeInsets.only(left: 9.0)),
                        Expanded(
                          child: Container(
                            height: 30,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: colorOut,
                                  width: 3.0
                              ),
                              borderRadius: BorderRadius.circular(360),
                            ),
                            child: Material(
                              color: colorOut,
                              borderRadius: BorderRadius.circular(360),
                              child: InkWell(
                                onTap: () => controller.jumpToPage(1),
                                borderRadius: BorderRadius.circular(360),
                                splashColor: Colors.grey,
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Transform.translate(
                                    offset: const Offset(0,-1.5),
                                    child: Text(
                                      "Collection",
                                      style: TextStyle(
                                        color: colorIn,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Padding(padding: EdgeInsets.only(left: 9.0)),
                        Expanded(
                          child: Container(
                            height: 30,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: colorOut,
                                  width: 3.0
                              ),
                              borderRadius: BorderRadius.circular(360),
                            ),
                            child: Material(
                              color: colorOut,
                              borderRadius: BorderRadius.circular(360),
                              child: InkWell(
                                onTap: () => controller.jumpToPage(2),
                                borderRadius: BorderRadius.circular(360),
                                splashColor: Colors.grey,
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Transform.translate(
                                    offset: const Offset(0,-1.5),
                                    child: Text(
                                      "Envies",
                                      style: TextStyle(
                                        color: colorIn,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Padding(padding: EdgeInsets.only(left: 9.0)),
                        Expanded(
                          child: Container(
                            height: 30,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: colorOut,
                                  width: 3.0
                              ),
                              borderRadius: BorderRadius.circular(360),
                            ),
                            child: Material(
                              color: colorOut,
                              borderRadius: BorderRadius.circular(360),
                              child: InkWell(
                                onTap: () => controller.jumpToPage(3),
                                borderRadius: BorderRadius.circular(360),
                                splashColor: Colors.grey,
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Transform.translate(
                                    offset: const Offset(0,-1.5),
                                    child: Text(
                                      "Statistiques",
                                      style: TextStyle(
                                        color: colorIn,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                      child: Container(
                        height: 1.0,
                        width: MediaQuery.of(context).size.width,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      "Hey BG, cette page est en dev, elle arrivera plus tard.",
                      textAlign: TextAlign.start,
                      style: GoogleFonts.adventPro(
                        textStyle: const TextStyle(
                          fontSize: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            height: 30,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: colorOut,
                                  width: 3.0
                              ),
                              borderRadius: BorderRadius.circular(360),
                            ),
                            child: Material(
                              color: colorOut,
                              borderRadius: BorderRadius.circular(360),
                              child: InkWell(
                                onTap: () => controller.jumpToPage(0),
                                borderRadius: BorderRadius.circular(360),
                                splashColor: Colors.grey,
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Transform.translate(
                                    offset: const Offset(0,-1.5),
                                    child: Text(
                                      "Pile à Lire",
                                      style: TextStyle(
                                        color: colorIn,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Padding(padding: EdgeInsets.only(left: 9.0)),
                        Expanded(
                          child: Container(
                            height: 30,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: colorOut,
                                  width: 3.0
                              ),
                              borderRadius: BorderRadius.circular(360),
                            ),
                            child: Material(
                              color: colorIn,
                              borderRadius: BorderRadius.circular(360),
                              child: InkWell(
                                onTap: (){},
                                borderRadius: BorderRadius.circular(360),
                                splashColor: Colors.grey,
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Transform.translate(
                                    offset: const Offset(0,-1.5),
                                    child: Text(
                                      "Collection",
                                      style: TextStyle(
                                        color: colorOut,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Padding(padding: EdgeInsets.only(left: 9.0)),
                        Expanded(
                          child: Container(
                            height: 30,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: colorOut,
                                  width: 3.0
                              ),
                              borderRadius: BorderRadius.circular(360),
                            ),
                            child: Material(
                              color: colorOut,
                              borderRadius: BorderRadius.circular(360),
                              child: InkWell(
                                onTap: () => controller.jumpToPage(2),
                                borderRadius: BorderRadius.circular(360),
                                splashColor: Colors.grey,
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Transform.translate(
                                    offset: const Offset(0,-1.5),
                                    child: Text(
                                      "Envies",
                                      style: TextStyle(
                                        color: colorIn,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Padding(padding: EdgeInsets.only(left: 9.0)),
                        Expanded(
                          child: Container(
                            height: 30,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: colorOut,
                                  width: 3.0
                              ),
                              borderRadius: BorderRadius.circular(360),
                            ),
                            child: Material(
                              color: colorOut,
                              borderRadius: BorderRadius.circular(360),
                              child: InkWell(
                                onTap: () => controller.jumpToPage(3),
                                borderRadius: BorderRadius.circular(360),
                                splashColor: Colors.grey,
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Transform.translate(
                                    offset: const Offset(0,-1.5),
                                    child: Text(
                                      "Statistiques",
                                      style: TextStyle(
                                        color: colorIn,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            height: 30,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: colorOut,
                                  width: 3.0
                              ),
                              borderRadius: BorderRadius.circular(360),
                            ),
                            child: Material(
                              color: colorOut,
                              borderRadius: BorderRadius.circular(360),
                              child: InkWell(
                                onTap: () => controller.jumpToPage(0),
                                borderRadius: BorderRadius.circular(360),
                                splashColor: Colors.grey,
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Transform.translate(
                                    offset: const Offset(0,-1.5),
                                    child: Text(
                                      "Pile à Lire",
                                      style: TextStyle(
                                        color: colorIn,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Padding(padding: EdgeInsets.only(left: 9.0)),
                        Expanded(
                          child: Container(
                            height: 30,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: colorOut,
                                  width: 3.0
                              ),
                              borderRadius: BorderRadius.circular(360),
                            ),
                            child: Material(
                              color: colorOut,
                              borderRadius: BorderRadius.circular(360),
                              child: InkWell(
                                onTap: () => controller.jumpToPage(1),
                                borderRadius: BorderRadius.circular(360),
                                splashColor: Colors.grey,
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Transform.translate(
                                    offset: const Offset(0,-1.5),
                                    child: Text(
                                      "Collection",
                                      style: TextStyle(
                                        color: colorIn,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Padding(padding: EdgeInsets.only(left: 9.0)),
                        Expanded(
                          child: Container(
                            height: 30,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: colorOut,
                                  width: 3.0
                              ),
                              borderRadius: BorderRadius.circular(360),
                            ),
                            child: Material(
                              color: colorIn,
                              borderRadius: BorderRadius.circular(360),
                              child: InkWell(
                                onTap: (){},
                                borderRadius: BorderRadius.circular(360),
                                splashColor: Colors.grey,
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Transform.translate(
                                    offset: const Offset(0,-1.5),
                                    child: Text(
                                      "Envies",
                                      style: TextStyle(
                                        color: colorOut,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Padding(padding: EdgeInsets.only(left: 9.0)),
                        Expanded(
                          child: Container(
                            height: 30,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: colorOut,
                                  width: 3.0
                              ),
                              borderRadius: BorderRadius.circular(360),
                            ),
                            child: Material(
                              color: colorOut,
                              borderRadius: BorderRadius.circular(360),
                              child: InkWell(
                                onTap: () => controller.jumpToPage(3),
                                borderRadius: BorderRadius.circular(360),
                                splashColor: Colors.grey,
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Transform.translate(
                                    offset: const Offset(0,-1.5),
                                    child: Text(
                                      "Statistiques",
                                      style: TextStyle(
                                        color: colorIn,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                      child: Container(
                        height: 1.0,
                        width: MediaQuery.of(context).size.width,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      "Tomes • Édition",
                      textAlign: TextAlign.start,
                      style: GoogleFonts.adventPro(
                        textStyle: const TextStyle(
                          fontSize: 30,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                      child: Container(
                        height: 1.0,
                        width: MediaQuery.of(context).size.width,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      "Hey BG, cette page est en dev, elle arrivera plus tard.",
                      textAlign: TextAlign.start,
                      style: GoogleFonts.adventPro(
                        textStyle: const TextStyle(
                          fontSize: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Stat Page
              SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            height: 30,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: colorOut,
                                  width: 3.0
                              ),
                              borderRadius: BorderRadius.circular(360),
                            ),
                            child: Material(
                              color: colorOut,
                              borderRadius: BorderRadius.circular(360),
                              child: InkWell(
                                onTap: () => controller.jumpToPage(0),
                                borderRadius: BorderRadius.circular(360),
                                splashColor: Colors.grey,
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Transform.translate(
                                    offset: const Offset(0,-1.5),
                                    child: Text(
                                      "Pile à Lire",
                                      style: TextStyle(
                                        color: colorIn,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Padding(padding: EdgeInsets.only(left: 9.0)),
                        Expanded(
                          child: Container(
                            height: 30,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: colorOut,
                                  width: 3.0
                              ),
                              borderRadius: BorderRadius.circular(360),
                            ),
                            child: Material(
                              color: colorOut,
                              borderRadius: BorderRadius.circular(360),
                              child: InkWell(
                                onTap: () => controller.jumpToPage(1),
                                borderRadius: BorderRadius.circular(360),
                                splashColor: Colors.grey,
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Transform.translate(
                                    offset: const Offset(0,-1.5),
                                    child: Text(
                                      "Collection",
                                      style: TextStyle(
                                        color: colorIn,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Padding(padding: EdgeInsets.only(left: 9.0)),
                        Expanded(
                          child: Container(
                            height: 30,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: colorOut,
                                  width: 3.0
                              ),
                              borderRadius: BorderRadius.circular(360),
                            ),
                            child: Material(
                              color: colorOut,
                              borderRadius: BorderRadius.circular(360),
                              child: InkWell(
                                onTap: () => controller.jumpToPage(2),
                                borderRadius: BorderRadius.circular(360),
                                splashColor: Colors.grey,
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Transform.translate(
                                    offset: const Offset(0,-1.5),
                                    child: Text(
                                      "Envies",
                                      style: TextStyle(
                                        color: colorIn,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Padding(padding: EdgeInsets.only(left: 9.0)),
                        Expanded(
                          child: Container(
                            height: 30,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: colorOut,
                                  width: 3.0
                              ),
                              borderRadius: BorderRadius.circular(360),
                            ),
                            child: Material(
                              color: colorIn,
                              borderRadius: BorderRadius.circular(360),
                              child: InkWell(
                                onTap: (){},
                                borderRadius: BorderRadius.circular(360),
                                splashColor: Colors.grey,
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Transform.translate(
                                    offset: const Offset(0,-1.5),
                                    child: Text(
                                      "Statistiques",
                                      style: TextStyle(
                                        color: colorOut,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                      child: Container(
                        height: 1.0,
                        width: MediaQuery.of(context).size.width,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      "Hey BG, cette page est en dev, elle arrivera plus tard.",
                      textAlign: TextAlign.start,
                      style: GoogleFonts.adventPro(
                        textStyle: const TextStyle(
                          fontSize: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
