class Serie {
  Serie({
    required this.id,
    required this.image,
    required this.title,
    required this.subSeries,
    required this.authors,
    required this.editors,
    required this.genres,
    required this.lastTimeChecked,
  });

  final String id; // * Get the ID of the serie
  final String title; // * Get the title of the serie
  final String image; // * Get the image link of the serie
  List<String> subSeries; // * Get the list of IDs of sub series of the serie
  List<String> authors; // * Get the list of IDs of authors of the serie
  List<String> editors; // * Get the list of IDs of editors of the serie
  List<String> genres; // * Get the list of genres of the serie
  DateTime lastTimeChecked; // * Get the last time the serie was checked

  factory Serie.fromJson(Map<String, dynamic> json) => Serie(
    id: json['id'],
    title: json['title'],
    image: json['image'],
    subSeries: List<String>.from(json['subSeries'].map((x) => x)),
    authors: List<String>.from(json['authors'].map((x) => x)),
    editors: List<String>.from(json['editors'].map((x) => x)),
    genres: List<String>.from(json['genres'].map((x) => x)),
    lastTimeChecked: DateTime.parse(json['lastTimeChecked']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'image': image,
    'subSeries': List<dynamic>.from(subSeries.map((x) => x)),
    'authors': List<dynamic>.from(authors.map((x) => x)),
    'editors': List<dynamic>.from(editors.map((x) => x)),
    'genres': List<dynamic>.from(genres.map((x) => x)),
    'lastTimeChecked': lastTimeChecked.toIso8601String(),
  };
}
