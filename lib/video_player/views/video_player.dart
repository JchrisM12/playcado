import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:playcado/app_router/app_router.dart';
import 'package:playcado/media/models/media_item.dart';
import 'package:playcado/video_player/bloc/video_player_bloc.dart';
import 'package:playcado/video_player/services/player_service.dart';
import 'package:playcado/video_player/widgets/video_controls_overlay.dart';

/// A widget that renders the Video output using the global player state.
class VideoPlayer extends StatefulWidget {
  final MediaItem item;
  final String? localPath;
  final bool isFullscreen;

  const VideoPlayer({
    super.key,
    required this.item,
    this.localPath,
    this.isFullscreen = false,
  });

  @override
  State<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  // We use the global controller from the service
  late VideoController controller;

  @override
  void initState() {
    super.initState();
    controller = context.read<PlayerService>().controller;
  }

  Future<void> _handleFullscreenToggle() async {
    if (widget.isFullscreen) {
      if (context.canPop()) {
        context.pop();
      }
    } else {
      // Enter fullscreen
      // We pass nothing extra because the global bloc holds the state
      await context.push(AppRouter.videoPlayerPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    // We don't need to rebuild the Video widget itself constantly,
    // as it binds to the controller which is stable.
    // However, we listen to the Bloc for metadata updates/state changes.
    return BlocBuilder<VideoPlayerBloc, VideoPlayerState>(
      builder: (context, state) {
        // Fallback title if state doesn't match widget (transition edge case)
        final title = state.mediaItem?.name ?? widget.item.name;

        return ColoredBox(
          color: Colors.black,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Center(
                child: Hero(
                  tag: 'video_player_${widget.item.id}',
                  child: Video(
                    controller: controller,
                    controls: NoVideoControls,
                  ),
                ),
              ),
              VideoControlsOverlay(
                player: context.read<PlayerService>().player,
                title: title,
                isFullscreen: widget.isFullscreen,
                onFullscreenToggle: _handleFullscreenToggle,
              ),
            ],
          ),
        );
      },
    );
  }
}
