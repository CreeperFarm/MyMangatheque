import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymangatheque/src/const/own_icon.dart';
import 'package:mymangatheque/src/provider/search_filter_provider.dart';
import 'package:mymangatheque/src/provider/theme_color_provider.dart';

class DiscoverPage extends ConsumerStatefulWidget {
  const DiscoverPage({super.key});

  @override
  ConsumerState<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends ConsumerState<DiscoverPage> {
  List _allResults = [];

  String textLength(text, length) {
    if (text.length > length) {
      return text.substring(0, length) + "...";
    } else {
      return text;
    }
  }

  void changeFilter(String filter) {
    ref.read(searchFilterProvider.notifier).changeSearchFilter(filter);
  }

  getClientStream() async {
    var data = await FirebaseFirestore.instance
        .collection('manga')
        .orderBy(ref.watch(searchFilterProvider))
        .get();

    setState(() {
      _allResults = data.docs;
    });
  }

  @override
  void initState() {
    ref.read(themeBgColorProvider);
    ref.read(searchFilterProvider);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final textColor = ref.watch(themeTextColorProvider);
    final bgColor = ref.watch(themeBgColorProvider);
    final selectedFilter = ref.watch(searchFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Découvrir"),
            PopupMenuButton<String>(
              icon: OwnIcon(iconColor: textColor, iconName: "filter_right"),
              onSelected: (String result) {
                setState(() {
                  changeFilter(result);
                });
              },
              offset: const Offset(0, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              shadowColor: textColor.withOpacity(0.5),
              color: bgColor,
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'manga',
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (selectedFilter == 'manga')
                        const Icon(Icons.check)
                      else
                        const Padding(padding: EdgeInsets.only(right: 0)),
                      const Text('Manga'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                    value: 'editor',
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (selectedFilter == 'editor')
                          const Icon(Icons.check)
                        else
                          const Padding(padding: EdgeInsets.only(right: 0)),
                        const Text('Éditeur'),
                      ],
                    )),
                PopupMenuItem<String>(
                  value: 'author',
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (selectedFilter == 'author')
                        const Icon(Icons.check)
                      else
                        const Padding(padding: EdgeInsets.only(right: 0)),
                      const Text('Auteur'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: const Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Discover",
                style: TextStyle(
                  fontSize: 25,
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
