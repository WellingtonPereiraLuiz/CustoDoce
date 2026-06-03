import 'package:custo_doce/core/enums/unit_of_measure.dart';

class IngredientEntity {
  final String id;
  final String name;
  final UnitOfMeasure unitOfMeasure;
  final double packageSize;
  final double costPerPackage;
  final double calculatedUnitCost;

  const IngredientEntity({
    required this.id,
    required this.name,
    required this.unitOfMeasure,
    required this.packageSize,
    required this.costPerPackage,
    required this.calculatedUnitCost,
  });

  IngredientEntity copyWith({
    String? id,
    String? name,
    UnitOfMeasure? unitOfMeasure,
    double? packageSize,
    double? costPerPackage,
    double? calculatedUnitCost,
  }) {
    return IngredientEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      unitOfMeasure: unitOfMeasure ?? this.unitOfMeasure,
      packageSize: packageSize ?? this.packageSize,
      costPerPackage: costPerPackage ?? this.costPerPackage,
      calculatedUnitCost: calculatedUnitCost ?? this.calculatedUnitCost,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IngredientEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
