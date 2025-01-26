class Serie {
  Serie({
    required this.id,
    required this.title,
    required this.subSeries,
  });

  final String id;
  final String title;
  List<String> subSeries;
}
