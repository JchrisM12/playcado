import 'dart:convert';
import 'package:equatable/equatable.dart';

class ServerCredentials extends Equatable {
  final String serverName;
  final String username;
  final String password;

  const ServerCredentials({
    required this.serverName,
    required this.username,
    required this.password,
  });

  /// Unique identifier for this credential set
  String get id => '$username@$serverName';

  Map<String, dynamic> toMap() {
    return {
      'serverName': serverName,
      'username': username,
      'password': password,
    };
  }

  factory ServerCredentials.fromMap(Map<String, dynamic> map) {
    return ServerCredentials(
      serverName: map['serverName'] ?? '',
      username: map['username'] ?? '',
      password: map['password'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory ServerCredentials.fromJson(String source) =>
      ServerCredentials.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ServerCredentials(serverName: $serverName, username: $username)';
  }

  @override
  List<Object?> get props => [serverName, username, password];
}
