import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/settings_provider.dart';

class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({super.key});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  final _pin1 = TextEditingController();
  final _pin2 = TextEditingController();

  @override
  void dispose() {
    _pin1.dispose();
    _pin2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        title: const Text('Definir PIN'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Elige un PIN de 4 dígitos.\nLo pediremos al abrir la app.',
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 24),
            _PinField(controller: _pin1, label: 'PIN'),
            const SizedBox(height: 12),
            _PinField(controller: _pin2, label: 'Confirmar PIN'),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_pin1.text.length != 4) return _err('El PIN debe tener 4 dígitos');
    if (_pin1.text != _pin2.text) return _err('Los PIN no coinciden');
    await context.read<SettingsProvider>().setPin(_pin1.text);
    if (mounted) Navigator.of(context).pop();
  }

  void _err(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
}

class _PinField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  const _PinField({required this.controller, required this.label});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLength: 4,
      keyboardType: TextInputType.number,
      obscureText: true,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: const TextStyle(fontSize: 24, letterSpacing: 12, fontWeight: FontWeight.w700),
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        labelText: label,
        counterText: '',
      ),
    );
  }
}

class PinLockScreen extends StatefulWidget {
  final String expected;
  const PinLockScreen({super.key, required this.expected});

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  final _ctrl = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_rounded, size: 96, color: scheme.primary),
              const SizedBox(height: 24),
              const Text(
                'Ingresa tu PIN',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _ctrl,
                autofocus: true,
                maxLength: 4,
                keyboardType: TextInputType.number,
                obscureText: true,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(
                    fontSize: 28, letterSpacing: 16, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
                decoration: const InputDecoration(counterText: ''),
                onChanged: (v) {
                  if (v.length == 4) _check(v);
                },
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: TextStyle(color: scheme.error)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _check(String v) {
    if (v == widget.expected) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _error = 'PIN incorrecto');
      _ctrl.clear();
    }
  }
}
