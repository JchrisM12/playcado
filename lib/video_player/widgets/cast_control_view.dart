import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playcado/cast/services/cast_service.dart';
import 'package:playcado/core/extensions.dart';
import 'package:playcado/media/models/media_item.dart';

class CastControlView extends StatelessWidget {
  final MediaItem? item;

  const CastControlView({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cast_connected_rounded,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 32),
          Text(
            context.l10n.castingToDevice,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              item?.name ?? context.l10n.mediaType,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 48),
          FilledButton.icon(
            onPressed: () {
              context.read<CastService>().disconnect();
            },
            icon: const Icon(Icons.stop_circle_outlined),
            label: Text(context.l10n.stopCasting),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
