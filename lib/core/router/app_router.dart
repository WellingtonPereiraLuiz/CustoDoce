import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:custo_doce/core/constants/app_constants.dart';
import 'package:custo_doce/core/providers/auth_provider.dart';
import 'package:custo_doce/core/providers/guest_mode_provider.dart';
import 'package:custo_doce/core/providers/subscription_provider.dart';
import 'package:custo_doce/core/router/route_guard_feedback.dart';
import 'package:custo_doce/presentation/screens/home/home_screen.dart';
import 'package:custo_doce/presentation/screens/recipe/recipe_detail_screen.dart';
import 'package:custo_doce/presentation/screens/ingredient_manager/ingredient_manager_screen.dart';
import 'package:custo_doce/presentation/screens/recipe_builder/recipe_builder_screen.dart';
import 'package:custo_doce/presentation/screens/paywall/paywall_screen.dart';
import 'package:custo_doce/presentation/screens/settings/settings_screen.dart';
import 'package:custo_doce/presentation/screens/auth/login_screen.dart';
import 'package:custo_doce/presentation/screens/main/main_scaffold.dart';
import 'package:custo_doce/presentation/screens/splash/splash_screen.dart';
import 'package:custo_doce/presentation/screens/digital_menu/digital_menu_screen.dart';
import 'package:custo_doce/presentation/screens/recipe/recipes_screen.dart';
import 'package:custo_doce/presentation/screens/auth/register_screen.dart';
import 'package:custo_doce/presentation/screens/ai_chat/ai_chat_screen.dart';
import 'package:custo_doce/presentation/providers/recipe_providers.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final user = ref.watch(currentUserProvider);
  final isGuest = ref.watch(guestModeProvider);
  final currentPlan = ref.watch(currentPlanProvider);
  final recipes = ref.watch(recipesProvider).valueOrNull ?? const [];
  final isAuthenticated = user != null && !isGuest;

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final location = state.uri.path;
      final isAuthPage = location == '/login' || location == '/register';

      if (isAuthPage && (isAuthenticated || isGuest)) {
        return '/home';
      }

      if (location == AppConstants.paywallRoute && !isAuthenticated) {
        return _guardRedirect(
          path: '/login',
          guard: 'auth',
          feature: 'a tela de planos',
          redirectTo: state.uri.toString(),
        );
      }

      final planProtectedRoutes = <String, ({String feature, String requiredPlan, bool hasAccess})>{
        AppConstants.menuRoute: (
          feature: 'Cardápio digital',
          requiredPlan: 'Pro',
          hasAccess: currentPlan.hasDigitalMenu,
        ),
        '/ai-chat': (
          feature: 'Assistente IA',
          requiredPlan: 'Premium',
          hasAccess: currentPlan.hasChatAi,
        ),
      };

      final protectedRoute = planProtectedRoutes[location];
      if (protectedRoute != null) {
        if (!isAuthenticated) {
          return _guardRedirect(
            path: '/login',
            guard: 'auth',
            feature: protectedRoute.feature,
            redirectTo: state.uri.toString(),
          );
        }

        if (!protectedRoute.hasAccess) {
          return _guardRedirect(
            path: '/home',
            guard: 'plan',
            feature: protectedRoute.feature,
            requiredPlan: protectedRoute.requiredPlan,
          );
        }
      }

      final isCreatingRecipe = location == AppConstants.recipeBuilderRoute;
      final reachedFreeRecipeLimit =
          !currentPlan.isUnlimitedRecipes && recipes.length >= currentPlan.recipeLimit;
      if (isCreatingRecipe && reachedFreeRecipeLimit) {
        return _guardRedirect(
          path: '/home',
          guard: 'plan',
          feature: 'Criar novas receitas',
          requiredPlan: 'Light ou superior',
        );
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => RouteGuardFeedback.wrap(
          state: state,
          child: const SplashScreen(),
        ),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => RouteGuardFeedback.wrap(
          state: state,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => RouteGuardFeedback.wrap(
          state: state,
          child: const RegisterScreen(),
        ),
      ),
      GoRoute(
        path: AppConstants.recipeBuilderRoute,
        name: 'recipe-builder',
        builder: (context, state) => RouteGuardFeedback.wrap(
          state: state,
          child: RecipeBuilderScreen(
            editRecipeId: state.extra as String?,
          ),
        ),
      ),
      GoRoute(
        path: '/ai-chat',
        name: 'ai-chat',
        builder: (context, state) => RouteGuardFeedback.wrap(
          state: state,
          child: const AiChatScreen(),
        ),
      ),
      GoRoute(
        path: AppConstants.recipeEditRoute,
        name: 'recipe-edit',
        builder: (context, state) {
          final recipeId = state.pathParameters['id']!;
          return RouteGuardFeedback.wrap(
            state: state,
            child: RecipeBuilderScreen(editRecipeId: recipeId),
          );
        },
      ),
      GoRoute(
        path: '/recipe/:id',
        name: 'recipe-detail',
        builder: (context, state) {
          final recipeId = state.pathParameters['id']!;
          return RouteGuardFeedback.wrap(
            state: state,
            child: RecipeDetailScreen(recipeId: recipeId),
          );
        },
      ),
      GoRoute(
        path: AppConstants.paywallRoute,
        name: 'paywall',
        builder: (context, state) => RouteGuardFeedback.wrap(
          state: state,
          child: const PaywallScreen(),
        ),
      ),
      GoRoute(
        path: AppConstants.menuRoute,
        name: 'menu',
        builder: (context, state) => RouteGuardFeedback.wrap(
          state: state,
          child: const DigitalMenuScreen(),
        ),
      ),
      // Stateful shell route for bottom navigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return RouteGuardFeedback.wrap(
            state: state,
            child: MainScaffold(navigationShell: navigationShell),
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/recipes',
                name: 'recipes',
                builder: (context, state) => const RecipesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppConstants.ingredientManagerRoute,
                name: 'ingredients',
                builder: (context, state) => const IngredientManagerScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppConstants.settingsRoute,
                name: 'settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text(
          'Página não encontrada: ${state.error}',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
      ),
    ),
  );
});

String _guardRedirect({
  required String path,
  required String guard,
  String? feature,
  String? requiredPlan,
  String? redirectTo,
}) {
  final queryParameters = <String, String>{
    'guard': guard,
    if (feature != null) 'feature': feature,
    if (requiredPlan != null) 'requiredPlan': requiredPlan,
    if (redirectTo != null) 'redirect': redirectTo,
  };

  return Uri(path: path, queryParameters: queryParameters).toString();
}
