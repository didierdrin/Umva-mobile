class MusicData {
  final String id;
  final String title;
  final String channelTitle;
  final String url;
  final String image;
  final bool favorite;
  final bool subscription;

  const MusicData(this.title, this.channelTitle, this.url, this.image, this.favorite, this.subscription, {this.id = ''});

  factory MusicData.fromJson(Map<String, dynamic> json) => MusicData(
        json['title'] as String? ?? '',
        json['artist'] as String? ?? '',
        json['file_url'] as String? ?? '',
        json['image_url'] as String? ?? '',
        false,
        json['subscription'] as bool? ?? false,
        id: json['id'] as String? ?? '',
      );

  /// Stable identity for Hero tags. Falls back to url for the (now unused)
  /// case of a MusicData built without a database id.
  String get heroTag => id.isNotEmpty ? id : url;

  MusicData copyWith({bool? favorite}) =>
      MusicData(title, channelTitle, url, image, favorite ?? this.favorite, subscription, id: id);
}
