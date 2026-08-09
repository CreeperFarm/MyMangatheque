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
    required this.lastTimeChecked,
  });

  final String id; // * Get the ID of the sub serie
  final String title; // * Get the title of the sub serie
  final String serie; // * Get the serie id of the sub serie
  List<String> volumes; // * Get the list of IDs of volume of the sub serie
  List<String> authors; // * Get the list of IDs of authors of the sub serie
  final String editor; // * Get the ID of the editor of the sub serie
  final String image; // * Get the image link of the sub serie
  List<String> genres; // * Get the list of genres of the sub serie
  final DateTime
  firstPublication; // * Get the first publication date of the sub serie
  DateTime lastTimeChecked; // * Get the last time the sub serie was checked

  static String _resolveImage(Map<String, dynamic> json) {
    return (json['image'] ?? json['coverUrl'] ?? '').toString();
  }

  factory SubSerie.fromJson(Map<String, dynamic> json) => SubSerie(
    id: json['id'],
    title: json['title'],
    serie: json['serie'],
    volumes: List<String>.from(json['volumes'].map((x) => x)),
    authors: List<String>.from(json['authors'].map((x) => x)),
    editor: json['editor'],
    image: _resolveImage(json),
    genres: List<String>.from(json['genres'].map((x) => x)),
    firstPublication: DateTime.parse(json['firstPublication']),
    lastTimeChecked: DateTime.parse(json['lastTimeChecked']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'serie': serie,
    'volumes': List<dynamic>.from(volumes.map((x) => x)),
    'authors': List<dynamic>.from(authors.map((x) => x)),
    'editor': editor,
    'image': image,
    'coverUrl': image,
    'genres': List<dynamic>.from(genres.map((x) => x)),
    'firstPublication': firstPublication.toIso8601String(),
    'lastTimeChecked': lastTimeChecked.toIso8601String(),
  };
}
