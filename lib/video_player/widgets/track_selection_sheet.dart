import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:playcado/core/extensions.dart';

class TrackSelectionSheet extends StatefulWidget {
  final Player player;

  const TrackSelectionSheet({super.key, required this.player});

  @override
  State<TrackSelectionSheet> createState() => _TrackSelectionSheetState();
}

class _TrackSelectionSheetState extends State<TrackSelectionSheet> {
  @override
  Widget build(BuildContext context) {
    // We access tracks directly from state.
    // In a production app, wrapping this in a StreamBuilder listening to
    // widget.player.stream.tracks would be more reactive,
    // but looking at state is sufficient for the modal's lifespan.
    final tracks = widget.player.state.tracks;
    final audioTracks = tracks.audio;
    final subtitleTracks = tracks.subtitle;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              tabs: [
                Tab(text: context.l10n.audio),
                Tab(text: context.l10n.subtitles),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildTrackList(
                    context,
                    audioTracks,
                    widget.player.state.track.audio,
                    (track) async {
                      await widget.player.setAudioTrack(track);
                      setState(() {});
                    },
                  ),
                  _buildTrackList(
                    context,
                    subtitleTracks,
                    widget.player.state.track.subtitle,
                    (track) async {
                      await widget.player.setSubtitleTrack(track);
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackList(
    BuildContext context,
    List<dynamic> tracks,
    dynamic current,
    Function(dynamic) onSelect,
  ) {
    if (tracks.isEmpty) {
      return Center(child: Text(context.l10n.noTracksAvailable));
    }

    return ListView.builder(
      itemCount: tracks.length,
      itemBuilder: (context, index) {
        final track = tracks[index];
        final isSelected = track == current;

        // Friendly name logic
        String label = track.id == 'no' || track.id == 'auto'
            ? (track.id == 'no' ? context.l10n.off : context.l10n.auto)
            : '${track.language ?? context.l10n.unknown} ${track.title != null ? "(${track.title})" : ""}';

        return ListTile(
          title: Text(label),
          trailing: isSelected
              ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
              : null,
          onTap: () => onSelect(track),
        );
      },
    );
  }
}
