enum SubscriptionPlan { free, light, pro, premium }

class PlanLimits {
  final SubscriptionPlan plan;
  final String name;
  final String priceLabel;
  final int recipeLimit;
  final int ingredientLimit;

  final bool hasCustomSellingPrice;
  final bool hasMenuToggle;
  final bool hasDigitalMenu;
  final bool hasExportJpg;
  final bool hasShareText;
  final bool hasChatAi;
  final bool hasExportPdf;
  final bool hasInvoiceScan;
  final bool hasCloudBackup;

  const PlanLimits({
    required this.plan,
    required this.name,
    required this.priceLabel,
    required this.recipeLimit,
    required this.ingredientLimit,
    required this.hasCustomSellingPrice,
    required this.hasMenuToggle,
    required this.hasDigitalMenu,
    required this.hasExportJpg,
    required this.hasShareText,
    required this.hasChatAi,
    required this.hasExportPdf,
    required this.hasInvoiceScan,
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
    hasCustomSellingPrice: false,
    hasMenuToggle: false,
    hasDigitalMenu: false,
    hasExportJpg: false,
    hasShareText: false,
    hasChatAi: false,
    hasExportPdf: false,
    hasInvoiceScan: false,
    hasCloudBackup: false,
  );

  static const light = PlanLimits(
    plan: SubscriptionPlan.light,
    name: 'Light',
    priceLabel: r'R$ 19,90/mês',
    recipeLimit: 30,
    ingredientLimit: 100,
    hasCustomSellingPrice: true,
    hasMenuToggle: false,
    hasDigitalMenu: false,
    hasExportJpg: false,
    hasShareText: false,
    hasChatAi: false,
    hasExportPdf: false,
    hasInvoiceScan: false,
    hasCloudBackup: true,
  );

  static const pro = PlanLimits(
    plan: SubscriptionPlan.pro,
    name: 'Pro',
    priceLabel: r'R$ 34,90/mês',
    recipeLimit: -1,
    ingredientLimit: -1,
    hasCustomSellingPrice: true,
    hasMenuToggle: true,
    hasDigitalMenu: true,
    hasExportJpg: true,
    hasShareText: true,
    hasChatAi: false,
    hasExportPdf: true,
    hasInvoiceScan: false,
    hasCloudBackup: true,
  );

  static const premium = PlanLimits(
    plan: SubscriptionPlan.premium,
    name: 'Premium',
    priceLabel: r'R$ 49,90/mês',
    recipeLimit: -1,
    ingredientLimit: -1,
    hasCustomSellingPrice: true,
    hasMenuToggle: true,
    hasDigitalMenu: true,
    hasExportJpg: true,
    hasShareText: true,
    hasChatAi: true,
    hasExportPdf: true,
    hasInvoiceScan: true,
    hasCloudBackup: true,
  );

  static const all = [free, light, pro, premium];

  static PlanLimits forPlan(SubscriptionPlan p) {
    return all.firstWhere((e) => e.plan == p, orElse: () => free);
  }
}
