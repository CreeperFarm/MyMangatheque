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

  factory Volume.fromJson(Map<String, dynamic> json) {
    return Volume(
      id: json['id'],
      title: json['title'],
      tomeNumber: json['tomeNumber'],
      price: json['price'],
      image: json['image'],
      over18: json['over18'],
      resume: json['resume'],
      bookLink: json['bookLink'],
      release: DateTime.parse(json['release']),
      ean: json['ean'],
      language: json['language'],
      subSeries: json['subSeries'],
      series: json['series'],
      authors: List<String>.from(json['authors']),
      contains: json['contains'],
      info: json['info'],
      support: json['support'],
      japGenre: json['japGenre'],
      readed: json['readed'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'tomeNumber': tomeNumber,
      'price': price,
      'image': image,
      'over18': over18,
      'resume': resume,
      'bookLink': bookLink,
      'release': release!.toIso8601String(),
      'ean': ean,
      'language': language,
      'subSeries': subSeries,
      'series': series,
      'authors': authors,
      'contains': contains,
      'info': info,
      'support': support,
      'japGenre': japGenre,
      'readed': readed,
    };
  }
}
