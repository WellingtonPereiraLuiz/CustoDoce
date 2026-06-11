import 'package:custo_doce/core/theme/app_theme.dart';
import 'package:custo_doce/core/utils/plan_gate.dart';
import 'package:custo_doce/domain/entities/equipment_entity.dart';
import 'package:custo_doce/presentation/providers/equipment_providers.dart';
import 'package:custo_doce/presentation/providers/subscription_provider.dart';
import 'package:flutter/material.intl.dart' hide NumberFormat;
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EquipmentScreen extends ConsumerWidget {
  const EquipmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final equipmentState = ref.watch(equipmentProvider);
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final plan = ref.watch(currentPlanProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Equipamentos'),
      ),
      body: equipmentState.when(
        data: (equipmentList) {
          if (equipmentList.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80, top: 16, left: 16, right: 16),
            itemCount: equipmentList.length,
            itemBuilder: (context, index) {
              final eq = equipmentList[index];
              return Dismissible(
                key: Key(eq.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Colors.red.shade400,
                  child: const Icon(Icons.delete_outline, color: Colors.white),
                ),
                onDismissed: (_) {
                  ref.read(equipmentProvider.notifier).deleteEquipment(eq.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${eq.name} apagado.')),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      eq.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text('Potência: ${eq.powerWatts.toStringAsFixed(0)} W'),
                        Text('Custo kWh: ${currencyFormat.format(eq.kwhCost)}'),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Custo/hora: ${currencyFormat.format(eq.costPerHour)}/h',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _showEquipmentForm(context, ref, eq),
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Erro: $error')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (plan.equipmentLimit == 0) {
            PlanGate.checkFeature(
              context: context,
              hasAccess: false,
              featureName: 'Equipamentos',
              requiredPlan: 'Light',
            );
            return;
          }
          final count = ref.read(equipmentProvider).value?.length ?? 0;
          final canAdd = PlanGate.checkLimit(
            context: context,
            currentCount: count,
            limit: plan.equipmentLimit,
            featureName: 'equipamentos',
            planName: plan.name,
          );
          if (canAdd) {
            _showEquipmentForm(context, ref, null);
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Novo Equipamento'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.kitchen_outlined, size: 80, color: Theme.of(context).disabledColor),
          const SizedBox(height: 16),
          Text(
            'Nenhum equipamento cadastrado',
            style: TextStyle(fontSize: 18, color: Theme.of(context).disabledColor),
          ),
          const SizedBox(height: 8),
          const Text('Cadastre batedeira, forno, etc., para\ncalcular o custo de energia.'),
        ],
      ),
    );
  }

  void _showEquipmentForm(BuildContext context, WidgetRef ref, EquipmentEntity? equipment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: _EquipmentFormWidget(
          equipment: equipment,
          onSave: (eq) {
            ref.read(equipmentProvider.notifier).saveEquipment(eq);
            Navigator.pop(ctx);
          },
        ),
      ),
    );
  }
}

class _EquipmentFormWidget extends StatefulWidget {
  final EquipmentEntity? equipment;
  final Function(EquipmentEntity) onSave;

  const _EquipmentFormWidget({this.equipment, required this.onSave});

  @override
  State<_EquipmentFormWidget> createState() => _EquipmentFormWidgetState();
}

class _EquipmentFormWidgetState extends State<_EquipmentFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _powerController;
  late TextEditingController _kwhController;
  double _costPreview = 0.0;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.equipment?.name ?? '');
    _powerController = TextEditingController(
        text: widget.equipment != null ? widget.equipment!.powerWatts.toString() : '');
    _kwhController = TextEditingController(
        text: widget.equipment != null ? widget.equipment!.kwhCost.toString() : '0.75');

    _powerController.addListener(_updatePreview);
    _kwhController.addListener(_updatePreview);
    _updatePreview();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _powerController.dispose();
    _kwhController.dispose();
    super.dispose();
  }

  void _updatePreview() {
    final power = double.tryParse(_powerController.text.replaceAll(',', '.')) ?? 0.0;
    final kwh = double.tryParse(_kwhController.text.replaceAll(',', '.')) ?? 0.0;
    setState(() {
      _costPreview = (power / 1000) * kwh;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.equipment == null ? 'Novo Equipamento' : 'Editar Equipamento',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome do equipamento',
                prefixIcon: Icon(Icons.label_outline),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Informe o nome' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _powerController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Potência em Watts (W)',
                hintText: 'Ex: 1500',
                prefixIcon: Icon(Icons.bolt_outlined),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Informe a potência';
                if (double.tryParse(v.replaceAll(',', '.')) == null) return 'Valor inválido';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _kwhController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Custo do kWh (R\$)',
                hintText: 'Valor padrão: R\$ 0,75',
                prefixIcon: Icon(Icons.electrical_services_outlined),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Informe o custo do kWh';
                if (double.tryParse(v.replaceAll(',', '.')) == null) return 'Valor inválido';
                return null;
              },
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Preview Custo/hora:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    '${currencyFormat.format(_costPreview)}/h',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final eq = EquipmentEntity(
                    id: widget.equipment?.id ?? '',
                    name: _nameController.text.trim(),
                    powerWatts: double.parse(_powerController.text.replaceAll(',', '.')),
                    kwhCost: double.parse(_kwhController.text.replaceAll(',', '.')),
                  );
                  widget.onSave(eq);
                }
              },
              child: const Text('Salvar Equipamento'),
            ),
          ],
        ),
      ),
    );
  }
}
