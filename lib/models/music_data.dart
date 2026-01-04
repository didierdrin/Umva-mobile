class MusicData {
  final String title;
  final String channelTitle;
  final String url;
  final String image;
  final bool favorite;
  final bool subscription;

  const MusicData(this.title, this.channelTitle, this.url, this.image, this.favorite, this.subscription);

  MusicData copyWith({bool? favorite}) => MusicData(title, channelTitle, url, image, favorite ?? this.favorite, subscription);
}