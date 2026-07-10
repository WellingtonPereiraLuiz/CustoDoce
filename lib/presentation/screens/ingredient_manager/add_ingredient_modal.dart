import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:custo_doce/core/enums/unit_of_measure.dart';
import 'package:custo_doce/core/utils/uuid_generator.dart';
import 'package:custo_doce/domain/entities/ingredient_entity.dart';
import 'package:custo_doce/presentation/providers/ingredient_providers.dart';

/// Bottom sheet de criação/edição de ingrediente do design system Stitch v2,
/// com pré-visualização em tempo real do custo por unidade calculado.
class AddIngredientModal extends StatefulWidget {
  final IngredientEntity? existing;
  final WidgetRef ref;

  const AddIngredientModal({super.key, this.existing, required this.ref});

  @override
  State<AddIngredientModal> createState() => _AddIngredientModalState();
}

class _AddIngredientModalState extends State<AddIngredientModal> {
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
              style: Theme.of(context).textTheme.headlineSmall,
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
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant),
              ),
              child: Row(
                children: [
                  Icon(Icons.calculate_rounded,
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      size: 20),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Custo por unidade calculado',
                          style: Theme.of(context).textTheme.labelSmall),
                      Text(
                        currencyFormat.format(_calculatedUnitCost),
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondaryContainer,
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
