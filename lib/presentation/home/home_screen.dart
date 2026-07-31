import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/law_providers.dart';
import '../widgets/law_card.dart';
import '../widgets/offline_badge.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lawsAsync = ref.watch(lawsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('PH Law Wiki (Offline)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Philippine Law Reference',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const OfflineBadge(),
              ],
            ),
            const SizedBox(height: 16),
            _SearchBarEntry(
              onSubmitted: (query) {
                context.push('/search', extra: query);
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Browse laws',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            lawsAsync.when(
              data: (laws) {
                if (laws.isEmpty) {
                  return const Text('No laws available yet.');
                }
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.1,
                      ),
                  itemCount: laws.length,
                  itemBuilder: (context, index) {
                    final law = laws[index];
                    return LawCard(
                      law: law,
                      onTap: () => context.push('/law/${law.id}'),
                    );
                  },
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('Failed to load laws: $error'),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _QuickAction(
                  icon: Icons.bookmark_outline,
                  label: 'Bookmarks',
                  onTap: () => context.push('/bookmarks'),
                ),
                _QuickAction(
                  icon: Icons.note_outlined,
                  label: 'Notes',
                  onTap: () => context.push('/notes'),
                ),
                _QuickAction(
                  icon: Icons.info_outline,
                  label: 'About',
                  onTap: () => context.push('/about'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBarEntry extends StatefulWidget {
  const _SearchBarEntry({required this.onSubmitted});

  final ValueChanged<String> onSubmitted;

  @override
  State<_SearchBarEntry> createState() => _SearchBarEntryState();
}

class _SearchBarEntryState extends State<_SearchBarEntry> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: const ValueKey('home-search-field'),
      controller: _controller,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search laws, articles, or keywords…',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
      ),
      onSubmitted: widget.onSubmitted,
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
