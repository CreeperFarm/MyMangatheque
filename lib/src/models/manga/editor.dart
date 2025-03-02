class Editor {
  Editor({
    required this.id,
    required this.name,
    required this.image,
    required this.series,
    required this.lastTimeChecked,
  });

  final String id; // * Get the ID of the editor
  final String name; // * Get the name of the editor
  final String image; // * Get the image link of the editor
  List<String> series; // * Get the IDs of series of the editor
  DateTime lastTimeChecked; // * Get the last time the editor was checked

  factory Editor.fromJson(Map<String, dynamic> json) {
    return Editor(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      series: List<String>.from(json['series']),
      lastTimeChecked: DateTime.parse(json['lastTimeChecked']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'series': series,
      'lastTimeChecked': lastTimeChecked.toIso8601String(),
    };
  }
}
