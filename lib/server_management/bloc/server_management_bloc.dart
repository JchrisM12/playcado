import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playcado/auth_repository/auth_repository.dart';
import 'package:playcado/services/secure_storage_service.dart';

part 'server_management_event.dart';
part 'server_management_state.dart';

class ServerManagementBloc
    extends Bloc<ServerManagementEvent, ServerManagementState> {
  final SecureStorageService _secureStorage;

  ServerManagementBloc({required SecureStorageService secureStorage})
    : _secureStorage = secureStorage,
      super(const ServerManagementState()) {
    on<ServerManagementLoadLastUsed>(_onLoadLastUsed);
    on<ServerManagementPopulateForm>(_onPopulateForm);
    on<ServerManagementClearForm>(_onClearForm);
  }

  Future<void> _onLoadLastUsed(
    ServerManagementLoadLastUsed event,
    Emitter<ServerManagementState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final creds = await _secureStorage.retrieveCredentials();
      if (creds != null) {
        emit(
          state.copyWith(
            serverUrl: creds.serverName,
            username: creds.username,
            password: creds.password,
            isLoading: false,
          ),
        );
      } else {
        emit(state.copyWith(isLoading: false));
      }
    } catch (_) {
      emit(state.copyWith(isLoading: false));
    }
  }

  void _onPopulateForm(
    ServerManagementPopulateForm event,
    Emitter<ServerManagementState> emit,
  ) {
    emit(
      state.copyWith(
        serverUrl: event.credentials.serverName,
        username: event.credentials.username,
        password: event.credentials.password,
        isLoading: false,
      ),
    );
  }

  void _onClearForm(
    ServerManagementClearForm event,
    Emitter<ServerManagementState> emit,
  ) {
    emit(const ServerManagementState(isLoading: false));
  }
}
