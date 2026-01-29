import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mymangatheque/l10n/app_localizations.dart';
import 'package:mymangatheque/src/back/provider/search_filter_provider.dart';
import 'package:mymangatheque/src/const/assets.dart';
import 'package:mymangatheque/src/const/own_icon.dart';

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
    /*var data = await FirebaseFirestore.instance
        .collection('manga')
        .orderBy(ref.watch(searchFilterProvider))
        .get();

    setState(() {
      _allResults = data.docs;
    });*/
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Get localization - return early if not available
    var localizations = AppLocalizations.of(context);
    if (localizations == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final selectedFilter = ref.watch(searchFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(localizations.discover),
            PopupMenuButton<String>(
              icon: OwnIcon(iconColor: Theme.of(context).colorScheme.primary, iconSrc: Assets.icons.filterRight),
              onSelected: (String result) {
                setState(() {
                  changeFilter(result);
                });
              },
              offset: const Offset(0, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.5),
              color: Theme.of(context).colorScheme.onPrimary,
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'manga',
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (selectedFilter == 'manga')
                        const Icon(Icons.check)
                      else
                        const Padding(
                            padding: EdgeInsets.only(
                          right: 0,
                        )),
                      Text(localizations.manga),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                    value: 'editor',
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (selectedFilter == 'editor') const Icon(Icons.check) else const Padding(padding: EdgeInsets.only(right: 0)),
                        Text(localizations.editor),
                      ],
                    )),
                PopupMenuItem<String>(
                  value: 'author',
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (selectedFilter == 'author') const Icon(Icons.check) else const Padding(padding: EdgeInsets.only(right: 0)),
                      Text(localizations.author),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                localizations.discover,
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
