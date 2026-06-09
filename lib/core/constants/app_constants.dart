import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  static const String appName = 'CustoDoce';
  static const int freeRecipeLimit = 3;
  static final String revenueCatApiKey = dotenv.env['REVENUECAT_API_KEY'] ?? '';
  static const String revenueCatProEntitlement = 'pro';
  static final String supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  static final String supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  // GoRouter paths
  static const String homeRoute = '/';
  static const String ingredientManagerRoute = '/ingredients';
  static const String recipeBuilderRoute = '/recipe-builder';
  static const String recipeEditRoute = '/recipe-builder/:id';
  static const String paywallRoute = '/paywall';
  static const String settingsRoute = '/settings';
}
