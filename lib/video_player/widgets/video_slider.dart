import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:playcado/core/formatters.dart';

class VideoSlider extends StatefulWidget {
  final Player player;
  final VoidCallback? onInteractionStart;
  final VoidCallback? onInteractionEnd;

  const VideoSlider({
    super.key,
    required this.player,
    this.onInteractionStart,
    this.onInteractionEnd,
  });

  @override
  State<VideoSlider> createState() => _VideoSliderState();
}

class _VideoSliderState extends State<VideoSlider> {
  // We use streams for high-frequency updates to avoid rebuilding the whole UI
  Stream<Duration> get _positionStream => widget.player.stream.position;
  Stream<Duration> get _durationStream => widget.player.stream.duration;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: _durationStream,
      initialData: widget.player.state.duration,
      builder: (context, durationSnapshot) {
        final totalDuration = durationSnapshot.data ?? Duration.zero;

        return StreamBuilder<Duration>(
          stream: _positionStream,
          initialData: widget.player.state.position,
          builder: (context, positionSnapshot) {
            final position = positionSnapshot.data ?? Duration.zero;
            final max = totalDuration.inMilliseconds.toDouble();
            final value = position.inMilliseconds.toDouble().clamp(0.0, max);

            return Row(
              children: [
                Text(
                  Formatters.formatTime(position),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 6,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 12,
                      ),
                      activeTrackColor: Theme.of(context).colorScheme.primary,
                      inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
                      thumbColor: Colors.white,
                    ),
                    child: Slider(
                      value: value,
                      min: 0.0,
                      max: max > 0 ? max : 1.0,
                      onChanged: (newValue) {
                        widget.onInteractionStart?.call();
                        widget.player.seek(
                          Duration(milliseconds: newValue.toInt()),
                        );
                      },
                      onChangeEnd: (_) {
                        widget.onInteractionEnd?.call();
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  Formatters.formatTime(totalDuration),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
