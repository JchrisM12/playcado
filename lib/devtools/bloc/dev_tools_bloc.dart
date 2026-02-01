import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chrome_cast/flutter_chrome_cast.dart';
import 'package:playcado/cast/models/cast_item.dart';
import 'package:playcado/cast/services/cast_service.dart';
import 'package:playcado/downloads_repository/downloads_repository.dart';
import 'package:playcado/media/models/media_item.dart';
import 'package:playcado/services/preferences_service.dart';
import 'package:playcado/services/secure_storage_service.dart';

part 'dev_tools_event.dart';
part 'dev_tools_state.dart';

class DevToolsBloc extends Bloc<DevToolsEvent, DevToolsState> {
  DevToolsBloc({
    required PreferencesService preferencesService,
    required CastService castService,
    required DownloadsRepository downloadsRepository,
    required SecureStorageService secureStorage,
  }) : _preferencesService = preferencesService,
       _castService = castService,
       _downloadsRepository = downloadsRepository,
       _secureStorage = secureStorage,
       super(const DevToolsState()) {
    on<DevToolsCastSessionUpdated>(_onCastSessionUpdated);
    on<DevToolsCastTestVideoRequested>(_onCastTestVideo);
    on<DevToolsClearPreferencesServiceRequested>(_onClearPreferencesService);
    on<DevToolsClearDownloadsDataRequested>(_onClearDownloadsData);
    on<DevToolsClearSecureStorageRequested>(_onClearSecureStorage);
    on<DevToolsDisconnectCastRequested>(_onDisconnectCast);
    on<DevToolsInitialized>(_onInitialized);
  }
  final PreferencesService _preferencesService;
  final CastService _castService;
  StreamSubscription? _castSubscription;
  final DownloadsRepository _downloadsRepository;
  final SecureStorageService _secureStorage;

  void _onCastSessionUpdated(
    DevToolsCastSessionUpdated event,
    Emitter<DevToolsState> emit,
  ) {
    emit(state.copyWith(isCastConnected: event.isConnected));
  }

  Future<void> _onCastTestVideo(
    DevToolsCastTestVideoRequested event,
    Emitter<DevToolsState> emit,
  ) async {
    const testUrl =
        'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';

    try {
      await _castService.loadMedia(
        const CastItem(
          mediaItem: MediaItem(
            id: 'test',
            name: 'TEST VIDEO (Big Buck Bunny)',
            type: MediaItemType.movie,
            overview:
                'Big Buck Bunny tells the story of a giant rabbit with a heart bigger than himself.',
          ),
          streamUrl: testUrl,
          imageUrl:
              'https://upload.wikimedia.org/wikipedia/commons/7/70/Big.Buck.Bunny.-.Opening.Screen.png',
          mimeType: 'video/mp4',
        ),
      );
      emit(
        state.copyWith(
          status: DevToolsStatus.success,
          message: 'Sending video to Cast device...',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: DevToolsStatus.error,
          message: 'Failed to cast test video',
        ),
      );
    }
  }

  Future<void> _onClearPreferencesService(
    DevToolsClearPreferencesServiceRequested event,
    Emitter<DevToolsState> emit,
  ) async {
    try {
      await _preferencesService.resetAll();
      emit(
        state.copyWith(
          status: DevToolsStatus.success,
          message: 'App Preferences Reset',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: DevToolsStatus.error,
          message: 'Error reseting app preferences: $e',
        ),
      );
    }
  }

  Future<void> _onClearDownloadsData(
    DevToolsClearDownloadsDataRequested event,
    Emitter<DevToolsState> emit,
  ) async {
    try {
      await _downloadsRepository.clearAll();
      emit(
        state.copyWith(
          status: DevToolsStatus.success,
          message: 'Downloads Meta Cleared',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: DevToolsStatus.error,
          message: 'Error clearing downloads: $e',
        ),
      );
    }
  }

  Future<void> _onClearSecureStorage(
    DevToolsClearSecureStorageRequested event,
    Emitter<DevToolsState> emit,
  ) async {
    try {
      await _secureStorage.deleteAll();
      emit(
        state.copyWith(
          status: DevToolsStatus.success,
          message: 'Secure Storage Cleared',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: DevToolsStatus.error,
          message: 'Error clearing storage: $e',
        ),
      );
    }
  }

  Future<void> _onDisconnectCast(
    DevToolsDisconnectCastRequested event,
    Emitter<DevToolsState> emit,
  ) async {
    await _castService.disconnect();
  }

  void _onInitialized(DevToolsInitialized event, Emitter<DevToolsState> emit) {
    // Check initial status
    final isConnected = _castService.isConnected;
    emit(state.copyWith(isCastConnected: isConnected));

    // Listen to session changes
    _castSubscription?.cancel();
    _castSubscription = _castService.currentSessionStream.listen((session) {
      final connected =
          session?.connectionState == GoogleCastConnectState.connected;
      add(DevToolsCastSessionUpdated(connected));
    });
  }

  @override
  Future<void> close() {
    _castSubscription?.cancel();
    return super.close();
  }
}
