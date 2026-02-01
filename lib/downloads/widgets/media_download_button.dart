import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:playcado/app_router/app_router.dart';
import 'package:playcado/core/extensions.dart';
import 'package:playcado/downloads/bloc/downloads_bloc.dart';
import 'package:playcado/downloads_repository/models/download_item.dart';
import 'package:playcado/media/models/media_item.dart';
import 'package:playcado/widgets/snackbar_helper.dart';

class MediaDownloadButton extends StatelessWidget {
  final MediaItem item;

  const MediaDownloadButton({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DownloadsBloc, DownloadsState>(
      builder: (context, state) {
        final downloadItem = state.downloads
            .where((d) => d.id == item.id)
            .fold<DownloadItem?>(null, (prev, elem) => elem);

        final status = downloadItem?.status;
        final isDownloaded = status == DownloadStatus.completed;
        final isDownloading =
            status == DownloadStatus.downloading ||
            status == DownloadStatus.queued;
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        if (isDownloading) {
          final progress = downloadItem?.progress ?? 0.0;
          return Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 2.5,
                      backgroundColor: colorScheme.primary.withValues(
                        alpha: 0.2,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.download_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          );
        }

        if (isDownloaded) {
          return IconButton(
            style: IconButton.styleFrom(
              backgroundColor: Colors.black.withValues(alpha: 0.4),
              foregroundColor: colorScheme.error,
            ),
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () {
              context.read<DownloadsBloc>().add(
                DownloadsDeleteRequested(item.id),
              );
              SnackbarHelper.showInfo(
                context,
                context.l10n.deletedItem(item.name),
              );
            },
            tooltip: context.l10n.delete,
          );
        }

        return IconButton(
          style: IconButton.styleFrom(
            backgroundColor: Colors.black.withValues(alpha: 0.4),
            foregroundColor: Colors.white,
          ),
          icon: const Icon(Icons.download_rounded),
          onPressed: () {
            context.read<DownloadsBloc>().add(DownloadsRequested(item: item));
            SnackbarHelper.showInfo(context, context.l10n.downloadStarted);
            context.go(AppRouter.downloadsPath);
          },
          tooltip: context.l10n.download,
        );
      },
    );
  }
}
