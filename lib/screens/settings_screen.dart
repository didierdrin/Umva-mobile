import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import '../theme/text_styles.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _suggestionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _suggestionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
      children: [
        Text('Preferences', style: subHeadingStyle(context)),
        SwitchListTile(
          title: Text('Dark Mode', style: bodyStyle(context)),
          value: isDark,
          onChanged: (value) => ref.read(themeProvider.notifier).toggleTheme(value),
        ),
        const SizedBox(height: 24),
        Text('Feedback', style: subHeadingStyle(context)),
        ListTile(
          leading: const Icon(Icons.bug_report),
          title: Text('Report a bug', style: bodyStyle(context)),
          onTap: () => _showDialog(context, 'Report a Bug'),
        ),
        ListTile(
          leading: const Icon(Icons.feedback),
          title: Text('Send feedback', style: bodyStyle(context)),
          onTap: () => _showDialog(context, 'Send Feedback'),
        ),
      ],
    );
  }

  void _showDialog(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: headingStyle(context)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(hintText: 'Name')),
            TextField(controller: _emailController, decoration: const InputDecoration(hintText: 'Email')),
            TextField(controller: _suggestionController, decoration: const InputDecoration(hintText: 'Message'), maxLines: 4),
          ],
        ),
        actions: [
          TextButton(onPressed: () { /* Send logic */ Navigator.pop(context); }, child: const Text('Send')),
          TextButton(onPressed: () {Navigator.pop(context);}, child: const Text('Cancel')),
        ],
      ),
    );
  }
}
