import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:playcado/video_player/bloc/video_player_bloc.dart';
import 'package:playcado/video_player/services/player_service.dart';
import 'package:playcado/video_player/widgets/cast_control_view.dart';
import 'package:playcado/video_player/widgets/video_controls_overlay.dart';
import 'package:playcado/widgets/loading_indicator.dart';

class FullscreenPlayerScreen extends StatefulWidget {
  const FullscreenPlayerScreen({super.key});

  @override
  State<FullscreenPlayerScreen> createState() => _FullscreenPlayerScreenState();
}

class _FullscreenPlayerScreenState extends State<FullscreenPlayerScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocBuilder<VideoPlayerBloc, VideoPlayerState>(
        builder: (context, state) {
          if (state.isCasting) {
            return CastControlView(item: state.mediaItem);
          }

          if (state.mediaItem == null) {
            return const LoadingIndicator();
          }

          final controller = context.read<PlayerService>().controller;
          final player = context.read<PlayerService>().player;

          return Stack(
            fit: StackFit.expand,
            children: [
              Center(
                child: Video(controller: controller, controls: NoVideoControls),
              ),
              VideoControlsOverlay(
                player: player,
                title: state.mediaItem!.name,
                isFullscreen: true,
                onFullscreenToggle: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
