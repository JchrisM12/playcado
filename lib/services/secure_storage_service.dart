import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:playcado/auth_repository/auth_repository.dart';
import 'package:playcado/services/logger_service.dart';

class SecureStorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static const String _serverNameKey = 'server_name';
  static const String _usernameKey = 'username';
  static const String _passwordKey = 'password';
  static const String _savedAccountsKey = 'saved_accounts';

  // --- Active Session Management ---

  Future<void> storeCredentials(ServerCredentials credentials) async {
    LoggerService.secureStorage.info(
      'Storing active credentials for: ${credentials.username}',
    );
    try {
      await _storage.write(key: _serverNameKey, value: credentials.serverName);
      await _storage.write(key: _usernameKey, value: credentials.username);
      await _storage.write(key: _passwordKey, value: credentials.password);
    } catch (e, s) {
      LoggerService.secureStorage.severe('Failed to store credentials', e, s);
      throw Exception('Failed to store credentials: $e');
    }
  }

  Future<ServerCredentials?> retrieveCredentials() async {
    try {
      final serverName = await _storage.read(key: _serverNameKey);
      final username = await _storage.read(key: _usernameKey);
      final password = await _storage.read(key: _passwordKey);

      if (serverName != null && username != null && password != null) {
        LoggerService.secureStorage.fine('Credentials retrieved successfully');
        return ServerCredentials(
          serverName: serverName,
          username: username,
          password: password,
        );
      }
      return null;
    } catch (e, s) {
      LoggerService.secureStorage.severe(
        'Failed to retrieve credentials',
        e,
        s,
      );
      throw Exception('Failed to retrieve credentials: $e');
    }
  }

  Future<bool> hasCredentials() async {
    try {
      final serverName = await _storage.read(key: _serverNameKey);
      final username = await _storage.read(key: _usernameKey);
      final password = await _storage.read(key: _passwordKey);

      return serverName != null && username != null && password != null;
    } catch (e) {
      return false;
    }
  }

  Future<void> clearCredentials() async {
    LoggerService.secureStorage.info('Clearing active credentials');
    try {
      await _storage.delete(key: _serverNameKey);
      await _storage.delete(key: _usernameKey);
      await _storage.delete(key: _passwordKey);
    } catch (e, s) {
      LoggerService.secureStorage.severe('Failed to clear credentials', e, s);
      throw Exception('Failed to clear credentials: $e');
    }
  }

  // --- Multi-Account Management ---

  Future<List<ServerCredentials>> getSavedAccounts() async {
    try {
      final jsonString = await _storage.read(key: _savedAccountsKey);
      if (jsonString == null) return [];
      final List<dynamic> list = jsonDecode(jsonString);
      return list.map((e) => ServerCredentials.fromMap(e)).toList();
    } catch (e, s) {
      LoggerService.secureStorage.warning(
        'Failed to parse saved accounts',
        e,
        s,
      );
      return [];
    }
  }

  Future<void> saveAccount(ServerCredentials credentials) async {
    try {
      final accounts = await getSavedAccounts();
      // Remove if exists to update (avoid duplicates)
      accounts.removeWhere((element) => element.id == credentials.id);
      // Add to top of list
      accounts.insert(0, credentials);

      await _storage.write(
        key: _savedAccountsKey,
        value: jsonEncode(accounts.map((e) => e.toMap()).toList()),
      );
    } catch (e, s) {
      LoggerService.secureStorage.severe('Failed to save account list', e, s);
      throw Exception('Failed to save account list: $e');
    }
  }

  Future<void> removeAccount(String id) async {
    try {
      final accounts = await getSavedAccounts();
      accounts.removeWhere((element) => element.id == id);
      await _storage.write(
        key: _savedAccountsKey,
        value: jsonEncode(accounts.map((e) => e.toMap()).toList()),
      );
    } catch (e, s) {
      LoggerService.secureStorage.severe('Failed to remove account', e, s);
      throw Exception('Failed to remove account: $e');
    }
  }

  Future<void> deleteAll() async {
    LoggerService.secureStorage.warning('Deleting ALL secure storage data');
    try {
      await _storage.deleteAll();
    } catch (e, s) {
      LoggerService.secureStorage.severe(
        'Failed to delete all stored data',
        e,
        s,
      );
      throw Exception('Failed to delete all stored data: $e');
    }
  }
}
