class Author {
  const Author({
    required this.id,
    required this.name,
    required this.image,
    required this.series,
    required this.job,
  });

  final String id;
  final String name;
  final String image;
  final List<dynamic> series;
  final String job;
}
