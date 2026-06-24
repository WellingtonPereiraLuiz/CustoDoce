import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:custo_doce/core/enums/unit_of_measure.dart';
import 'package:custo_doce/core/theme/app_theme.dart';
import 'package:custo_doce/core/utils/uuid_generator.dart';
import 'package:custo_doce/core/utils/plan_gate.dart';
import 'package:custo_doce/core/providers/subscription_provider.dart';
import 'package:custo_doce/domain/entities/ingredient_entity.dart';
import 'package:custo_doce/presentation/providers/ingredient_providers.dart';
import 'package:intl/intl.dart';

class IngredientManagerScreen extends ConsumerWidget {
  const IngredientManagerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ingredientsAsync = ref.watch(ingredientsProvider);
    final currencyFormat =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingredientes'),
        leading: BackButton(
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
          child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: ingredientsAsync.when(
                loading: () => Center(
                    child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.primary)),
                error: (e, _) => Center(child: Text('Erro: $e')),
                data: (ingredients) {
                  if (ingredients.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.inventory_2_outlined,
                              size: 64,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant),
                          const SizedBox(height: 16),
                          Text('Nenhum ingrediente cadastrado',
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Text('Toque em + para adicionar',
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.outline)),
                        ],
                      ),
                    );
                  }
                  return Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Column(
                        children: [
                          // Counter chip
                          Builder(builder: (context) {
                            final plan = ref.read(currentPlanProvider);
                            final count = ingredients.length;
                            if (plan.isUnlimitedIngredients)
                              return const SizedBox.shrink();
                            final isAtLimit = count >= plan.ingredientLimit;
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Chip(
                                  label: Text(
                                    '$count / ${plan.ingredientLimit} ingredientes',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isAtLimit
                                          ? AppTheme.errorColor
                                          : null,
                                    ),
                                  ),
                                  backgroundColor: isAtLimit
                                      ? AppTheme.errorColor.withAlpha(20)
                                      : Theme.of(context)
                                          .colorScheme
                                          .surfaceContainerHighest,
                                  side: BorderSide(
                                    color: isAtLimit
                                        ? AppTheme.errorColor.withAlpha(60)
                                        : Colors.transparent,
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                ),
                              ),
                            );
                          }),
                          Expanded(
                            child: ListView.builder(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 8, 16, 100),
                              itemCount: ingredients.length,
                              itemBuilder: (context, index) {
                                final ingredient = ingredients[index];
                                return _IngredientCard(
                                  ingredient: ingredient,
                                  currencyFormat: currencyFormat,
                                  onEdit: () => _showIngredientForm(
                                      context, ref, ingredient),
                                  onDelete: () async {
                                    final confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title:
                                            const Text('Excluir ingrediente'),
                                        content: Text(
                                            'Excluir "${ingredient.name}"? Receitas que usam este ingrediente podem ser afetadas.'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, false),
                                            child: const Text('Cancelar'),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .error,
                                              foregroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .onError,
                                            ),
                                            onPressed: () =>
                                                Navigator.pop(ctx, true),
                                            child: const Text('Excluir'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirmed == true) {
                                      await ref
                                          .read(ingredientsProvider.notifier)
                                          .deleteIngredient(ingredient.id);
                                    }
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ))),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_ingredient',
        onPressed: () {
          final plan = ref.read(currentPlanProvider);
          final ingredients = ref.read(ingredientsProvider).value ?? [];
          final canAdd = PlanGate.checkLimit(
            context: context,
            ref: ref,
            currentCount: ingredients.length,
            limit: plan.ingredientLimit,
            featureName: 'ingredientes',
            planName: plan.name,
          );
          if (canAdd) _showIngredientForm(context, ref, null);
        },
        icon: Icon(Icons.add_rounded),
        label: const Text('Novo Ingrediente'),
      ),
    );
  }

  void _showIngredientForm(
    BuildContext context,
    WidgetRef ref,
    IngredientEntity? existing,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => IngredientFormSheet(existing: existing, ref: ref),
    );
  }
}

