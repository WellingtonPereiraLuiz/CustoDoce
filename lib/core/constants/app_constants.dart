

class AppConstants {
  static const String appName = 'CustoDoce';
  // Limites de plano agora em: lib/core/models/subscription_plan.dart (PlanLimits)
  static const String revenueCatApiKey = String.fromEnvironment('REVENUECAT_API_KEY');
  static const String revenueCatProEntitlement = 'pro';

  // GoRouter paths
  static const String homeRoute = '/';
  static const String ingredientManagerRoute = '/ingredients';
  static const String recipeBuilderRoute = '/recipe-builder';
  static const String recipeEditRoute = '/recipe-builder/:id';
  static const String paywallRoute = '/paywall';
  static const String settingsRoute = '/settings';
  static const String equipmentRoute = '/equipment';
  static const String dashboardRoute = '/dashboard';
  static const String menuRoute = '/menu';
}
