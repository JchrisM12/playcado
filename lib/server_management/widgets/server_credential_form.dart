import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playcado/auth/bloc/auth_bloc.dart';
import 'package:playcado/core/extensions.dart';
import 'package:playcado/server_management/bloc/server_management_bloc.dart';
import 'package:playcado/widgets/loading_indicator.dart';

class ServerCredentialForm extends StatefulWidget {
  final ServerManagementState initialState;

  const ServerCredentialForm({super.key, required this.initialState});

  @override
  State<ServerCredentialForm> createState() => _ServerCredentialFormState();
}

class _ServerCredentialFormState extends State<ServerCredentialForm> {
  late final TextEditingController _serverCtrl;
  late final TextEditingController _userCtrl;
  late final TextEditingController _passCtrl;
  bool _rememberCredentials = true;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _serverCtrl = TextEditingController(text: widget.initialState.serverUrl);
    _userCtrl = TextEditingController(text: widget.initialState.username);
    _passCtrl = TextEditingController(text: widget.initialState.password);
  }

  @override
  void didUpdateWidget(covariant ServerCredentialForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync text controllers with state from Bloc
    if (widget.initialState != oldWidget.initialState) {
      if (_serverCtrl.text != widget.initialState.serverUrl) {
        _serverCtrl.text = widget.initialState.serverUrl;
      }
      if (_userCtrl.text != widget.initialState.username) {
        _userCtrl.text = widget.initialState.username;
      }
      if (_passCtrl.text != widget.initialState.password) {
        _passCtrl.text = widget.initialState.password;
      }
    }
  }

  @override
  void dispose() {
    _serverCtrl.dispose();
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _onLogin() {
    context.read<AuthBloc>().add(
      AuthLoginRequested(
        _serverCtrl.text,
        _userCtrl.text,
        _passCtrl.text,
        rememberCredentials: _rememberCredentials,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authLoading = context.watch<AuthBloc>().state.user.isLoading;

    return Column(
      children: [
        TextField(
          controller: _serverCtrl,
          enabled: !authLoading,
          autocorrect: false,
          keyboardType: TextInputType.url,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: context.l10n.serverUrlLabel,
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.dns),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _userCtrl,
          enabled: !authLoading,
          autocorrect: false,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: context.l10n.username,
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.person),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passCtrl,
          enabled: !authLoading,
          obscureText: _obscurePassword,
          autocorrect: false,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _onLogin(),
          decoration: InputDecoration(
            labelText: context.l10n.password,
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: authLoading
                  ? null
                  : () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Checkbox(
              value: _rememberCredentials,
              onChanged: authLoading
                  ? null
                  : (value) {
                      setState(() {
                        _rememberCredentials = value ?? false;
                      });
                    },
            ),
            Text(context.l10n.rememberCredentials),
          ],
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
          ),
          onPressed: authLoading ? null : _onLogin,
          child: authLoading
              ? const LoadingIndicator(size: 20)
              : Text(context.l10n.login),
        ),
      ],
    );
  }
}
