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

  InputDecoration _decoration(String label, IconData icon, {Widget? suffixIcon}) => InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.white70),
        suffixIcon: suffixIcon,
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Brand gradient + scattered translucent music glyphs, echoing
          // splash_screen.dart, so sign-in feels like part of the same app
          // rather than a bare form dropped on a white screen.
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF06543), Color(0xFFEF8A6F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          const _MusicGlyphBackdrop(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.15),
                          border: Border.all(color: Colors.white.withOpacity(0.4)),
                        ),
                        child: const Icon(Icons.headphones, color: Colors.white, size: 40),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'UMVA',
                        style: headingStyle(context).copyWith(color: Colors.white, fontSize: 30, letterSpacing: 2),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isSignUp ? 'Create an account to keep listening' : 'Sign in to keep listening',
                        style: captionStyle(context).copyWith(color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 28),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withOpacity(0.25)),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_isSignUp) ...[
                                TextFormField(
                                  controller: _nameController,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: _decoration('Name', Icons.person_outline),
                                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                                ),
                                const SizedBox(height: 16),
                              ],
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                style: const TextStyle(color: Colors.white),
                                decoration: _decoration('Email', Icons.email_outlined),
                                validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                style: const TextStyle(color: Colors.white),
                                decoration: _decoration(
                                  'Password',
                                  Icons.lock_outline,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                      color: Colors.white70,
                                    ),
                                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                  ),
                                ),
                                validator: (v) => (v == null || v.length < 8) ? 'At least 8 characters' : null,
                              ),
                              if (auth.error != null) ...[
                                const SizedBox(height: 16),
                                Text(
                                  auth.error!,
                                  style: const TextStyle(color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed: auth.isLoading ? null : _submit,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFFF06543),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: auth.isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFF06543)),
                                        )
                                      : Text(_isSignUp ? 'Create Account' : 'Sign In', style: const TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: auth.isLoading ? null : () => setState(() => _isSignUp = !_isSignUp),
                        child: Text(
                          _isSignUp ? 'Already have an account? Sign in' : "Don't have an account? Sign up",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Faint oversized music glyphs scattered behind the form - purely
/// decorative, gives the gradient some texture without needing a bundled
/// photo asset.
class _MusicGlyphBackdrop extends StatelessWidget {
  const _MusicGlyphBackdrop();

  @override
  Widget build(BuildContext context) {
    final glyphs = <_Glyph>[
      _Glyph(Icons.music_note, top: -30, left: -20, size: 160, angle: -0.3),
      _Glyph(Icons.graphic_eq, bottom: 40, right: -40, size: 200, angle: 0.15),
      _Glyph(Icons.album, top: 120, right: -50, size: 140, angle: 0.2),
      _Glyph(Icons.queue_music, bottom: -30, left: -30, size: 150, angle: -0.1),
    ];
    return IgnorePointer(
      child: Stack(
        children: glyphs
            .map((g) => Positioned(
                  top: g.top,
                  bottom: g.bottom,
                  left: g.left,
                  right: g.right,
                  child: Transform.rotate(
                    angle: g.angle,
                    child: Icon(g.icon, size: g.size, color: Colors.white.withOpacity(0.08)),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _Glyph {
  final IconData icon;
  final double? top, bottom, left, right;
  final double size;
  final double angle;
  _Glyph(this.icon, {this.top, this.bottom, this.left, this.right, required this.size, required this.angle});
}
