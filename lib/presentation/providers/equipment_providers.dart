import 'package:custo_doce/data/local/database/database_helper.dart';
import 'package:custo_doce/data/local/datasources/local_equipment_datasource.dart';
import 'package:custo_doce/data/repositories/equipment_repository_impl.dart';
import 'package:custo_doce/domain/entities/equipment_entity.dart';
import 'package:custo_doce/domain/repositories/equipment_repository.dart';
import 'package:custo_doce/core/providers/auth_provider.dart';
import 'package:custo_doce/core/providers/subscription_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final equipmentRepositoryProvider = Provider<EquipmentRepository>((ref) {
  final datasource = LocalEquipmentDatasource(DatabaseHelper.instance);
  return EquipmentRepositoryImpl(datasource);
});

class EquipmentNotifier extends AsyncNotifier<List<EquipmentEntity>> {
  late EquipmentRepository _repository;

  @override
  Future<List<EquipmentEntity>> build() async {
    _repository = ref.watch(equipmentRepositoryProvider);
    return _repository.getAllEquipment();
  }

  Future<bool> saveEquipment(EquipmentEntity equipment) async {
    try {
      final plan = ref.read(currentPlanProvider);
      final count = state.value?.length ?? 0;
      
      if (plan.equipmentLimit != -1 && count >= plan.equipmentLimit) {
        return false;
      }

      final authUser = ref.read(currentUserProvider);
      final newEquipment = equipment.copyWith(
        id: equipment.id.isEmpty ? const Uuid().v4() : equipment.id,
        userId: authUser?.uid,
      );

      if (equipment.id.isEmpty) {
        await _repository.saveEquipment(newEquipment);
      } else {
        await _repository.updateEquipment(newEquipment);
      }
      
      ref.invalidateSelf();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> deleteEquipment(String id) async {
    await _repository.deleteEquipment(id);
    ref.invalidateSelf();
  }
}

final equipmentProvider = AsyncNotifierProvider<EquipmentNotifier, List<EquipmentEntity>>(
  EquipmentNotifier.new,
);
