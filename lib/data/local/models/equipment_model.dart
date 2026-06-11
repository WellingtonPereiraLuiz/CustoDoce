import 'package:custo_doce/domain/entities/equipment_entity.dart';

class EquipmentModel extends EquipmentEntity {
  const EquipmentModel({
    required super.id,
    required super.name,
    required super.powerWatts,
    required super.kwhCost,
    super.userId,
  });

  factory EquipmentModel.fromMap(Map<String, dynamic> map) {
    return EquipmentModel(
      id: map['id'] as String,
      name: map['name'] as String,
      powerWatts: (map['power_watts'] as num).toDouble(),
      kwhCost: (map['kwh_cost'] as num).toDouble(),
      userId: map['user_id'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'power_watts': powerWatts,
      'kwh_cost': kwhCost,
      'user_id': userId,
    };
  }

  factory EquipmentModel.fromEntity(EquipmentEntity entity) {
    return EquipmentModel(
      id: entity.id,
      name: entity.name,
      powerWatts: entity.powerWatts,
      kwhCost: entity.kwhCost,
      userId: entity.userId,
    );
  }
}
