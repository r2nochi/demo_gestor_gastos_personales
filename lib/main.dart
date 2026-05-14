import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'providers/account_provider.dart';
import 'providers/category_provider.dart';
import 'providers/recurring_provider.dart';
import 'providers/reminder_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/transaction_provider.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/settings/pin_setup_screen.dart';
import 'screens/shell.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es', null);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));

  final settings = SettingsProvider();
  await settings.load();
  await NotificationService.instance.init();

  runApp(SaldoApp(settings: settings));
}

class SaldoApp extends StatelessWidget {
  final SettingsProvider settings;
  const SaldoApp({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider(create: (_) => CategoryProvider()..load()),
        ChangeNotifierProvider(create: (_) => AccountProvider()..load()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()..load()),
        ChangeNotifierProvider(create: (_) => RecurringProvider()..load()),
        ChangeNotifierProvider(create: (_) => ReminderProvider()..load()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, s, _) => MaterialApp(
          title: 'Saldo',
          debugShowCheckedModeBanner: false,
          theme: SaldoTheme.light(),
          darkTheme: SaldoTheme.dark(),
          themeMode: s.themeMode,
          locale: const Locale('es'),
          supportedLocales: const [Locale('es'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          home: !s.onboarded
              ? const OnboardingScreen()
              : (s.pin != null ? PinGate(pin: s.pin!) : const AppShell()),
        ),
      ),
    );
  }
}

class PinGate extends StatefulWidget {
  final String pin;
  const PinGate({super.key, required this.pin});

  @override
  State<PinGate> createState() => _PinGateState();
}

class _PinGateState extends State<PinGate> {
  bool _unlocked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showLock());
  }

  Future<void> _showLock() async {
    final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PinLockScreen(expected: widget.pin),
        fullscreenDialog: true,
      ),
    );
    if (ok == true && mounted) setState(() => _unlocked = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_unlocked) return const AppShell();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Icon(
          Icons.lock_rounded,
          size: 80,
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
    );
  }
}
