import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/formatters.dart';
import '../../models/account.dart';
import '../../providers/account_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/transaction_provider.dart';
import 'account_edit_screen.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final accs = context.watch<AccountProvider>();
    final tx = context.watch<TransactionProvider>();
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cuentas'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AccountEditScreen()),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nueva cuenta'),
      ),
      body: accs.all.isEmpty
          ? const Center(child: Text('Aún no tienes cuentas.'))
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: accs.all.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final a = accs.all[i];
                final balance = a.initialBalance + tx.balanceAllTime(accountId: a.id);
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        color: Color(a.colorValue),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        IconData(a.iconCode, fontFamily: 'MaterialIcons'),
                        color: Colors.white,
                      ),
                    ),
                    title: Text(a.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(
                      'Saldo: ${formatMoney(balance, code: settings.currency)}',
                      style: const TextStyle(fontSize: 13),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => AccountEditScreen(editing: a)),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
