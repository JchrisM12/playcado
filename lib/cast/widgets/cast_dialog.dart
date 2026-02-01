import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chrome_cast/flutter_chrome_cast.dart';
import 'package:go_router/go_router.dart';
import 'package:playcado/cast/services/cast_service.dart';
import 'package:playcado/core/extensions.dart';
import 'package:playcado/media/models/media_item.dart';
import 'package:playcado/video_player/bloc/video_player_bloc.dart';
import 'package:playcado/widgets/snackbar_helper.dart';

class CastDeviceListDialog extends StatelessWidget {
  final Function(GoogleCastDevice)? onDeviceSelected;
  final MediaItem? autoPlayItem;

  const CastDeviceListDialog({
    super.key,
    this.onDeviceSelected,
    this.autoPlayItem,
  });

  @override
  Widget build(BuildContext context) {
    final castService = context.read<CastService>();
    final playerBloc = context.read<VideoPlayerBloc>();

    return StreamBuilder<GoogleCastSession?>(
      stream: castService.currentSessionStream,
      initialData: castService.currentSession,
      builder: (context, sessionSnapshot) {
        final currentSession = sessionSnapshot.data;
        // Use a combination of session and manager state for robustness
        final isConnected =
            castService.isConnected ||
            currentSession?.connectionState == GoogleCastConnectState.connected;
        final connectedDevice = currentSession?.device;

        return AlertDialog(
          title: Text(
            isConnected
                ? context.l10n.connectedTo(
                    connectedDevice?.friendlyName ?? context.l10n.unknown,
                  )
                : context.l10n.selectADevice,
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: StreamBuilder<List<GoogleCastDevice>>(
              stream: castService.devicesStream,
              initialData: const [],
              builder: (context, snapshot) {
                final devices = snapshot.data ?? [];
                if (devices.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(context.l10n.searchingForDevices),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: devices.length,
                  itemBuilder: (context, index) {
                    final device = devices[index];
                    final isCurrentDevice =
                        isConnected &&
                        device.deviceID == connectedDevice?.deviceID;

                    return ListTile(
                      leading: Icon(
                        Icons.tv,
                        color: isCurrentDevice ? Colors.blue : null,
                      ),
                      title: Text(
                        device.friendlyName,
                        style: TextStyle(
                          fontWeight: isCurrentDevice ? FontWeight.bold : null,
                        ),
                      ),
                      subtitle: Text(device.modelName ?? ''),
                      trailing: isCurrentDevice
                          ? const Icon(Icons.check, color: Colors.blue)
                          : null,
                      onTap: () {
                        if (onDeviceSelected != null) {
                          onDeviceSelected!(device);
                        } else {
                          // Close dialog first
                          context.pop();

                          if (autoPlayItem != null) {
                            // Trigger cast play in bloc which handles connection wait
                            playerBloc.add(
                              PlayerCastRequested(item: autoPlayItem!),
                            );
                          }

                          // Trigger connection (even if already connecting/connected, service handles it)
                          castService.connect(device);

                          SnackbarHelper.showInfo(
                            context,
                            context.l10n.connectingTo(device.friendlyName),
                          );
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            if (isConnected)
              TextButton(
                onPressed: () {
                  context.pop();
                  castService.disconnect();
                },
                child: Text(
                  context.l10n.stopCasting,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            TextButton(
              onPressed: () => context.pop(),
              child: Text(context.l10n.cancel),
            ),
          ],
        );
      },
    );
  }
}
