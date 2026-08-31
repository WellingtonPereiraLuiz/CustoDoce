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

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Theme.of(context).colorScheme.surfaceContainer,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 24,
        left: 24,
        right: 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 48,
                height: 6,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .outlineVariant
                      .withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              widget.existing == null
                  ? 'Novo Ingrediente'
                  : 'Editar Ingrediente',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 24),
            // Name field
            TextFormField(
              controller: _nameCtrl,
              decoration: _buildInputDecoration('Nome do Ingrediente'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Informe o nome' : null,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            // Unit of measure dropdown
            DropdownButtonFormField<UnitOfMeasure>(
              initialValue: _selectedUnit,
              decoration: _buildInputDecoration('Unidade de Medida'),
              icon: Icon(Icons.arrow_drop_down,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
              items: UnitOfMeasure.values
                  .map((u) => DropdownMenuItem(
                        value: u,
                        child: Text(u.label),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _selectedUnit = v!),
            ),
            const SizedBox(height: 16),
            // Package size and cost
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _packageSizeCtrl,
                        decoration: _buildInputDecoration('Tamanho'),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
                        ],
                        onChanged: (_) => setState(() {}),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Obrigatório';
                          if (double.tryParse(v) == null ||
                              double.parse(v) <= 0) {
                            return 'Valor inválido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 4),
                      Text('Tamanho da Embalagem',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant
                                      .withValues(alpha: 0.7))),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _costCtrl,
                        decoration: _buildInputDecoration('Custo (R\$)'),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
                        ],
                        onChanged: (_) => setState(() {}),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Obrigatório';
                          if (double.tryParse(v) == null ||
                              double.parse(v) < 0) {
                            return 'Valor inválido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 4),
                      Text('Custo da Embalagem',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant
                                      .withValues(alpha: 0.7))),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Real-time calculated unit cost preview
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHigh
                    .withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .outlineVariant
                        .withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.calculate_outlined,
                        color: Theme.of(context).colorScheme.onSurface,
                        size: 20),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('CUSTO POR UNIDADE CALCULADO',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    fontSize: 10,
                                    letterSpacing: 0.5,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                    fontWeight: FontWeight.w700,
                                  )),
                      const SizedBox(height: 2),
                      Text(
                        currencyFormat.format(_calculatedUnitCost),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Action buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  foregroundColor:
                      Theme.of(context).colorScheme.onPrimaryContainer,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer),
                      )
                    : Text(
                        widget.existing == null
                            ? 'Salvar Ingrediente'
                            : 'Atualizar Ingrediente',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor:
                      Theme.of(context).colorScheme.onSurfaceVariant,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }
}
