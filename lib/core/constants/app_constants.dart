class AppConstants {
  static const String appName = 'CustoDoce';
  static const int freeRecipeLimit = 3;
  static const String revenueCatApiKey = 'YOUR_REVENUECAT_API_KEY_HERE';
  static const String revenueCatProEntitlement = 'pro';
  static const String supabaseUrl = 'YOUR_SUPABASE_URL_HERE';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY_HERE';

  // GoRouter paths
  static const String homeRoute = '/';
  static const String ingredientManagerRoute = '/ingredients';
  static const String recipeBuilderRoute = '/recipe-builder';
  static const String recipeEditRoute = '/recipe-builder/:id';
  static const String paywallRoute = '/paywall';
  static const String settingsRoute = '/settings';
}
