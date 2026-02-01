import 'package:jellyfin_dart/jellyfin_dart.dart';
import 'package:playcado/auth_repository/models/server_credentials.dart';

class JellyfinClientService {
  JellyfinDart? _client;
  ServerCredentials? _credentials;
  String? _accessToken;
  String? _deviceId;

  JellyfinDart? get client => _client;
  ServerCredentials? get credentials => _credentials;
  String? get accessToken => _accessToken;
  String? get deviceId => _deviceId;
  bool get hasSession =>
      _client != null && _credentials != null && _accessToken != null;

  void setClient(
    JellyfinDart client,
    ServerCredentials credentials,
    String accessToken,
    String deviceId,
  ) {
    _client = client;
    _credentials = credentials;
    _accessToken = accessToken;
    _deviceId = deviceId;
  }

  void clear() {
    _client = null;
    _credentials = null;
    _accessToken = null;
    _deviceId = null;
  }
}
