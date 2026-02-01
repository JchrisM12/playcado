import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playcado/auth_repository/auth_repository.dart';
import 'package:playcado/core/status_wrapper.dart';
import 'package:playcado/services/logger_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required AuthRepository authRepository, User? initialUser})
    : _authRepository = authRepository,
      super(
        AuthState(
          user: initialUser != null
              ? StatusWrapper<User>().toSuccess(initialUser)
              : const StatusWrapper(),
          credentials: authRepository.currentCredentials,
        ),
      ) {
    on<AuthEnterOfflineModeRequested>(_onAuthEnterOfflineModeRequested);
    on<AuthLoadAccountsRequested>(_onAuthLoadAccountsRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthRemoveAccountRequested>(_onAuthRemoveAccountRequested);
    on<AuthSwitchAccountRequested>(_onAuthSwitchAccountRequested);
    on<AuthDemoModeRequested>(_onAuthDemoModeRequested);

    add(AuthLoadAccountsRequested());
  }

  final AuthRepository _authRepository;

  Future<void> _onAuthLoadAccountsRequested(
    AuthLoadAccountsRequested event,
    Emitter<AuthState> emit,
  ) async {
    final accounts = await _authRepository.getSavedAccounts();
    emit(state.copyWith(availableAccounts: accounts));
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(user: state.user.toLoading()));
    try {
      final user = await _authRepository.login(
        serverUrl: event.server,
        username: event.username,
        password: event.password,
        rememberCredentials: event.rememberCredentials,
      );

      if (user != null) {
        emit(
          state.copyWith(
            user: state.user.toSuccess(user),
            credentials: () => _authRepository.currentCredentials,
          ),
        );
        // Refresh accounts list
        add(AuthLoadAccountsRequested());
      } else {
        emit(state.copyWith(user: state.user.toError()));
      }
    } catch (e, stackTrace) {
      LoggerService.auth.severe('Login failed in AuthBloc', e, stackTrace);
      emit(state.copyWith(user: state.user.toError()));
    }
  }

  Future<void> _onAuthEnterOfflineModeRequested(
    AuthEnterOfflineModeRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isOfflineMode: true));
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.logout();
    // Keep the accounts list, just clear the user session and reset offline mode
    emit(
      state.copyWith(
        user: state.user.toInitial(),
        isOfflineMode: false,
        isDemoMode: false,
        credentials: () => null,
      ),
    );
  }

  Future<void> _onAuthDemoModeRequested(
    AuthDemoModeRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.logout();
    const demoUser = User(
      id: 'demo_user',
      name: 'Demo Pilot',
      serverAddress: 'demo.playcado.app',
      accessToken: 'demo_token',
    );
    _authRepository.setDemoUser(demoUser);
    emit(
      state.copyWith(isDemoMode: true, user: state.user.toSuccess(demoUser)),
    );
  }

  Future<void> _onAuthRemoveAccountRequested(
    AuthRemoveAccountRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.removeAccount(event.id);
    add(AuthLoadAccountsRequested());
  }

  Future<void> _onAuthSwitchAccountRequested(
    AuthSwitchAccountRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(user: state.user.toLoading()));
    try {
      final user = await _authRepository.login(
        serverUrl: event.credentials.serverName,
        username: event.credentials.username,
        password: event.credentials.password,
        rememberCredentials: true,
      );

      if (user != null) {
        emit(
          state.copyWith(
            user: state.user.toSuccess(user),
            credentials: () => _authRepository.currentCredentials,
          ),
        );
        // Refresh list to move this account to top
        add(AuthLoadAccountsRequested());
      } else {
        emit(state.copyWith(user: state.user.toError()));
      }
    } catch (e) {
      emit(state.copyWith(user: state.user.toError()));
    }
  }
}
