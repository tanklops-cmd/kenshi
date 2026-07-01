import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kendo_companion/src/app/app.dart';
import 'package:kendo_companion/src/core/database/app_database.dart';
import 'package:kendo_companion/src/core/splash/splash_screen.dart';
import 'package:kendo_companion/src/core/theme/app_theme.dart';
import 'package:media_kit/media_kit.dart';
import 'package:sqflite/sqflite.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  final database = await openAppDatabase();

  runApp(_AppEntry(database: database));
}

/// Renders a refined splash screen, then hands off to [KendoCompanionApp].
///
/// Tests bypass this entirely by constructing [KendoCompanionApp] directly
/// inside a [ProviderScope], leaving the splash invisible to the test suite.
class _AppEntry extends StatefulWidget {
  const _AppEntry({required this.database});

  final Database database;

  @override
  State<_AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<_AppEntry> {
  bool _splashDone = false;

  void _onSplashComplete() {
    setState(() => _splashDone = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_splashDone) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        home: SplashScreen(onComplete: _onSplashComplete),
      );
    }

    return ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(widget.database)],
      child: const KendoCompanionApp(),
    );
  }
}

