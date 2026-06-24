enum AssistantActionType {
  none('none'),
  consultation('consultation'),
  createIngredient('create_ingredient'),
  updateIngredient('update_ingredient'),
  createRecipe('create_recipe'),
  invoiceScan('invoice_scan'),
  bulkIngredientUpdate('bulk_ingredient_update');

  final String value;
  const AssistantActionType(this.value);

  static AssistantActionType fromString(String value) {
    return AssistantActionType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => AssistantActionType.none,
    );
  }
}
