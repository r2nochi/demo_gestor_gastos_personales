import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/formatters.dart';
import '../../providers/account_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/transaction_provider.dart';
import 'accounts_screen.dart';

class AccountPicker extends StatelessWidget {
  const AccountPicker({super.key});

  @override
  Widget build(BuildContext context) {
    final accs = context.watch<AccountProvider>();
    final tx = context.watch<TransactionProvider>();
    final settings = context.watch<SettingsProvider>();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Text(
                'Cuentas',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
            for (final a in accs.all)
              ListTile(
                leading: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: Color(a.colorValue),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    IconData(a.iconCode, fontFamily: 'MaterialIcons'),
                    color: Colors.white,
                  ),
                ),
                title: Text(a.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                trailing: Text(
                  formatMoney(
                    a.initialBalance + tx.balanceAllTime(accountId: a.id),
                    code: settings.currency,
                  ),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                selected: a.id == accs.selectedId,
                onTap: () {
                  if (a.id != null) accs.select(a.id!);
                  Navigator.of(context).pop();
                },
              ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings_rounded),
              title: const Text('Administrar cuentas'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AccountsScreen()),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
