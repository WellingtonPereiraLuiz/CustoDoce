import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:custo_doce/presentation/providers/recipe_providers.dart';
import 'package:custo_doce/core/providers/subscription_provider.dart';
import 'package:custo_doce/core/utils/plan_gate.dart';
import 'package:custo_doce/presentation/widgets/recipe_card_widget.dart';

class RecipesScreen extends ConsumerWidget {
  const RecipesScreen({super.key});

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, String recipeId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Receita?'),
        content: const Text('Essa ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Excluir',
                style: TextStyle(color: Theme.of(ctx).colorScheme.error)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(recipesProvider.notifier).deleteRecipe(recipeId);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipesAsync = ref.watch(recipesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Receitas'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: recipesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  Center(child: Text('Erro ao carregar receitas: $e')),
              data: (recipes) {
                if (recipes.isEmpty) {
                  return Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cake_rounded,
                              size: 64,
                              color: Theme.of(context).colorScheme.outline),
                          const SizedBox(height: 16),
                          Text('Nenhuma receita ainda',
                              style: Theme.of(context).textTheme.headlineSmall),
                        ]),
                  );
                }
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final crossAxisCount =
                        width >= 900 ? 3 : (width >= 600 ? 2 : 1);
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: 0.78,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                      ),
                      itemCount: recipes.length,
                      itemBuilder: (context, index) {
                        final recipe = recipes[index];
                        return RecipeCard(
                          recipe: recipe,
                          onTap: () => context.push('/recipe/${recipe.id}'),
                          onDelete: () =>
                              _confirmDelete(context, ref, recipe.id),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final plan = ref.read(currentPlanProvider);
          final recipes = ref.read(recipesProvider).value ?? [];
          final canCreate = PlanGate.checkLimit(
            context: context,
            ref: ref,
            currentCount: recipes.length,
            limit: plan.recipeLimit,
            featureName: 'receitas',
            planName: plan.name,
          );
          if (canCreate) context.push('/recipe-builder');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
