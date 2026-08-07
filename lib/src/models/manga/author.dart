class Author {
  Author({
    required this.id,
    required this.name,
    required this.image,
    required this.series,
    required this.job,
    required this.lastTimeChecked,
  });

  final String id; // * Get the ID of the author
  final String name; // * Get the name of the author
  final String image; // * Get the image link of the author
  List<String> series; // * Get the list of IDs of serie where the author worked on
  final String job; // * Get the job of the author
  DateTime lastTimeChecked; // * Get the last time checked of the author

  static String _resolveImage(Map<String, dynamic> json) {
    return (json['image'] ?? json['coverUrl'] ?? '').toString();
  }

  factory Author.fromJson(Map<String, dynamic> json) => Author(
    id: json['id'],
    name: json['name'],
    image: _resolveImage(json),
    series: List<String>.from(json['series'].map((x) => x)),
    job: json['job'],
    lastTimeChecked: DateTime.parse(json['lastTimeChecked']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'image': image,
    'coverUrl': image,
    'series': List<dynamic>.from(series.map((x) => x)),
    'job': job,
    'lastTimeChecked': lastTimeChecked.toIso8601String(),
  };
}
