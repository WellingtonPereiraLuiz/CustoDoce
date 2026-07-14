import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:custo_doce/core/providers/settings_provider.dart';
import 'package:custo_doce/core/router/app_router.dart';
import 'package:custo_doce/core/theme/app_theme.dart';
import 'package:custo_doce/data/local/database/database_helper.dart';
import 'package:custo_doce/core/services/subscription_service.dart';
import 'package:custo_doce/core/utils/seeder.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:custo_doce/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // .env é opcional: em builds via --dart-define-from-file=.env (web/CI)
  // o arquivo não é empacotado como asset, e as chaves já chegam via
  // String.fromEnvironment (ver AppConstants). dotenv é só um fallback
  // para desenvolvimento local com o arquivo presente no disco.
  await dotenv.load(fileName: '.env', isOptional: true);

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize local database
  await _initializeDatabase();

  // Initialize RevenueCat (placeholder - replace with real API key)
  await _initializeRevenueCat();

  // Seed database with fake data
  await seedDatabase();

  runApp(
    const ProviderScope(
      child: CustoDoceApp(),
    ),
  );
}

/// Initializes the SQLite database by accessing the singleton instance.
Future<void> _initializeDatabase() async {
  try {
    await DatabaseHelper.instance.database;
    debugPrint('✅ Database initialized successfully');
  } catch (e) {
    debugPrint('❌ Database initialization failed: $e');
  }
}

/// Placeholder for RevenueCat initialization.
Future<void> _initializeRevenueCat() async {
  try {
    final service = SubscriptionService();
    await service.init();
    debugPrint('✅ RevenueCat initialized successfully');
  } catch (e) {
    debugPrint('❌ RevenueCat initialization failed: $e');
  }
}

class CustoDoceApp extends ConsumerWidget {
  const CustoDoceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final settingsAsync = ref.watch(settingsProvider);

    // Default settings while loading
    final themeMode = settingsAsync.valueOrNull?.themeMode ?? ThemeMode.light;

    return MaterialApp.router(
      title: 'CustoDoce',
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,

      // Localization
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [
        Locale('pt', 'BR'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Router
      routerConfig: router,

      builder: (context, child) {
        return MediaQuery(
          // Prevent text scaling from breaking layouts
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.0),
          ),
          child: child!,
        );
      },
    );
  }
}
