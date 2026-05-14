import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/settings_provider.dart';
import '../accounts/accounts_screen.dart';
import '../categories/categories_screen.dart';
import '../recurring/recurring_screen.dart';
import '../reminders/reminders_screen.dart';
import '../settings/settings_screen.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final scheme = Theme.of(context).colorScheme;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [scheme.primary, scheme.primary.withValues(alpha: 0.75)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    radius: 28,
                    child: Text(
                      settings.userName.isEmpty
                          ? '?'
                          : settings.userName.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Saldo',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Hola, ${settings.userName}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _entry(context, Icons.category_rounded, 'Categorías',
                      const CategoriesScreen()),
                  _entry(context, Icons.account_balance_wallet_rounded,
                      'Cuentas', const AccountsScreen()),
                  _entry(context, Icons.replay_circle_filled_rounded,
                      'Pagos habituales', const RecurringScreen()),
                  _entry(context, Icons.notifications_active_rounded,
                      'Recordatorios', const RemindersScreen()),
                  const Divider(),
                  _entry(context, Icons.settings_rounded, 'Ajustes',
                      const SettingsScreen()),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Saldo · v1.0.0',
                style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _entry(BuildContext context, IconData icon, String label, Widget screen) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      onTap: () {
        Navigator.of(context).pop();
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
      },
    );
  }
}
