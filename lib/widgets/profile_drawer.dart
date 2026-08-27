// lib/widgets/profile_drawer.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../theme/text_styles.dart';
import '../screens/auth/login_screen.dart';
import '../screens/overall_screen.dart' show selectedTabProvider;

class ProfileDrawer extends ConsumerWidget {
  const ProfileDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = auth.user;
    final theme = Theme.of(context);

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: theme.primaryColor,
                    child: Text(
                      user != null ? user.initials : '?',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user != null && user.name.isNotEmpty ? user.name : 'Guest',
                          style: subHeadingStyle(context),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (user != null)
                          Text(user.email, style: captionStyle(context), overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: Text('Settings', style: bodyStyle(context)),
              onTap: () {
                Navigator.pop(context);
                ref.read(selectedTabProvider.notifier).state = 2;
              },
            ),
            const Spacer(),
            const Divider(height: 1),
            if (auth.isSignedIn)
              ListTile(
                leading: const Icon(Icons.logout),
                title: Text('Sign Out', style: bodyStyle(context)),
                onTap: () {
                  Navigator.pop(context);
                  ref.read(authProvider.notifier).signOut();
                },
              )
            else
              ListTile(
                leading: const Icon(Icons.login),
                title: Text('Sign In', style: bodyStyle(context)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                },
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
