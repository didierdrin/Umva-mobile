// lib/screens/auth/login_screen.dart
//
// Single screen toggling between sign-in and sign-up, backed by
// providers/auth_provider.dart -> services/neon_auth_service.dart (the same
// Neon Auth / Better Auth endpoints umva-dashboard uses).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../theme/text_styles.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final notifier = ref.read(authProvider.notifier);
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final success = _isSignUp
        ? await notifier.signUp(name: _nameController.text.trim(), email: email, password: password)
        : await notifier.signIn(email: email, password: password);

    if (success && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: Text(_isSignUp ? 'Sign Up' : 'Sign In', style: headingStyle(context))),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (_isSignUp) ...[
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name', prefixIcon: Icon(Icons.person_outline)),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (v) => (v == null || v.length < 8) ? 'At least 8 characters' : null,
              ),
              if (auth.error != null) ...[
                const SizedBox(height: 16),
                Text(auth.error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: auth.isLoading ? null : _submit,
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                child: auth.isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(_isSignUp ? 'Create Account' : 'Sign In'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: auth.isLoading ? null : () => setState(() => _isSignUp = !_isSignUp),
                child: Text(_isSignUp ? 'Already have an account? Sign in' : "Don't have an account? Sign up"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
