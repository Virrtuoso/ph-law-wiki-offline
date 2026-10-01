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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

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
        // Column (not ListView) so quick-actions below the law grid are always
        // built — ListView lazily omits off-screen children, which broke tests
        // and a11y that expect Bookmarks/Notes/About without scrolling.
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Philippine Law Reference',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Browse sample codes offline — information only.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  const OfflineBadge(),
                ],
              ),
              const SizedBox(height: 20),
              _SearchBarEntry(
                onSubmitted: (query) {
                  context.push('/search', extra: query);
                },
              ),
              const SizedBox(height: 22),
              Text(
                'Browse laws',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Open a code to explore articles and sections.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 14),
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
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 1.0,
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
              const SizedBox(height: 22),
              Text(
                'Library',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _QuickAction(
                      key: const ValueKey('quick-action-bookmarks'),
                      icon: Icons.bookmark_outline,
                      label: 'Bookmarks',
                      onTap: () => context.push('/bookmarks'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.note_outlined,
                      label: 'Notes',
                      onTap: () => context.push('/notes'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.info_outline,
                      label: 'About',
                      onTap: () => context.push('/about'),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Material(
      color: cs.surfaceContainerHighest.withValues(alpha: 0.65),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: TextField(
        key: const ValueKey('home-search-field'),
        controller: _controller,
        textInputAction: TextInputAction.search,
        style: theme.textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: 'Search laws, articles, or keywords…',
          hintStyle: theme.textTheme.bodyLarge?.copyWith(
            color: cs.onSurfaceVariant.withValues(alpha: 0.75),
          ),
          prefixIcon: Icon(Icons.search_rounded, color: cs.primary),
          suffixIcon: IconButton(
            tooltip: 'Search',
            icon: Icon(Icons.arrow_forward_rounded, color: cs.primary),
            onPressed: () => widget.onSubmitted(_controller.text),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 16,
          ),
        ),
        onSubmitted: widget.onSubmitted,
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Material(
      color: cs.surfaceContainerHighest.withValues(alpha: 0.55),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.45)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: cs.primary),
              const SizedBox(height: 6),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
