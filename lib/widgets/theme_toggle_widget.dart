import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/theme_provider.dart';

class ThemeToggleWidget extends ConsumerWidget {
  const ThemeToggleWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;

    return SwitchListTile(
      title: const Text('Dark Mode'),
      subtitle: Text(isDarkMode ? 'Enabled' : 'Disabled'),
      value: isDarkMode,
      onChanged: (value) {
        ref.read(themeModeProvider.notifier).toggleTheme();
      },
      secondary: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
    );
  }
}

class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;

    return IconButton(
      icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
      onPressed: () {
        ref.read(themeModeProvider.notifier).toggleTheme();
      },
      tooltip: isDarkMode ? 'Light Mode' : 'Dark Mode',
    );
  }
}
