import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:mymangatheque/src/back/services/pocketbase.dart';
import 'package:riverpod/riverpod.dart';

class MangaOwnedNotifier extends Notifier<List<dynamic>> {
  @override
  List<dynamic> build() => [];

  initialize() async {
    if (PocketBaseConnector().isLoggedIn()) {
      try {
        final result = await PocketBaseConnector().getCollectionDataWithFilterExpand(
          'owned',
          "user='${PocketBaseConnector().getConnectedUser()!.id}'",
          'volume.sub_series',
        );
        final data = json.decode(result.toString());
        print(data);
        Map<String, dynamic> subSeriesMap = {};
        for (var i = 0; i < data.length; i++) {
          String title = data[i]['expand']['volume']['expand']['sub_series']['title'];
          if (subSeriesMap.containsKey(title)) {
            subSeriesMap[title]['volumes'].add({
              'title': data[i]['expand']['volume']['title'],
              'image': data[i]['expand']['volume']['image'],
              'id': data[i]['expand']['volume']['id']
            });
          } else {
            subSeriesMap[title] = {
              'title': title,
              'id': data[i]['expand']['volume']['expand']['sub_series']['id'],
              'first_index_data': i,
              'volumes': [
                {
                  'title': data[i]['expand']['volume']['title'],
                  'image': data[i]['expand']['volume']['image'],
                  'id': data[i]['expand']['volume']['id']
                }
              ]
            };
          }
        }
        print(subSeriesMap);
        state = subSeriesMap.values.toList();
      } catch (e) {
        debugPrint(e.toString());
        state = [];
      }
    } else {
      state = [];
    }
  }

  void newDataSet(newDataSet) {
    state = newDataSet;
  }

  void addDataSubSeries(newSubSeries) {
    state.add(newSubSeries);
  }

  void addVolumeOwned(subSeriesId, newVolumeOwned) {
    state.firstWhere((subSeries) => subSeries['id'] == subSeriesId)['volumes'].add(newVolumeOwned);
  }
}

final mangaOwnedProvider = NotifierProvider<MangaOwnedNotifier, List<dynamic>>(() {
  return MangaOwnedNotifier();
});
