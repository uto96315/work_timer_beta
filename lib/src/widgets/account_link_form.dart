import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/firebase_providers.dart';
import 'settings_ui.dart';

/// Lets an anonymously-signed-in user optionally attach an email/password,
/// so they can sign back in from another device without losing their data.
/// Once linked, shows the attached email instead of the form.
class AccountLinkForm extends ConsumerStatefulWidget {
  const AccountLinkForm({super.key});

  @override
  ConsumerState<AccountLinkForm> createState() => _AccountLinkFormState();
}

class _AccountLinkFormState extends ConsumerState<AccountLinkForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? get _linkedEmail {
    final user = ref.watch(firebaseAuthProvider).currentUser;
    if (user == null) return null;
    for (final info in user.providerData) {
      if (info.providerId == 'password') return info.email;
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final auth = ref.read(firebaseAuthProvider);
      final credential = EmailAuthProvider.credential(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      await auth.currentUser!.linkWithCredential(credential);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('登録しました')));
        setState(() {});
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = _messageFor(e.code));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String _messageFor(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'このメールアドレスは既に使われています';
      case 'invalid-email':
        return 'メールアドレスの形式が正しくありません';
      case 'weak-password':
        return 'パスワードは6文字以上にしてください';
      default:
        return '登録に失敗しました（$code）';
    }
  }

  @override
  Widget build(BuildContext context) {
    final linkedEmail = _linkedEmail;
    final scheme = Theme.of(context).colorScheme;

    if (linkedEmail != null) {
      return SettingsSection(
        icon: Icons.person_outline,
        title: 'アカウント',
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.check_circle_rounded, color: scheme.primary),
            title: const Text('メールアドレス登録済み'),
            subtitle: Text(linkedEmail),
          ),
        ],
      );
    }

    return SettingsSection(
      icon: Icons.person_outline,
      title: 'アカウント',
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'メールアドレスとパスワードを登録すると、機種変更時にデータを引き継げます（任意）',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'メールアドレス'),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (v) =>
                    (v == null || !v.contains('@')) ? '正しいメールアドレスを入力してください' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'パスワード（6文字以上）',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                validator: (v) => (v == null || v.length < 6) ? '6文字以上で入力してください' : null,
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 10),
                Text(_errorMessage!, style: TextStyle(color: scheme.error)),
              ],
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('登録する'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
