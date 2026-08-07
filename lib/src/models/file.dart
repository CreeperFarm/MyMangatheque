class AppwriteFile {
  AppwriteFile({
    required this.url,
    this.id,
    this.bucketId,
    this.fileName,
  });

  final String url;
  final String? id;
  final String? bucketId;
  final String? fileName;

  String? get path => url;

  factory AppwriteFile.fromUrl(String? url) {
    return AppwriteFile(url: url ?? '');
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppwriteFile && runtimeType == other.runtimeType && url == other.url;

  @override
  int get hashCode => url.hashCode;
}
