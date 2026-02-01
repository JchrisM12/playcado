import 'package:flutter/material.dart';
import 'package:playcado/l10n/app_localizations.dart';
import 'package:playcado/media/models/media_item.dart';

class MediaDetailsOverview extends StatelessWidget {
  final MediaItem item;
  final MediaItem? nextEpisode;

  const MediaDetailsOverview({
    super.key,
    required this.item,
    this.nextEpisode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Use specific item metadata if it is an episode (playing) or next up
    final displayItem =
        (item.type == MediaItemType.series && nextEpisode != null)
            ? nextEpisode
            : item;
    final overviewText = displayItem?.overview;

    if (overviewText == null || overviewText.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (displayItem?.type == MediaItemType.episode) ...[
          Text(
            'S${displayItem!.parentIndexNumber} E${displayItem.indexNumber} - ${displayItem.name}',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
        ] else ...[
          Text(
            l10n.overview,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Text(
          overviewText,
          style: theme.textTheme.bodyLarge?.copyWith(
            height: 1.5,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
