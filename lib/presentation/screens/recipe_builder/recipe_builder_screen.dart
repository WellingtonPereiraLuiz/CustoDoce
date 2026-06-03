import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:custo_doce/core/theme/app_theme.dart';
import 'package:custo_doce/domain/entities/ingredient_entity.dart';
import 'package:custo_doce/presentation/providers/ingredient_providers.dart';
import 'package:custo_doce/presentation/providers/recipe_builder_provider.dart';
import 'package:custo_doce/presentation/providers/recipe_providers.dart';
import 'package:intl/intl.dart';

class RecipeBuilderScreen extends ConsumerStatefulWidget {
  final String? editRecipeId;
  const RecipeBuilderScreen({super.key, this.editRecipeId});

  @override
  ConsumerState<RecipeBuilderScreen> createState() => _RecipeBuilderScreenState();
}

class _RecipeBuilderScreenState extends ConsumerState<RecipeBuilderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _operationalCostCtrl = TextEditingController(text: '0');
  final _marginCtrl = TextEditingController(text: '0');
  final _qtyCtrl = TextEditingController();
  IngredientEntity? _selectedIngredient;
  bool _isSaving = false;

  final _currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(recipeBuilderProvider.notifier).reset();
      if (widget.editRecipeId != null) {
        _loadForEdit();
      }
    });
  }

  void _loadForEdit() {
    final recipes = ref.read(recipesProvider).valueOrNull ?? [];
    final recipe = recipes.where((r) => r.id == widget.editRecipeId).firstOrNull;
    if (recipe != null) {
      ref.read(recipeBuilderProvider.notifier).loadRecipeForEdit(recipe);
      _nameCtrl.text = recipe.name;
      _operationalCostCtrl.text = recipe.additionalOperationalCost.toString();
      _marginCtrl.text = recipe.profitMarginPercentage.toString();
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _operationalCostCtrl.dispose();
    _marginCtrl.dispose();
    _qtyCtrl.dispose();
    super.dispose();
  }

  void _addIngredient() {
    if (_selectedIngredient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um ingrediente')),
      );
      return;
    }
    final qty = double.tryParse(_qtyCtrl.text);
    if (qty == null || qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe uma quantidade válida')),
      );
      return;
    }
    ref.read(recipeBuilderProvider.notifier).addIngredient(_selectedIngredient!, qty);
    _qtyCtrl.clear();
    setState(() => _selectedIngredient = null);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final builderState = ref.read(recipeBuilderProvider);
    if (builderState.ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione pelo menos um ingrediente')),
      );
      return;
    }
    setState(() => _isSaving = true);
    final recipe = ref.read(recipeBuilderProvider.notifier).buildRecipeEntity();
    bool success;
    if (widget.editRecipeId != null) {
      await ref.read(recipesProvider.notifier).updateRecipe(recipe);
      success = true;
    } else {
      success = await ref.read(recipesProvider.notifier).saveRecipe(recipe);
    }
    setState(() => _isSaving = false);
    if (!mounted) return;
    if (success) {
      ref.read(recipeBuilderProvider.notifier).reset();
      context.pop();
    } else {
      context.push('/paywall');
    }
  }

  @override
  Widget build(BuildContext context) {
    final builderState = ref.watch(recipeBuilderProvider);
    final ingredientsAsync = ref.watch(ingredientsProvider);
    final ingredients = ingredientsAsync.valueOrNull ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editRecipeId != null ? 'Editar Receita' : 'Nova Receita'),
        leading: BackButton(onPressed: () {
          ref.read(recipeBuilderProvider.notifier).reset();
          context.pop();
        }),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppTheme.primaryColor),
                  )
                : const Text('Salvar',
                    style: TextStyle(
                        color: AppTheme.primaryColor, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Section 1: Recipe Details
            _SectionHeader(title: 'Detalhes da Receita', icon: Icons.info_outline_rounded),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Nome da Receita'),
              textCapitalization: TextCapitalization.words,
              onChanged: (v) => ref.read(recipeBuilderProvider.notifier).setName(v),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
            ),
            const SizedBox(height: 24),

            // Section 2: Ingredients
            _SectionHeader(title: 'Ingredientes', icon: Icons.kitchen_rounded),
            const SizedBox(height: 12),
            if (ingredients.isEmpty)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceVariantDark,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Color(0xFFFFA726)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Nenhum ingrediente cadastrado. Vá em Ingredientes para adicionar.',
                        style: const TextStyle(
                            fontSize: 13, color: Color(0xFF9E9E9E)),
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: DropdownButtonFormField<IngredientEntity>(
                          initialValue: _selectedIngredient,
                          decoration: const InputDecoration(
                              labelText: 'Selecionar Ingrediente'),
                          dropdownColor: AppTheme.surfaceVariantDark,
                          isExpanded: true,
                          items: ingredients
                              .map((i) => DropdownMenuItem(
                                    value: i,
                                    child: Text(i.name,
                                        overflow: TextOverflow.ellipsis),
                                  ))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedIngredient = v),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _qtyCtrl,
                          decoration: InputDecoration(
                            labelText:
                                'Qtd (${_selectedIngredient?.unitOfMeasure.label ?? 'un'})',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.]'))
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton.filled(
                        onPressed: _addIngredient,
                        icon: const Icon(Icons.add_rounded),
                        style: IconButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...builderState.ingredients.map((ri) => _IngredientUsageRow(
                        ingredientName: ri.ingredientName,
                        unit: ri.ingredientUnit,
                        qty: ri.quantityUsed,
                        cost: ri.calculatedIngredientCost,
                        currencyFormat: _currencyFormat,
                        onRemove: () => ref
                            .read(recipeBuilderProvider.notifier)
                            .removeIngredient(ri.ingredientId),
                      )),
                ],
              ),
            const SizedBox(height: 24),

            // Section 3: Operational Costs
            _SectionHeader(
                title: 'Custos Operacionais',
                icon: Icons.electric_bolt_rounded),
            const SizedBox(height: 12),
            TextFormField(
              controller: _operationalCostCtrl,
              decoration: const InputDecoration(
                labelText: 'Custo Operacional (gás, energia, etc.) R\$',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
              ],
              onChanged: (v) {
                final val = double.tryParse(v) ?? 0;
                ref
                    .read(recipeBuilderProvider.notifier)
                    .setOperationalCost(val);
              },
            ),
            const SizedBox(height: 24),

            // Section 4: Pricing
            _SectionHeader(
                title: 'Precificação', icon: Icons.trending_up_rounded),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: builderState.profitMarginPercentage.clamp(0, 300),
                    min: 0,
                    max: 300,
                    divisions: 300,
                    activeColor: AppTheme.primaryColor,
                    inactiveColor: AppTheme.surfaceVariantDark,
                    onChanged: (v) {
                      ref
                          .read(recipeBuilderProvider.notifier)
                          .setProfitMargin(v);
                      _marginCtrl.text = v.toStringAsFixed(0);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 70,
                  child: TextFormField(
                    controller: _marginCtrl,
                    decoration: const InputDecoration(labelText: '%'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    onChanged: (v) {
                      final val = double.tryParse(v) ?? 0;
                      ref
                          .read(recipeBuilderProvider.notifier)
                          .setProfitMargin(val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Section 5: Cost Summary
            _CostSummaryCard(
              totalCost: builderState.totalCost,
              suggestedSellPrice: builderState.suggestedSellPrice,
              margin: builderState.profitMarginPercentage,
              currencyFormat: _currencyFormat,
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.black),
                      )
                    : Text(
                        widget.editRecipeId != null
                            ? 'Atualizar Receita'
                            : 'Salvar Receita',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(child: Divider()),
      ],
    );
  }
}

class _IngredientUsageRow extends StatelessWidget {
  final String ingredientName;
  final String unit;
  final double qty;
  final double cost;
  final NumberFormat currencyFormat;
  final VoidCallback onRemove;

  const _IngredientUsageRow({
    required this.ingredientName,
    required this.unit,
    required this.qty,
    required this.cost,
    required this.currencyFormat,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.surfaceVariantDark,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(Icons.fiber_manual_record,
                size: 8, color: AppTheme.primaryColor),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ingredientName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  Text('$qty $unit',
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF9E9E9E))),
                ],
              ),
            ),
            Text(
              currencyFormat.format(cost),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryColor,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.close_rounded, size: 18),
              color: AppTheme.errorColor,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }
}

class _CostSummaryCard extends StatelessWidget {
  final double totalCost;
  final double suggestedSellPrice;
  final double margin;
  final NumberFormat currencyFormat;

  const _CostSummaryCard({
    required this.totalCost,
    required this.suggestedSellPrice,
    required this.margin,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2A2218), Color(0xFF1E1E1E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_outlined,
                  color: AppTheme.primaryColor, size: 20),
              const SizedBox(width: 8),
              const Text('Resumo de Custo',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryColor)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Custo Total',
                        style: TextStyle(
                            fontSize: 12, color: Color(0xFF9E9E9E))),
                    const SizedBox(height: 4),
                    Text(
                      currencyFormat.format(totalCost),
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),
              Container(
                height: 40,
                width: 1,
                color: const Color(0xFF424242),
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Preço Sugerido',
                        style: TextStyle(
                            fontSize: 12, color: Color(0xFF9E9E9E))),
                    const SizedBox(height: 4),
                    Text(
                      currencyFormat.format(suggestedSellPrice),
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.successColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Margem de lucro: ${margin.toStringAsFixed(0)}%',
              style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.successColor,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
