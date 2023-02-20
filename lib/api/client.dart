
import '../model/music_tag_info.dart';

abstract class Client {

  Future<List<MusicTagInfo>> showPlaylist(int offset);

  Future<Map<String,dynamic>> search(String keyword, int page);

  Future<Map<String, dynamic>> getPlaylist(String playlistId);

  Future<String> bootstrapTrack(String trackId);

}