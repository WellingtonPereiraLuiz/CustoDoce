enum SubscriptionPlan { free, light, pro, premium }

class PlanLimits {
  final SubscriptionPlan plan;
  final String name;
  final String priceLabel;
  final int recipeLimit;
  final int ingredientLimit;
  final int equipmentLimit;
  final bool hasReports;
  final bool hasDigitalMenu;
  final bool hasCloudBackup;

  const PlanLimits({
    required this.plan,
    required this.name,
    required this.priceLabel,
    required this.recipeLimit,
    required this.ingredientLimit,
    required this.equipmentLimit,
    required this.hasReports,
    required this.hasDigitalMenu,
    required this.hasCloudBackup,
  });

  bool get isUnlimitedRecipes => recipeLimit == -1;
  bool get isUnlimitedIngredients => ingredientLimit == -1;

  static const free = PlanLimits(
    plan: SubscriptionPlan.free,
    name: 'Free',
    priceLabel: 'Grátis',
    recipeLimit: 3,
    ingredientLimit: 15,
    equipmentLimit: 0,
    hasReports: false,
    hasDigitalMenu: false,
    hasCloudBackup: false,
  );

  static const light = PlanLimits(
    plan: SubscriptionPlan.light,
    name: 'Light',
    priceLabel: 'R\$ 4,90/mês',
    recipeLimit: 30,
    ingredientLimit: 100,
    equipmentLimit: 5,
    hasReports: false,
    hasDigitalMenu: false,
    hasCloudBackup: false,
  );

  static const pro = PlanLimits(
    plan: SubscriptionPlan.pro,
    name: 'Pro',
    priceLabel: 'R\$ 9,90/mês',
    recipeLimit: -1,
    ingredientLimit: -1,
    equipmentLimit: -1,
    hasReports: true,
    hasDigitalMenu: false,
    hasCloudBackup: true,
  );

  static const premium = PlanLimits(
    plan: SubscriptionPlan.premium,
    name: 'Premium',
    priceLabel: 'R\$ 14,90/mês',
    recipeLimit: -1,
    ingredientLimit: -1,
    equipmentLimit: -1,
    hasReports: true,
    hasDigitalMenu: true,
    hasCloudBackup: true,
  );

  static const all = [free, light, pro, premium];

  static PlanLimits forPlan(SubscriptionPlan p) {
    return all.firstWhere((e) => e.plan == p, orElse: () => free);
  }
}
