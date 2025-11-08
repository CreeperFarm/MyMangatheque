import 'package:mymangatheque/src/models/manga/volume.dart';

class SubSerieForCollection {
  SubSerieForCollection(
      {required this.id, required this.title, required this.numberOfVolumes, required this.numberOwnedVolumes, required this.volumes, this.cover});

  final String id;
  final String title;
  final int numberOfVolumes;
  final String? cover;
  int numberOwnedVolumes;
  List<Volume> volumes;

  factory SubSerieForCollection.fromJson(Map<String, dynamic> json) {
    return SubSerieForCollection(
      id: json['id'],
      title: json['title'],
      numberOfVolumes: json['numberOfVolumes'],
      numberOwnedVolumes: json['numberOwnedVolumes'],
      volumes: json['volumes'] != null ? List<Volume>.from(json['volumes'].map((x) => Volume.fromJson(x))) : <Volume>[],
    );
  }

  removeVolume(Volume volume) {
    volumes.removeWhere((v) => v.id == volume.id);
  }

  containsVolume(Volume volume) {
    return volumes.any((v) => v.id == volume.id);
  }

  Map<String, dynamic> toJson() {
    if (cover == null) {
      return {
        'id': id,
        'title': title,
        'numberOfVolumes': numberOfVolumes,
        'numberOwnedVolumes': numberOwnedVolumes,
        'volumes': volumes.map((x) => x.toJson()).toList(),
      };
    } else {
      return {
        'id': id,
        'title': title,
        'numberOfVolumes': numberOfVolumes,
        'numberOwnedVolumes': numberOwnedVolumes,
        'volumes': volumes.map((x) => x.toJson()).toList(),
        'cover': cover,
      };
    }
  }
}
