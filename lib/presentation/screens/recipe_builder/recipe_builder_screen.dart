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
import 'package:fl_chart/fl_chart.dart';

class RecipeBuilderScreen extends ConsumerStatefulWidget {
  final String? editRecipeId;
  const RecipeBuilderScreen({super.key, this.editRecipeId});

  @override
  ConsumerState<RecipeBuilderScreen> createState() => _RecipeBuilderScreenState();
}

class _RecipeBuilderScreenState extends ConsumerState<RecipeBuilderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  final _fixedCostCtrl = TextEditingController(text: '0');
  
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
      _fixedCostCtrl.text = recipe.additionalOperationalCost.toString();
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _qtyCtrl.dispose();
    _fixedCostCtrl.dispose();
    super.dispose();
  }

  void _showInfoPopup(String title, String explanation) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceVariantDark,
        title: Text(title, style: const TextStyle(color: AppTheme.primaryColor)),
        content: Text(explanation, style: const TextStyle(color: Colors.white, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Entendi', style: TextStyle(color: AppTheme.primaryColor)),
          )
        ],
      )
    );
  }

  void _addIngredient() {
    if (_selectedIngredient == null) return;
    final qty = double.tryParse(_qtyCtrl.text);
    if (qty == null || qty <= 0) return;
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(recipeBuilderProvider);
    final notifier = ref.read(recipeBuilderProvider.notifier);
    final ingredientsAsync = ref.watch(ingredientsProvider);
    final ingredients = ingredientsAsync.valueOrNull ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editRecipeId != null ? 'Editar Receita' : 'Nova Receita'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Salvar', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nome da Receita'),
                  textCapitalization: TextCapitalization.words,
                  onChanged: notifier.setName,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
                ),
                const SizedBox(height: 24),

                // Ingredients
                const _SectionHeader(title: 'Ingredientes Base', icon: Icons.kitchen_rounded),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<IngredientEntity>(
                        initialValue: _selectedIngredient,
                        decoration: const InputDecoration(labelText: 'Selecionar'),
                        dropdownColor: AppTheme.surfaceVariantDark,
                        isExpanded: true,
                        items: ingredients.map((i) => DropdownMenuItem(value: i, child: Text(i.name, overflow: TextOverflow.ellipsis))).toList(),
                        onChanged: (v) => setState(() => _selectedIngredient = v),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _qtyCtrl,
                        decoration: InputDecoration(labelText: 'Qtd (${_selectedIngredient?.unitOfMeasure.label ?? 'un'})'),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton.filled(
                      onPressed: _addIngredient,
                      icon: const Icon(Icons.add_rounded),
                      style: IconButton.styleFrom(backgroundColor: AppTheme.primaryColor),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...state.ingredients.map((ri) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('${ri.ingredientName} (${ri.quantityUsed} ${ri.ingredientUnit})'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_currencyFormat.format(ri.calculatedIngredientCost), style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                          IconButton(icon: const Icon(Icons.close, color: AppTheme.errorColor), onPressed: () => notifier.removeIngredient(ri.ingredientId)),
                        ],
                      ),
                    )),
                const SizedBox(height: 24),

                // Invisible Costs
                _SectionHeader(
                  title: 'Custos Invisíveis & Fixos', 
                  icon: Icons.visibility_off_rounded,
                  onInfoTap: () => _showInfoPopup(
                    'Custos Invisíveis', 
                    'Todo produto tem custos invisíveis de pelo menos 20% (água, luz, gás, detergente, perdas). Isso garante que você não pague para trabalhar!'
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Aplicar Custo Invisível (%)'),
                  value: state.useInvisibleCost,
                  onChanged: notifier.toggleInvisibleCost,
                  activeColor: AppTheme.primaryColor,
                  contentPadding: EdgeInsets.zero,
                ),
                if (state.useInvisibleCost)
                  _NumericInput(
                    value: state.invisibleCostPercentage,
                    min: 0, max: 100, divisions: 100,
                    onChanged: notifier.setInvisibleCostPercentage,
                  ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _fixedCostCtrl,
                  decoration: const InputDecoration(labelText: 'Custo Fixo Adicional / Embalagem (R\$)'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (v) => notifier.setFixedCost(double.tryParse(v) ?? 0),
                ),
                const SizedBox(height: 24),

                // Profit Strategy
                _SectionHeader(
                  title: 'Estratégia de Lucro', 
                  icon: Icons.trending_up_rounded,
                  onInfoTap: () => _showInfoPopup(
                    'Lucro vs Markup', 
                    'Você pode definir seu lucro por % de Margem (ex: ganhar 50% em cima do custo) ou por Fator Multiplicador/Markup (ex: Custo x 3), que é o padrão usado na confeitaria.'
                  ),
                ),
                SwitchListTile(
                  title: const Text('Usar Fator Multiplicador (Markup)'),
                  subtitle: const Text('Recomendado para confeitaria'),
                  value: state.useMarkup,
                  onChanged: notifier.toggleMarkup,
                  activeColor: AppTheme.primaryColor,
                  contentPadding: EdgeInsets.zero,
                ),
                if (state.useMarkup) ...[
                  Text('Multiplicar custo total por:', style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                  _NumericInput(
                    value: state.markupMultiplier,
                    min: 1.0, max: 10.0, divisions: 90,
                    labelSuffix: 'x',
                    isDecimal: true,
                    onChanged: notifier.setMarkupMultiplier,
                  ),
                ] else ...[
                  Text('Margem de Lucro:', style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                  _NumericInput(
                    value: state.profitMarginPercentage,
                    min: 0, max: 300, divisions: 300,
                    onChanged: notifier.setProfitMargin,
                  ),
                ],
                const SizedBox(height: 24),

                // Investment
                _SectionHeader(
                  title: 'Fundo de Investimento', 
                  icon: Icons.savings_rounded,
                  onInfoTap: () => _showInfoPopup(
                    'Fundo de Investimento', 
                    'Separar uma % do seu Lucro Líquido para reinvestir na empresa (comprar equipamentos, marketing, etc.). Isso constrói o seu capital de giro.'
                  ),
                ),
                SwitchListTile(
                  title: const Text('Separar para Investimento'),
                  value: state.useInvestment,
                  onChanged: notifier.toggleInvestment,
                  activeColor: AppTheme.primaryColor,
                  contentPadding: EdgeInsets.zero,
                ),
                if (state.useInvestment)
                  _NumericInput(
                    value: state.investmentPercentage,
                    min: 0, max: 100, divisions: 100,
                    onChanged: notifier.setInvestmentPercentage,
                  ),
                const SizedBox(height: 32),

                // Dashboard Chart
                _PricingDashboard(state: state, currencyFormat: _currencyFormat),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onInfoTap;
  const _SectionHeader({required this.title, required this.icon, this.onInfoTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 20),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
        if (onInfoTap != null) ...[
          const SizedBox(width: 4),
          InkWell(
            onTap: onInfoTap,
            borderRadius: BorderRadius.circular(12),
            child: const Padding(
              padding: EdgeInsets.all(4.0),
              child: Icon(Icons.help_outline_rounded, size: 18, color: Colors.grey),
            ),
          ),
        ],
        const SizedBox(width: 12),
        const Expanded(child: Divider()),
      ],
    );
  }
}

class _PricingDashboard extends StatelessWidget {
  final RecipeBuilderState state;
  final NumberFormat currencyFormat;

  const _PricingDashboard({required this.state, required this.currencyFormat});

  @override
  Widget build(BuildContext context) {
    if (state.totalCost == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariantDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Text('Resumo Financeiro da Receita', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(
                    color: Colors.blueGrey,
                    value: state.totalIngredientsCost + state.fixedOperationalCost,
                    title: 'Bruto',
                    radius: 50,
                    titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  if (state.invisibleCost > 0)
                    PieChartSectionData(
                      color: Colors.orange,
                      value: state.invisibleCost,
                      title: 'Invisível',
                      radius: 50,
                      titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  PieChartSectionData(
                    color: AppTheme.successColor,
                    value: state.netProfit,
                    title: 'Lucro',
                    radius: 60,
                    titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  if (state.investmentValue > 0)
                    PieChartSectionData(
                      color: Colors.purpleAccent,
                      value: state.investmentValue,
                      title: 'Invest.',
                      radius: 50,
                      titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _StatRow('Custo Bruto (Ingredientes + Fixo)', state.totalIngredientsCost + state.fixedOperationalCost, currencyFormat, color: Colors.blueGrey),
          _StatRow('Custo Invisível (${state.invisibleCostPercentage.toStringAsFixed(0)}%)', state.invisibleCost, currencyFormat, color: Colors.orange),
          const Divider(height: 24),
          _StatRow('Custo Total', state.totalCost, currencyFormat, isBold: true),
          const SizedBox(height: 12),
          _StatRow('Fundo de Investimento', state.investmentValue, currencyFormat, color: Colors.purpleAccent),
          _StatRow('Lucro Líquido', state.netProfit, currencyFormat, color: AppTheme.successColor, isBold: true),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Preço Sugerido de Venda', style: TextStyle(fontSize: 16, color: Colors.grey)),
              Text(
                currencyFormat.format(state.finalPrice),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final double value;
  final NumberFormat format;
  final Color? color;
  final bool isBold;

  const _StatRow(this.label, this.value, this.format, {this.color, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (color != null) ...[
                Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                const SizedBox(width: 8),
              ],
              Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: isBold ? Colors.white : Colors.grey[300])),
            ],
          ),
          Text(format.format(value), style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: color ?? Colors.white)),
        ],
      ),
    );
  }
}

class _NumericInput extends StatefulWidget {
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;
  final String labelSuffix;
  final bool isDecimal;

  const _NumericInput({
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
    this.labelSuffix = '%',
    this.isDecimal = false,
  });

  @override
  State<_NumericInput> createState() => _NumericInputState();
}

class _NumericInputState extends State<_NumericInput> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: _format(widget.value));
  }

  @override
  void didUpdateWidget(_NumericInput old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      final newText = _format(widget.value);
      if (_ctrl.text != newText && double.tryParse(_ctrl.text) != widget.value) {
        _ctrl.text = newText;
      }
    }
  }

  String _format(double v) => widget.isDecimal ? v.toStringAsFixed(1) : v.toStringAsFixed(0);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _ctrl,
      decoration: InputDecoration(
        suffixText: widget.labelSuffix,
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
      onChanged: (v) {
        final val = double.tryParse(v);
        if (val != null && val >= widget.min && val <= widget.max) {
          widget.onChanged(val);
        }
      },
    );
  }
}

