import 'package:custo_doce/data/local/datasources/local_equipment_datasource.dart';
import 'package:custo_doce/data/local/models/equipment_model.dart';
import 'package:custo_doce/domain/entities/equipment_entity.dart';
import 'package:custo_doce/domain/repositories/equipment_repository.dart';

class EquipmentRepositoryImpl implements EquipmentRepository {
  final LocalEquipmentDatasource _localDatasource;

  EquipmentRepositoryImpl(this._localDatasource);

  @override
  Future<List<EquipmentEntity>> getAllEquipment() async {
    return await _localDatasource.getAllEquipment();
  }

  @override
  Future<void> saveEquipment(EquipmentEntity equipment) async {
    final model = EquipmentModel.fromEntity(equipment);
    await _localDatasource.insertEquipment(model);
  }

  @override
  Future<void> updateEquipment(EquipmentEntity equipment) async {
    final model = EquipmentModel.fromEntity(equipment);
    await _localDatasource.updateEquipment(model);
  }

  @override
  Future<void> deleteEquipment(String id) async {
    await _localDatasource.deleteEquipment(id);
  }

  @override
  Future<int> getEquipmentCount() async {
    return await _localDatasource.getEquipmentCount();
  }
}
