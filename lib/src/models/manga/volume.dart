class Volume {
  Volume({
    required this.id,
    required this.title,
    required this.tomeNumber,
    required this.price,
    required this.image,
    required this.over18,
    required this.resume,
    required this.bookLink,
    required this.release,
    required this.ean,
    required this.language,
    required this.subSeries,
    required this.series,
    required this.readed,
    required this.authors,
    required this.contains,
    required this.info,
    required this.support,
    required this.japGenre,
  });

  final String id;
  final String title;
  final num? tomeNumber;
  final num price;
  final String image;
  final bool over18;
  final String resume;
  final List<dynamic> bookLink;
  final DateTime? release;
  final num ean;
  final String? language;
  final String subSeries;
  final String series;
  final List<String> authors;
  final List<dynamic>? contains; // TODO: Convert it to a list of Volumes
  final Map<String, dynamic>? info;
  final String support;
  final String? japGenre;
  bool readed;
}
