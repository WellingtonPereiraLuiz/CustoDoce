class EquipmentEntity {
  final String id;
  final String name;
  final double powerWatts;
  final double kwhCost;
  final String? userId;

  const EquipmentEntity({
    required this.id,
    required this.name,
    required this.powerWatts,
    required this.kwhCost,
    this.userId,
  });

  /// Custo por hora de uso em R$ (Potência em W / 1000 * Custo do kWh)
  double get costPerHour => (powerWatts / 1000) * kwhCost;

  EquipmentEntity copyWith({
    String? id,
    String? name,
    double? powerWatts,
    double? kwhCost,
    String? userId,
  }) {
    return EquipmentEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      powerWatts: powerWatts ?? this.powerWatts,
      kwhCost: kwhCost ?? this.kwhCost,
      userId: userId ?? this.userId,
    );
  }
}
