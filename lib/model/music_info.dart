
import 'package:flutter_music_player/model/music_tag_info.dart';

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
  late String _url;
  late bool _disabled;

  MusicInfo(this._id,this._title,this._artist,this._artistId,this._album,this._albumId,this._imgUrl,this._source,this._sourceUrl,this._url,this._disabled);

  set setId(String id) => _id = id;
  get getId => _id;

  set setTitle(String title) => _title = title;
  get getTitle => _title;

  set setArtist(String artist) => _artist = artist;
  get getArtist => _artist;

  set setArtistId(String artistId) => _artistId = artistId;
  get getArtistId => _artistId;

  set setAlbum(String album) => _album = album;
  get getAlbum => _album;

  set setAlbumId(String albumId) => _albumId = albumId;
  get getAlbumId => _albumId;

  set setImgUrl(String imgUrl) => _imgUrl = imgUrl;
  get getImgUrl => _imgUrl;

  set setSource(String source) => _source = source;
  get getSource => _source;

  set setSourceUrl(String sourceUrl) => _sourceUrl = sourceUrl;
  get getSourceUrl => _sourceUrl;

  set setUrl(String url) => _url = url;
  get getUrl => _url;

  set setDisabled(bool disabled) => _disabled = disabled;
  get getDisabled => _disabled;

  @override
  String toString() {
    return 'MusicInfo{_id: $_id, _title: $_title, _artist: $_artist, _artistId: $_artistId, _album: $_album, _albumId: $_albumId, _imgUrl: $_imgUrl, _source: $_source, _sourceUrl: $_sourceUrl, _url: $_url, _disabled: $_disabled}';
  }
}