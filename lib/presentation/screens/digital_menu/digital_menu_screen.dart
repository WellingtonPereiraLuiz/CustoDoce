import 'package:custo_doce/core/enums/recipe_category.dart';
import 'package:custo_doce/core/providers/auth_provider.dart';
import 'package:custo_doce/core/providers/subscription_provider.dart';
import 'package:custo_doce/core/theme/app_theme.dart';
import 'package:custo_doce/presentation/providers/digital_menu_provider.dart';
import 'package:custo_doce/presentation/providers/recipe_providers.dart';
import 'package:custo_doce/presentation/widgets/locked_feature_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class DigitalMenuScreen extends ConsumerStatefulWidget {
  const DigitalMenuScreen({super.key});

  @override
  ConsumerState<DigitalMenuScreen> createState() => _DigitalMenuScreenState();
}

class _DigitalMenuScreenState extends ConsumerState<DigitalMenuScreen> {
  RecipeCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final plan = ref.watch(currentPlanProvider);
    if (!plan.hasDigitalMenu) {
      return const LockedFeatureScreen(
        featureName: 'Cardápio Digital',
        requiredPlan: 'Premium',
      );
    }

    final recipes = ref.watch(recipesProvider).value ?? [];
    final selectedRecipes = ref.watch(menuSelectionProvider);
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    
    final filteredRecipes = _selectedCategory == null 
        ? recipes 
        : recipes.where((r) => r.category == _selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cardápio Digital'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () => _copyLink(context, ref),
            tooltip: 'Copiar link',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildLinkCard(context, ref),
          const Divider(),
          _buildCategoryFilters(),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: filteredRecipes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final recipe = filteredRecipes[index];
                final isSelected = selectedRecipes.contains(recipe.id);
                return _RecipeMenuItem(
                  recipe: recipe,
                  isSelected: isSelected,
                  currencyFormat: currencyFormat,
                  onToggle: (val) {
                    final notifier = ref.read(menuSelectionProvider.notifier);
                    if (val) {
                      notifier.state = {...notifier.state, recipe.id};
                    } else {
                      notifier.state = {...notifier.state}..remove(recipe.id);
                    }
                  },
                );
              },
            ),
          ),
          _buildPreviewButton(context),
        ],
      ),
    );
  }

  Widget _buildLinkCard(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final userId = user?.uid ?? 'demo';
    final menuUrl = 'custodoce.app/menu/$userId';

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Link do Cardápio',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    menuUrl,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.copy_rounded, color: Theme.of(context).colorScheme.primary),
                  onPressed: () => _copyLink(context, ref),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: const Text('Todas'),
              selected: _selectedCategory == null,
              onSelected: (val) {
                if (val) setState(() => _selectedCategory = null);
              },
            ),
          ),
          ...RecipeCategory.values.map((cat) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(cat.label),
                selected: _selectedCategory == cat,
                onSelected: (val) {
                  setState(() => _selectedCategory = val ? cat : null);
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPreviewButton(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => _showMenuPreview(context),
            icon: const Icon(Icons.remove_red_eye_rounded),
            label: const Text('Visualizar Cardápio'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ),
    );
  }

  void _copyLink(BuildContext context, WidgetRef ref) async {
    final user = ref.read(currentUserProvider);
    final userId = user?.uid ?? 'demo';
    final menuUrl = 'custodoce.app/menu/$userId';

    await Clipboard.setData(ClipboardData(text: menuUrl));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Link copiado para a área de transferência!')),
      );
    }
  }

  void _showMenuPreview(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _MenuPreviewModal(),
    );
  }
}

class _RecipeMenuItem extends StatelessWidget {
  final dynamic recipe; // RecipeEntity
  final bool isSelected;
  final NumberFormat currencyFormat;
  final Function(bool) onToggle;

  const _RecipeMenuItem({
    required this.recipe,
    required this.isSelected,
    required this.currencyFormat,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected 
            ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected 
              ? Theme.of(context).colorScheme.primary 
              : Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: SwitchListTile(
        title: Text(recipe.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${recipe.category.label} • ${currencyFormat.format(recipe.suggestedSellPrice)}'),
        value: isSelected,
        onChanged: onToggle,
        activeColor: Theme.of(context).colorScheme.primary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}

class _MenuPreviewModal extends ConsumerWidget {
  const _MenuPreviewModal();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuRecipes = ref.watch(menuRecipesProvider);
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    
    // Agrupar receitas por categoria
    final groupedRecipes = <String, List<dynamic>>{};
    for (final r in menuRecipes) {
      final label = r.category.label;
      if (!groupedRecipes.containsKey(label)) {
        groupedRecipes[label] = [];
      }
      groupedRecipes[label]!.add(r);
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.surfaceContainerHighest,
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          Text('🍰 Nosso Cardápio', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
          const Divider(height: 32),
          if (menuRecipes.isEmpty)
            const Expanded(
              child: Center(
                child: Text('Nenhuma receita selecionada para o cardápio.\nVolte e ative algumas receitas!', textAlign: TextAlign.center),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: groupedRecipes.length,
                itemBuilder: (context, index) {
                  final category = groupedRecipes.keys.elementAt(index);
                  final items = groupedRecipes[category]!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          category,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                      ),
                      ...items.map((r) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(r.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text('Rendimento: ${r.yieldQuantity} un', style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color)),
                                ],
                              ),
                            ),
                            Text(
                              currencyFormat.format(r.suggestedSellPrice),
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.successColor),
                            ),
                          ],
                        ),
                      )),
                    ],
                  );
                },
              ),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Fechar Preview'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
