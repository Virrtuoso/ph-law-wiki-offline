import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/update_provider.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updateState = ref.watch(updateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'PH Law Wiki (Offline)',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text('Dataset version: ${updateState.datasetVersion}'),
          const SizedBox(height: 16),
          const Text(
            'This app provides an offline, searchable reference to a '
            'sample of Philippine legal texts, including excerpts of the '
            '1987 Constitution, the Civil Code of the Philippines, and the '
            'Flag and Heraldic Code. It works entirely without an internet '
            'connection once installed.',
          ),
          const SizedBox(height: 16),
          Card(
            color: Theme.of(context).colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_outlined,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Disclaimer: The content in this app is provided for '
                      'general informational purposes only and does not '
                      'constitute legal advice. Always consult a licensed '
                      'Philippine attorney or the Official Gazette for '
                      'authoritative, up-to-date legal texts.',
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Source attribution',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          const Text(
            'Legal texts are sourced from and cross-referenced against '
            'the Official Gazette of the Republic of the Philippines '
            '(officialgazette.gov.ph). See docs/data-ingestion-plan.md in '
            'the project repository for how future updates are sourced '
            'and verified.',
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            icon: const Icon(Icons.copy_outlined),
            label: const Text('Copy app version info'),
            onPressed: () {
              Clipboard.setData(
                ClipboardData(
                  text: 'PH Law Wiki (Offline) — dataset '
                      '${updateState.datasetVersion}',
                ),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied to clipboard.')),
              );
            },
          ),
        ],
      ),
    );
  }
}
