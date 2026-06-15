enum SubscriptionPlan { free, light, pro, premium }

class PlanLimits {
  final SubscriptionPlan plan;
  final String name;
  final String priceLabel;
  final int recipeLimit;
  final int ingredientLimit;

  final bool hasDigitalMenu;
  final bool hasCloudBackup;
  final bool hasAiAssistant;

  const PlanLimits({
    required this.plan,
    required this.name,
    required this.priceLabel,
    required this.recipeLimit,
    required this.ingredientLimit,

    required this.hasDigitalMenu,
    required this.hasCloudBackup,
    required this.hasAiAssistant,
  });

  bool get isUnlimitedRecipes => recipeLimit == -1;
  bool get isUnlimitedIngredients => ingredientLimit == -1;

  static const free = PlanLimits(
    plan: SubscriptionPlan.free,
    name: 'Free',
    priceLabel: 'Grátis',
    recipeLimit: 3,
    ingredientLimit: 15,

    hasDigitalMenu: false,
    hasCloudBackup: false,
    hasAiAssistant: false,
  );

  static const light = PlanLimits(
    plan: SubscriptionPlan.light,
    name: 'Light',
    priceLabel: 'R\$ 4,90/mês',
    recipeLimit: 30,
    ingredientLimit: 100,

    hasDigitalMenu: false,
    hasCloudBackup: false,
    hasAiAssistant: false,
  );

  static const pro = PlanLimits(
    plan: SubscriptionPlan.pro,
    name: 'Pro',
    priceLabel: 'R\$ 9,90/mês',
    recipeLimit: -1,
    ingredientLimit: -1,

    hasDigitalMenu: true,
    hasCloudBackup: true,
    hasAiAssistant: true,
  );

  static const premium = PlanLimits(
    plan: SubscriptionPlan.premium,
    name: 'Premium',
    priceLabel: 'R\$ 14,90/mês',
    recipeLimit: -1,
    ingredientLimit: -1,

    hasDigitalMenu: true,
    hasCloudBackup: true,
    hasAiAssistant: true,
  );

  static const all = [free, light, pro, premium];

  static PlanLimits forPlan(SubscriptionPlan p) {
    return all.firstWhere((e) => e.plan == p, orElse: () => free);
  }
}
