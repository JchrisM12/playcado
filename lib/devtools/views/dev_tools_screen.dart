import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:playcado/auth/bloc/auth_bloc.dart';
import 'package:playcado/cast/services/cast_service.dart';
import 'package:playcado/cast/widgets/cast_dialog.dart';
import 'package:playcado/devtools/bloc/dev_tools_bloc.dart';
import 'package:playcado/downloads_repository/downloads_repository.dart';
import 'package:playcado/services/preferences_service.dart';
import 'package:playcado/services/secure_storage_service.dart';
import 'package:playcado/widgets/snackbar_helper.dart';

class DevToolsScreen extends StatelessWidget {
  const DevToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DevToolsBloc(
        preferencesService: context.read<PreferencesService>(),
        castService: context.read<CastService>(),
        downloadsRepository: context.read<DownloadsRepository>(),
        secureStorage: context.read<SecureStorageService>(),
      )..add(DevToolsInitialized()),
      child: const _DevToolsView(),
    );
  }
}

class _DevToolsView extends StatelessWidget {
  const _DevToolsView();

  void _showCastDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CastDeviceListDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dev Tools')),
      body: BlocListener<DevToolsBloc, DevToolsState>(
        listener: (context, state) {
          if (state.message != null && state.message!.isNotEmpty) {
            if (state.status == DevToolsStatus.error) {
              SnackbarHelper.showError(context, state.message!);
            } else if (state.status == DevToolsStatus.success) {
              SnackbarHelper.showSuccess(context, state.message!);
            } else {
              SnackbarHelper.showInfo(context, state.message!);
            }
          }
        },
        child: BlocBuilder<DevToolsBloc, DevToolsState>(
          builder: (context, state) {
            final isConnected = state.isCastConnected;

            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _DevToolButton(
                  title: 'Enable Demo Mode',
                  icon: Icons.personal_video,
                  color: Colors.blue,
                  onTap: () {
                    context.read<AuthBloc>().add(AuthDemoModeRequested());
                    context.go('/');
                  },
                ),
                const SizedBox(height: 16),
                _DevToolButton(
                  title: isConnected
                      ? 'Play "Big Buck Bunny" (Ready)'
                      : 'Cast "Big Buck Bunny" Test',
                  icon: isConnected ? Icons.play_arrow : Icons.cast,
                  color: isConnected ? Colors.green : null,
                  onTap: () {
                    if (isConnected) {
                      context.read<DevToolsBloc>().add(
                        DevToolsCastTestVideoRequested(),
                      );
                    } else {
                      _showCastDialog(context);
                    }
                  },
                ),
                const SizedBox(height: 16),
                if (isConnected) ...[
                  _DevToolButton(
                    title: 'Disconnect Session',
                    icon: Icons.cast_connected,
                    color: Theme.of(context).colorScheme.error,
                    onTap: () => context.read<DevToolsBloc>().add(
                      DevToolsDisconnectCastRequested(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                _DevToolButton(
                  title: 'Clear Secure Storage',
                  icon: Icons.delete_forever,
                  color: Colors.red,
                  onTap: () => context.read<DevToolsBloc>().add(
                    DevToolsClearSecureStorageRequested(),
                  ),
                ),
                const SizedBox(height: 16),
                _DevToolButton(
                  title: 'Clear App Preferences',
                  icon: Icons.delete_forever,
                  color: Colors.red,
                  onTap: () => context.read<DevToolsBloc>().add(
                    DevToolsClearPreferencesServiceRequested(),
                  ),
                ),
                const SizedBox(height: 16),
                _DevToolButton(
                  title: 'Clear Downloads Metadata',
                  icon: Icons.delete_forever,
                  color: Colors.red,
                  onTap: () => context.read<DevToolsBloc>().add(
                    DevToolsClearDownloadsDataRequested(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DevToolButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const _DevToolButton({
    required this.title,
    required this.icon,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        color ?? Theme.of(context).colorScheme.secondaryContainer;
    final foregroundColor = color != null
        ? Colors.white
        : Theme.of(context).colorScheme.onSecondaryContainer;

    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(title),
    );
  }
}
