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

GoRouter _createRouter() => GoRouter(
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

ThemeData _buildTheme(Brightness brightness) {
  final base = ColorScheme.fromSeed(
    seedColor: const Color(0xFF5B6CFF),
    brightness: brightness,
  );
  final scheme = base.copyWith(
    primary: brightness == Brightness.dark
        ? const Color(0xFF9AA5FF)
        : const Color(0xFF3F51B5),
    secondary: brightness == Brightness.dark
        ? const Color(0xFF80CBC4)
        : const Color(0xFF00897B),
    surface: brightness == Brightness.dark
        ? const Color(0xFF12141C)
        : base.surface,
  );

  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    brightness: brightness,
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: AppBarTheme(
      centerTitle: false,
      elevation: 0,
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      titleTextStyle: TextStyle(
        color: scheme.onSurface,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    ),
    dividerTheme: DividerThemeData(
      color: scheme.outlineVariant.withValues(alpha: 0.4),
    ),
    textTheme: ThemeData(
      brightness: brightness,
      colorScheme: scheme,
      useMaterial3: true,
    ).textTheme.apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    ),
  );
}

/// Root application widget: configures theming (light/dark, driven by
/// [settingsProvider]) and go_router-based navigation. Every routed page
/// is wrapped by [_AppInitGate], which blocks rendering behind database
/// initialization/seeding so no screen ever queries an unseeded database.
///
/// The [GoRouter] is created per app instance (not a module singleton) so
/// widget tests that mount multiple apps do not inherit a leftover route.
class PhLawWikiApp extends ConsumerStatefulWidget {
  const PhLawWikiApp({super.key});

  @override
  ConsumerState<PhLawWikiApp> createState() => _PhLawWikiAppState();
}

class _PhLawWikiAppState extends ConsumerState<PhLawWikiApp> {
  late final GoRouter _router = _createRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp.router(
      title: 'PH Law Wiki (Offline)',
      debugShowCheckedModeBanner: false,
      themeMode: settings.themeMode,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
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
