import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playcado/auth/bloc/auth_bloc.dart';
import 'package:playcado/auth_repository/auth_repository.dart';
import 'package:playcado/core/extensions.dart';
import 'package:playcado/l10n/app_localizations.dart';
import 'package:playcado/server_management/bloc/server_management_bloc.dart';
import 'package:playcado/server_management/widgets/saved_accounts_list.dart';
import 'package:playcado/server_management/widgets/server_credential_form.dart';
import 'package:playcado/services/secure_storage_service.dart';
import 'package:playcado/widgets/icon_title.dart';
import 'package:playcado/widgets/loading_indicator.dart';
import 'package:playcado/widgets/snackbar_helper.dart';

class ServerManagementScreen extends StatelessWidget {
  const ServerManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepo = context.read<AuthRepository>();
    final shouldLoadLastUsed = !authRepo.isLoggedIn;

    return BlocProvider(
      create: (context) => ServerManagementBloc(
        secureStorage: context.read<SecureStorageService>(),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: IconTitle(centerTitle: true, title: context.l10n.playcado),
        ),
        body: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            // Only handle errors here. Success redirect is handled by Router.
            if (state.user.isError) {
              SnackbarHelper.showError(
                context,
                context.l10n.loginFailedPleaseCheckYourCredentials,
              );
            }
          },
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              return SafeArea(
                top: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SavedAccountsList(accounts: authState.availableAccounts),
                      BlocBuilder<ServerManagementBloc, ServerManagementState>(
                        builder: (context, formState) {
                          if (formState.isLoading && shouldLoadLastUsed) {
                            return const LoadingIndicator();
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ServerCredentialForm(initialState: formState),
                              const SizedBox(height: 24),
                              const Divider(),
                              const SizedBox(height: 16),
                              OutlinedButton.icon(
                                onPressed: () {
                                  context.read<AuthBloc>().add(
                                    AuthEnterOfflineModeRequested(),
                                  );
                                },
                                icon: const Icon(Icons.download_rounded),
                                label: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.viewOfflineDownloads,
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 24,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
