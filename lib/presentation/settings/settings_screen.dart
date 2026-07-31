import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/repositories/i_update_service.dart';
import '../providers/settings_provider.dart';
import '../providers/update_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final updateState = ref.watch(updateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Appearance', style: Theme.of(context).textTheme.titleMedium),
          SwitchListTile(
            key: const ValueKey('dark-mode-switch'),
            title: const Text('Dark mode'),
            value: settings.darkMode,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).setDarkMode(value);
            },
          ),
          ListTile(
            title: const Text('Font size'),
            subtitle: Slider(
              key: const ValueKey('font-size-slider'),
              value: settings.fontSize,
              min: kMinFontSize,
              max: kMaxFontSize,
              divisions: ((kMaxFontSize - kMinFontSize) / 1).round(),
              label: settings.fontSize.round().toString(),
              onChanged: (value) {
                ref.read(settingsProvider.notifier).setFontSize(value);
              },
            ),
          ),
          const Divider(height: 32),
          Text('Dataset', style: Theme.of(context).textTheme.titleMedium),
          ListTile(
            leading: const Icon(Icons.storage_outlined),
            title: const Text('Dataset version'),
            subtitle: Text(updateState.datasetVersion),
          ),
          ListTile(
            leading: const Icon(Icons.schedule_outlined),
            title: const Text('Last updated'),
            subtitle: Text(
              updateState.lastUpdatedAt != null
                  ? DateFormat.yMMMd().add_jm().format(
                      updateState.lastUpdatedAt!,
                    )
                  : 'Never',
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FilledButton.icon(
              key: const ValueKey('check-updates-button'),
              icon: updateState.isChecking
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.system_update_outlined),
              label: const Text('Check for updates'),
              onPressed: updateState.isChecking
                  ? null
                  : () => ref.read(updateProvider.notifier).checkForUpdates(),
            ),
          ),
          if (updateState.lastResult != null) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                updateState.lastResult!.message ??
                    (updateState.lastResult!.status ==
                            UpdateCheckStatus.upToDate
                        ? 'You are up to date.'
                        : 'An update is available.'),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
