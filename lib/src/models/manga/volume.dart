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
    required this.lastTimeChecked,
  });

  final String id; // * Get the id of the volume
  final String title; // * Get the title of the volume
  final num? tomeNumber; // * Get the tome number of the volume
  num price; // * Get the price of the volume
  final String image; // * Get the image link of the volume
  final bool over18; // * Get if the volume is over 18
  final String resume; // * Get the resume of the volume
  List<dynamic> bookLink; // * Get the book link of the volume
  final DateTime? release; // * Get the release date of the volume
  final num ean; // * Get the ean of the volume
  final String? language; // * Get the language of the volume
  final String subSeries; // * Get the ID sub serie of the volume
  final String series; // * Get the ID serie of the volume
  final List<String> authors; // * Get the list of authors of the volume
  final List<String>? contains; // * Get the list of contains of the volume
  final Map<String, dynamic>? info; // * Get the info of the volume
  final String support; // * Get the support of the volume
  final String? japGenre; // * Get the japanese genre of the volume
  bool readed; // * Get if the volume is readed
  DateTime lastTimeChecked; // * Get the last time checked of the volume

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
      contains: json['contains'] != null
          ? List<String>.from(json['contains'])
          : null,
      info: json['info'],
      support: json['support'],
      japGenre: json['japGenre'],
      readed: json['readed'],
      lastTimeChecked: DateTime.parse(json['lastTimeChecked']),
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
      'lastTimeChecked': lastTimeChecked.toIso8601String(),
    };
  }
}
