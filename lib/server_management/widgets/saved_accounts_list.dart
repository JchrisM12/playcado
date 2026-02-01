import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playcado/auth/bloc/auth_bloc.dart';
import 'package:playcado/auth_repository/models/server_credentials.dart';
import 'package:playcado/core/extensions.dart';

class SavedAccountsList extends StatelessWidget {
  final List<ServerCredentials> accounts;

  const SavedAccountsList({super.key, required this.accounts});

  @override
  Widget build(BuildContext context) {
    if (accounts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.savedAccounts,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 10),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: accounts.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final account = accounts[index];
            return Card(
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  child: Text(
                    account.username.isNotEmpty
                        ? account.username[0].toUpperCase()
                        : 'U',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                title: Text(account.username),
                subtitle: Text(account.serverName),
                trailing: _buildActionsMenu(context, account),
                onTap: () {
                  context.read<AuthBloc>().add(
                    AuthSwitchAccountRequested(account),
                  );
                },
              ),
            );
          },
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(context.l10n.orAddNewServer.toUpperCase()),
            ),
            Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildActionsMenu(BuildContext context, ServerCredentials account) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        context.read<AuthBloc>().add(AuthRemoveAccountRequested(account.id));
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: 20),
              SizedBox(width: 12),
              Text(context.l10n.delete),
            ],
          ),
        ),
      ],
    );
  }
}
