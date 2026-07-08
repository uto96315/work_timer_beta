import 'package:flutter/material.dart';

import 'register_screen.dart';
import 'workplace_setup_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/icon/wrtm_icon.png', width: 96, height: 96),
              const SizedBox(height: 24),
              Text(
                'かったるい仕事が\n少し楽しくなる。',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 48),
              FilledButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                ),
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                child: const Text('アカウント登録して始める'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const WorkplaceSetupScreen()),
                ),
                style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                child: const Text('登録せずに始める'),
              ),
              const SizedBox(height: 16),
              Text(
                '登録しなくてもすべての機能が使えます。\n後からいつでも登録できます。',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