class _IngredientCard extends StatelessWidget {
  final IngredientEntity ingredient;
  final NumberFormat currencyFormat;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _IngredientCard({
    required this.ingredient,
    required this.currencyFormat,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.kitchen_rounded,
                      color: Theme.of(context).colorScheme.primary, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ingredient.name,
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${ingredient.packageSize} ${ingredient.unitOfMeasure.label} • ${currencyFormat.format(ingredient.costPerPackage)}',
                        style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.outline),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      currencyFormat.format(ingredient.calculatedUnitCost),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'por ${ingredient.unitOfMeasure.label}',
                      style: TextStyle(
                          fontSize: 11,
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
                const SizedBox(width: 4),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert_rounded, size: 18),
                  onSelected: (v) {
                    if (v == 'edit') onEdit();
                    if (v == 'delete') onDelete();
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'edit', child: Text('Editar')),
                    PopupMenuItem(
                        value: 'delete',
                        child: Text('Excluir',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.error))),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class IngredientFormSheet extends StatefulWidget {
  final IngredientEntity? existing;
  final WidgetRef ref;

  const IngredientFormSheet({super.key, this.existing, required this.ref});

  @override
  State<IngredientFormSheet> createState() => _IngredientFormSheetState();
}

class _IngredientFormSheetState extends State<IngredientFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _packageSizeCtrl;
  late TextEditingController _costCtrl;
  UnitOfMeasure _selectedUnit = UnitOfMeasure.g;
  bool _isLoading = false;

  double get _calculatedUnitCost {
    final size = double.tryParse(_packageSizeCtrl.text) ?? 0;
    final cost = double.tryParse(_costCtrl.text) ?? 0;
    if (size <= 0) return 0;
    return cost / size;
  }

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existing?.name ?? '');
    _packageSizeCtrl = TextEditingController(
        text: widget.existing?.packageSize.toString() ?? '');
    _costCtrl = TextEditingController(
        text: widget.existing?.costPerPackage.toString() ?? '');
    if (widget.existing != null) {
      _selectedUnit = widget.existing!.unitOfMeasure;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _packageSizeCtrl.dispose();
    _costCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final packageSize = double.parse(_packageSizeCtrl.text);
    final cost = double.parse(_costCtrl.text);
    final ingredient = IngredientEntity(
      id: widget.existing?.id ?? generateUuid(),
      name: _nameCtrl.text.trim(),
      unitOfMeasure: _selectedUnit,
      packageSize: packageSize,
      costPerPackage: cost,
      calculatedUnitCost: cost / packageSize,
    );
    if (widget.existing == null) {
      await widget.ref
          .read(ingredientsProvider.notifier)
          .saveIngredient(ingredient);
    } else {
      await widget.ref
          .read(ingredientsProvider.notifier)
          .updateIngredient(ingredient);
    }
    setState(() => _isLoading = false);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 24,
        left: 20,
        right: 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.existing == null
                  ? 'Novo Ingrediente'
                  : 'Editar Ingrediente',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 20),
            // Name field
            TextFormField(
              controller: _nameCtrl,
              decoration:
                  const InputDecoration(labelText: 'Nome do Ingrediente'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Informe o nome' : null,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 14),
            // Unit of measure dropdown
            DropdownButtonFormField<UnitOfMeasure>(
              initialValue: _selectedUnit,
              decoration: const InputDecoration(labelText: 'Unidade de Medida'),
              items: UnitOfMeasure.values
                  .map((u) => DropdownMenuItem(
                        value: u,
                        child: Text(u.label),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _selectedUnit = v!),
            ),
            const SizedBox(height: 14),
            // Package size and cost
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _packageSizeCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Tamanho da Embalagem'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
                    ],
                    onChanged: (_) => setState(() {}),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Obrigatório';
                      if (double.tryParse(v) == null || double.parse(v) <= 0) {
                        return 'Valor inválido';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _costCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Custo da Embalagem (R\$)'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
                    ],
                    onChanged: (_) => setState(() {}),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Obrigatório';
                      if (double.tryParse(v) == null || double.parse(v) < 0) {
                        return 'Valor inválido';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Real-time calculated unit cost preview
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.calculate_rounded,
                      color: Theme.of(context).colorScheme.primary, size: 20),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Custo por unidade calculado',
                          style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context).colorScheme.outline)),
                      Text(
                        currencyFormat.format(_calculatedUnitCost),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _save,
                child: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Theme.of(context).colorScheme.onPrimary),
                      )
                    : Text(widget.existing == null
                        ? 'Salvar Ingrediente'
                        : 'Atualizar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
