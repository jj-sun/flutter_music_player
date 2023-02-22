
/// 音乐信息
class MusicInfo {
  late String _id;
  late String _title;
  late String _artist;
  late String _artistId;
  late String _album;
  late String _albumId;
  late String _imgUrl;
  late String _source;
  late String _sourceUrl;
  late String? _url;
  //late bool? _disabled;

  MusicInfo();

  void setId(String id) => _id = id;
  String get getId => _id;

  void setTitle(String title) => _title = title;
  String get getTitle => _title;

  void setArtist(String artist) => _artist = artist;
  String get getArtist => _artist;

  void setArtistId(String artistId) => _artistId = artistId;
  String get getArtistId => _artistId;

  void setAlbum(String album) => _album = album;
  String get getAlbum => _album;

  void setAlbumId(String albumId) => _albumId = albumId;
  String get getAlbumId => _albumId;

  void setImgUrl(String imgUrl) => _imgUrl = imgUrl;
  String get getImgUrl => _imgUrl;

  void setSource(String source) => _source = source;
  String get getSource => _source;

  void setSourceUrl(String sourceUrl) => _sourceUrl = sourceUrl;
  String get getSourceUrl => _sourceUrl;

  void setUrl(String? url) => _url = url;
  String? get getUrl => _url;

  /*void setDisabled(bool disabled) => _disabled = disabled;
  bool? get getDisabled => _disabled;*/

  @override
  String toString() {
    if(getUrl == null || getUrl!.isEmpty) {
      return 'MusicInfo{_id: $_id, _title: $_title, _artist: $_artist, _artistId: $_artistId, _album: $_album, _albumId: $_albumId, _imgUrl: $_imgUrl, _source: $_source, _sourceUrl: $_sourceUrl';

    } else {
      return 'MusicInfo{_id: $_id, _title: $_title, _artist: $_artist, _artistId: $_artistId, _album: $_album, _albumId: $_albumId, _imgUrl: $_imgUrl, _source: $_source, _sourceUrl: $_sourceUrl, _url: $_url';

    }
  }
}