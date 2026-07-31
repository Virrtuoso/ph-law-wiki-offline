import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'presentation/about/about_screen.dart';
import 'presentation/bookmarks/bookmarks_screen.dart';
import 'presentation/browse/law_browse_screen.dart';
import 'presentation/home/home_screen.dart';
import 'presentation/notes/notes_screen.dart';
import 'presentation/providers/repository_providers.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/reader/article_reader_screen.dart';
import 'presentation/search/search_screen.dart';
import 'presentation/settings/settings_screen.dart';

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/search',
      builder: (context, state) =>
          SearchScreen(initialQuery: state.extra as String?),
    ),
    GoRoute(
      path: '/law/:lawId',
      builder: (context, state) =>
          LawBrowseScreen(lawId: state.pathParameters['lawId']!),
    ),
    GoRoute(
      path: '/article/:articleId',
      builder: (context, state) => ArticleReaderScreen(
        articleId: state.pathParameters['articleId']!,
      ),
    ),
    GoRoute(
      path: '/bookmarks',
      builder: (context, state) => const BookmarksScreen(),
    ),
    GoRoute(path: '/notes', builder: (context, state) => const NotesScreen()),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(path: '/about', builder: (context, state) => const AboutScreen()),
  ],
);

/// Root application widget: configures theming (light/dark, driven by
/// [settingsProvider]) and go_router-based navigation. Every routed page
/// is wrapped by [_AppInitGate], which blocks rendering behind database
/// initialization/seeding so no screen ever queries an unseeded database.
class PhLawWikiApp extends ConsumerWidget {
  const PhLawWikiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp.router(
      title: 'PH Law Wiki (Offline)',
      debugShowCheckedModeBanner: false,
      themeMode: settings.themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      routerConfig: _router,
      builder: (context, child) => _AppInitGate(child: child),
    );
  }
}

/// Blocks the routed [child] behind [appInitProvider], showing a splash
/// screen while the database opens/seeds and an error screen if that
/// fails.
class _AppInitGate extends ConsumerWidget {
  const _AppInitGate({required this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initAsync = ref.watch(appInitProvider);
    return initAsync.when(
      data: (_) => child ?? const SizedBox.shrink(),
      loading: () => const _SplashScreen(),
      error: (error, stack) => _ErrorScreen(error: error),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading offline law database…'),
          ],
        ),
      ),
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Failed to initialize the app: $error'),
        ),
      ),
    );
  }
}
