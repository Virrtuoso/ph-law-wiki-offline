import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/hierarchy_node.dart';
import '../providers/article_providers.dart';
import '../providers/law_providers.dart';

class LawBrowseScreen extends ConsumerWidget {
  const LawBrowseScreen({super.key, required this.lawId});

  final String lawId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lawAsync = ref.watch(lawByIdProvider(lawId));
    final topNodesAsync = ref.watch(
      childNodesProvider(ChildNodesParams(lawId, null)),
    );
    final rootArticlesAsync = ref.watch(articlesForLawProvider(lawId));

    return Scaffold(
      appBar: AppBar(
        title: lawAsync.when(
          data: (law) => Text(law?.code ?? 'Law'),
          loading: () => const Text('Loading…'),
          error: (_, __) => const Text('Law'),
        ),
      ),
      body: lawAsync.when(
        data: (law) {
          if (law == null) {
            return const Center(child: Text('Law not found.'));
          }
          return ListView(
            padding: const EdgeInsets.all(8),
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  law.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              // Articles directly attached to the law (e.g. a Preamble)
              // with no parent hierarchy node.
              rootArticlesAsync.when(
                data: (articles) {
                  final rootOnly = articles
                      .where((a) => a.nodeId == null)
                      .toList();
                  return Column(
                    children: rootOnly.map((a) {
                      return ListTile(
                        leading: const Icon(Icons.description_outlined),
                        title: Text(
                          a.title != null
                              ? '${a.articleNumber}: ${a.title}'
                              : a.articleNumber,
                        ),
                        onTap: () => context.push('/article/${a.id}'),
                      );
                    }).toList(),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              topNodesAsync.when(
                data: (nodes) => Column(
                  children: nodes
                      .map((node) => _HierarchyNodeTile(lawId: lawId, node: node))
                      .toList(),
                ),
                loading: () => const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, stack) => Text('Failed to load: $error'),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

/// Recursively renders one hierarchy node as an expansion tile: child
/// nodes are shown first, followed by any articles attached directly to
/// this node.
class _HierarchyNodeTile extends ConsumerWidget {
  const _HierarchyNodeTile({required this.lawId, required this.node});

  final String lawId;
  final HierarchyNode node;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childNodesAsync = ref.watch(
      childNodesProvider(ChildNodesParams(lawId, node.id)),
    );
    final articlesAsync = ref.watch(articlesForNodeProvider(node.id));

    return ExpansionTile(
      key: PageStorageKey('node-${node.id}'),
      title: Text('${node.type} ${node.number}: ${node.title}'),
      children: [
        childNodesAsync.when(
          data: (children) => Column(
            children: children
                .map((c) => _HierarchyNodeTile(lawId: lawId, node: c))
                .toList(),
          ),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
        articlesAsync.when(
          data: (articles) => Column(
            children: articles.map((a) {
              return ListTile(
                contentPadding: const EdgeInsets.only(left: 32, right: 16),
                leading: const Icon(Icons.description_outlined),
                title: Text(
                  a.title != null
                      ? '${a.articleNumber}: ${a.title}'
                      : a.articleNumber,
                ),
                onTap: () => context.push('/article/${a.id}'),
              );
            }).toList(),
          ),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}
