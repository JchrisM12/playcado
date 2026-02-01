import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playcado/downloads_repository/downloads_repository.dart';
import 'package:playcado/media/models/media_item.dart';
import 'package:playcado/services/logger_service.dart';

part 'downloads_event.dart';
part 'downloads_state.dart';

class DownloadsBloc extends Bloc<DownloadsEvent, DownloadsState> {
  final DownloadsRepository _downloadsRepository;
  StreamSubscription? _subscription;

  DownloadsBloc({required DownloadsRepository repository})
    : _downloadsRepository = repository,
      super(const DownloadsState()) {
    on<DownloadsDeleteRequested>(_onDownloadsDeleteRequested);
    on<DownloadsInitialized>(_onDownloadsInitialized);
    on<DownloadsPauseRequested>(_onDownloadsPauseRequested);
    on<DownloadsResumeRequested>(_onDownloadsResumeRequested);
    on<DownloadsStartRequested>(_onDownloadsStartRequested);
    on<DownloadsRequested>(_onDownloadsRequested);
    on<DownloadsUpdated>(_onDownloadsUpdated);

    add(DownloadsInitialized());
  }

  Future<void> _onDownloadsDeleteRequested(
    DownloadsDeleteRequested event,
    Emitter<DownloadsState> emit,
  ) async {
    await _downloadsRepository.deleteDownload(event.id);
  }

  void _onDownloadsInitialized(
    DownloadsInitialized event,
    Emitter<DownloadsState> emit,
  ) {
    LoggerService.downloads.info('Initializing DownloadsBloc');
    // Check if repository already has data (handling potential race condition with async init)
    if (_downloadsRepository.currentDownloads.isNotEmpty) {
      emit(
        state.copyWith(
          downloads: _downloadsRepository.currentDownloads,
          isLoading: false,
        ),
      );
    }

    _subscription?.cancel();
    _subscription = _downloadsRepository.downloads.listen((items) {
      add(DownloadsUpdated(items));
    });
  }

  Future<void> _onDownloadsPauseRequested(
    DownloadsPauseRequested event,
    Emitter<DownloadsState> emit,
  ) async {
    await _downloadsRepository.pauseDownload(event.id);
  }

  Future<void> _onDownloadsResumeRequested(
    DownloadsResumeRequested event,
    Emitter<DownloadsState> emit,
  ) async {
    await _downloadsRepository.resumeDownload(event.id);
  }

  Future<void> _onDownloadsStartRequested(
    DownloadsStartRequested event,
    Emitter<DownloadsState> emit,
  ) async {
    LoggerService.downloads.info('User requested download: ${event.item.name}');
    try {
      await _downloadsRepository.addDownload(event.item);
    } catch (e, s) {
      LoggerService.downloads.severe('Error adding download in Bloc', e, s);
    }
  }

  Future<void> _onDownloadsRequested(
    DownloadsRequested event,
    Emitter<DownloadsState> emit,
  ) async {
    final item = event.item;
    LoggerService.downloads.info(
      'Preparing original quality download for ${item.name}',
    );

    try {
      await _downloadsRepository.addMediaDownload(item);
    } catch (e, s) {
      LoggerService.downloads.severe('Error preparing download', e, s);
    }
  }

  void _onDownloadsUpdated(
    DownloadsUpdated event,
    Emitter<DownloadsState> emit,
  ) {
    emit(state.copyWith(downloads: event.items, isLoading: false));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
