import 'package:custo_doce/domain/entities/equipment_entity.dart';

abstract class EquipmentRepository {
  Future<List<EquipmentEntity>> getAllEquipment();
  Future<void> saveEquipment(EquipmentEntity equipment);
  Future<void> updateEquipment(EquipmentEntity equipment);
  Future<void> deleteEquipment(String id);
  Future<int> getEquipmentCount();
}
