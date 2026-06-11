import 'package:custo_doce/domain/entities/recipe_entity.dart';
import 'package:custo_doce/presentation/providers/recipe_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final menuSelectionProvider = StateProvider<Set<String>>((ref) => {});

final menuRecipesProvider = Provider<List<RecipeEntity>>((ref) {
  final recipes = ref.watch(recipesProvider).value ?? [];
  final selected = ref.watch(menuSelectionProvider);
  return recipes.where((r) => selected.contains(r.id)).toList();
});
