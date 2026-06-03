import 'package:custo_doce/core/enums/unit_of_measure.dart';
import 'package:custo_doce/domain/entities/ingredient_entity.dart';

class IngredientModel {
  final String id;
  final String name;
  final String unitOfMeasure;
  final double packageSize;
  final double costPerPackage;
  final double calculatedUnitCost;

  const IngredientModel({
    required this.id,
    required this.name,
    required this.unitOfMeasure,
    required this.packageSize,
    required this.costPerPackage,
    required this.calculatedUnitCost,
  });

  factory IngredientModel.fromMap(Map<String, dynamic> map) {
    return IngredientModel(
      id: map['id'] as String,
      name: map['name'] as String,
      unitOfMeasure: map['unit_of_measure'] as String,
      packageSize: (map['package_size'] as num).toDouble(),
      costPerPackage: (map['cost_per_package'] as num).toDouble(),
      calculatedUnitCost: (map['calculated_unit_cost'] as num).toDouble(),
    );
  }

  factory IngredientModel.fromEntity(IngredientEntity entity) {
    return IngredientModel(
      id: entity.id,
      name: entity.name,
      unitOfMeasure: entity.unitOfMeasure.label,
      packageSize: entity.packageSize,
      costPerPackage: entity.costPerPackage,
      calculatedUnitCost: entity.calculatedUnitCost,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'unit_of_measure': unitOfMeasure,
      'package_size': packageSize,
      'cost_per_package': costPerPackage,
      'calculated_unit_cost': calculatedUnitCost,
    };
  }

  IngredientEntity toEntity() {
    return IngredientEntity(
      id: id,
      name: name,
      unitOfMeasure: UnitOfMeasure.fromString(unitOfMeasure),
      packageSize: packageSize,
      costPerPackage: costPerPackage,
      calculatedUnitCost: calculatedUnitCost,
    );
  }
}
