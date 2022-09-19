
/// 歌单信息
class MusicTagInfo {
  /// 图片地址
  late String coverImgUrl;

  /// 歌单标题
  late String title;
  /// 歌单ID
  late String id;
  /// 歌单资源地址
  late String sourceUrl;

  MusicTagInfo(this.coverImgUrl, this.title, this.id, this.sourceUrl);

  set setCoverImgUrl(String value) => coverImgUrl = value;

  String get getCoverImgUrl => coverImgUrl;

  set setTitle(String value) => title = value;

  String get getTitle => title;

  set setId(String value) => id = value;

  String get getId => id;

  set setSourceUrl(String value) => sourceUrl = value;

  String get getSourceUrl => sourceUrl;

  @override
  String toString() {
    return 'MusicTagInfo{coverImgUrl: $coverImgUrl, title: $title, id: $id, sourceUrl: $sourceUrl}';
  }
}