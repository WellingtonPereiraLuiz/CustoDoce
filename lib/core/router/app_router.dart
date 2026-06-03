import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:custo_doce/core/constants/app_constants.dart';
import 'package:custo_doce/presentation/screens/home/home_screen.dart';
import 'package:custo_doce/presentation/screens/ingredient_manager/ingredient_manager_screen.dart';
import 'package:custo_doce/presentation/screens/recipe_builder/recipe_builder_screen.dart';
import 'package:custo_doce/presentation/screens/paywall/paywall_screen.dart';
import 'package:custo_doce/presentation/screens/settings/settings_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppConstants.homeRoute,
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: AppConstants.homeRoute,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppConstants.ingredientManagerRoute,
        name: 'ingredients',
        builder: (context, state) => const IngredientManagerScreen(),
      ),
      GoRoute(
        path: AppConstants.recipeBuilderRoute,
        name: 'recipe-builder',
        builder: (context, state) => const RecipeBuilderScreen(),
      ),
      GoRoute(
        path: AppConstants.recipeEditRoute,
        name: 'recipe-edit',
        builder: (context, state) {
          final recipeId = state.pathParameters['id']!;
          return RecipeBuilderScreen(editRecipeId: recipeId);
        },
      ),
      GoRoute(
        path: AppConstants.paywallRoute,
        name: 'paywall',
        builder: (context, state) => const PaywallScreen(),
      ),
      GoRoute(
        path: AppConstants.settingsRoute,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text(
          'Página não encontrada: ${state.error}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    ),
  );
});
