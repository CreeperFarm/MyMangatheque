class SubSerie {
  SubSerie({
    required this.id,
    required this.title,
    required this.serie,
    required this.volumes,
    required this.authors,
    required this.editor,
    required this.image,
    required this.genres,
    required this.firstPublication,
  });

  final String id;
  final String title;
  final String serie;
  List<String> volumes;
  List<String> authors;
  final String editor;
  final String image;
  List<String> genres;
  final DateTime firstPublication;
}
