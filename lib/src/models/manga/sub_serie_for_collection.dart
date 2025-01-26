import 'package:mymangatheque/src/models/manga/volume.dart';

class SubSerieForCollection {
  SubSerieForCollection({
    required this.id,
    required this.title,
    required this.numberOfVolumes,
    required this.numberOwnedVolumes,
    required this.volumes,
  });

  final String id;
  final String title;
  final int numberOfVolumes;
  int numberOwnedVolumes;
  List<Volume> volumes;
}
