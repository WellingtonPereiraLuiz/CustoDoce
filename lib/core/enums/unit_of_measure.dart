enum UnitOfMeasure {
  g('g'),
  kg('kg'),
  ml('ml'),
  l('L'),
  unidade('unidade');

  final String label;
  const UnitOfMeasure(this.label);

  static UnitOfMeasure fromString(String value) {
    return UnitOfMeasure.values.firstWhere(
      (e) => e.label == value,
      orElse: () => throw ArgumentError('Invalid unit: $value'),
    );
  }
}
