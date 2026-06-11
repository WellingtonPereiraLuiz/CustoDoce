

class AppConstants {
  static const String appName = 'CustoDoce';
  static const int freeRecipeLimit = 3;
  static const String revenueCatApiKey = String.fromEnvironment('REVENUECAT_API_KEY');
  static const String revenueCatProEntitlement = 'pro';

  // GoRouter paths
  static const String homeRoute = '/';
  static const String ingredientManagerRoute = '/ingredients';
  static const String recipeBuilderRoute = '/recipe-builder';
  static const String recipeEditRoute = '/recipe-builder/:id';
  static const String paywallRoute = '/paywall';
  static const String settingsRoute = '/settings';
}
