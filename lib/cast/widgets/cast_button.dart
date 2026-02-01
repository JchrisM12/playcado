import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chrome_cast/flutter_chrome_cast.dart';

import 'package:playcado/cast/services/cast_service.dart';
import 'package:playcado/cast/widgets/cast_dialog.dart';

class CastButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const CastButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final castService = context.read<CastService>();

    return StreamBuilder<GoogleCastSession?>(
      stream: castService.currentSessionStream,
      initialData: castService.currentSession,
      builder: (context, snapshot) {
        final isConnected =
            snapshot.data?.connectionState == GoogleCastConnectState.connected;

        return IconButton(
          style: IconButton.styleFrom(
            backgroundColor: Colors.black.withValues(alpha: 0.4),
            foregroundColor: isConnected ? Colors.blue : Colors.white,
          ),
          icon: Icon(isConnected ? Icons.cast_connected : Icons.cast),
          tooltip: isConnected ? 'Cast Connected' : 'Cast',
          onPressed:
              onPressed ??
              () {
                showDialog(
                  context: context,
                  builder: (context) => const CastDeviceListDialog(),
                );
              },
        );
      },
    );
  }
}
