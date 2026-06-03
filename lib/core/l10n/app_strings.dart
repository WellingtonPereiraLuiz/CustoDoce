import 'package:flutter/material.dart';

class AppStrings {
  final Locale locale;
  AppStrings(this.locale);

  static AppStrings of(BuildContext context) {
    return AppStrings(Localizations.localeOf(context));
  }

  bool get _isPt => locale.languageCode == 'pt';

  // App
  String get appName => 'CustoDoce';

  // Navigation
  String get home => _isPt ? 'Início' : 'Home';
  String get settings => _isPt ? 'Configurações' : 'Settings';
  String get ingredients => _isPt ? 'Ingredientes' : 'Ingredients';
  String get recipes => _isPt ? 'Receitas' : 'Recipes';

  // Home Screen
  String get noRecipesYet => _isPt ? 'Nenhuma receita ainda' : 'No recipes yet';
  String get noRecipesSubtitle => _isPt
      ? 'Toque em + para criar sua primeira receita'
      : 'Tap + to create your first recipe';
  String get newRecipe => _isPt ? 'Nova Receita' : 'New Recipe';
  String get manageIngredients =>
      _isPt ? 'Gerenciar Ingredientes' : 'Manage Ingredients';
  String get errorLoadingRecipes =>
      _isPt ? 'Erro ao carregar receitas' : 'Error loading recipes';
  String get tryAgain => _isPt ? 'Tentar novamente' : 'Try again';
  String get deleteRecipe => _isPt ? 'Excluir receita' : 'Delete recipe';
  String get deleteRecipeConfirm => _isPt
      ? 'Deseja excluir esta receita? Esta ação não pode ser desfeita.'
      : 'Delete this recipe? This action cannot be undone.';
  String get cancel => _isPt ? 'Cancelar' : 'Cancel';
  String get delete => _isPt ? 'Excluir' : 'Delete';
  String get edit => _isPt ? 'Editar' : 'Edit';

  // Costs
  String get totalCost => _isPt ? 'Custo Total' : 'Total Cost';
  String get suggestedPrice => _isPt ? 'Preço Sugerido' : 'Suggested Price';
  String get margin => _isPt ? 'Margem' : 'Margin';

  // Ingredient Screen
  String get noIngredientsYet =>
      _isPt ? 'Nenhum ingrediente cadastrado' : 'No ingredients yet';
  String get addIngredient => _isPt ? 'Novo Ingrediente' : 'New Ingredient';
  String get newIngredient => _isPt ? 'Novo Ingrediente' : 'New Ingredient';
  String get editIngredient => _isPt ? 'Editar Ingrediente' : 'Edit Ingredient';
  String get ingredientName =>
      _isPt ? 'Nome do Ingrediente' : 'Ingredient Name';
  String get unitOfMeasure => _isPt ? 'Unidade de Medida' : 'Unit of Measure';
  String get packageSize => _isPt ? 'Tamanho da Embalagem' : 'Package Size';
  String get packageCost =>
      _isPt ? 'Custo da Embalagem (R\$)' : 'Package Cost (R\$)';
  String get calculatedUnitCost =>
      _isPt ? 'Custo por unidade calculado' : 'Calculated unit cost';
  String get saveIngredient => _isPt ? 'Salvar Ingrediente' : 'Save Ingredient';
  String get updateIngredient => _isPt ? 'Atualizar' : 'Update';
  String get deleteIngredient => _isPt ? 'Excluir ingrediente' : 'Delete ingredient';
  String get perUnit => _isPt ? 'por' : 'per';
  String get required => _isPt ? 'Obrigatório' : 'Required';
  String get enterName => _isPt ? 'Informe o nome' : 'Enter a name';
  String get invalidValue => _isPt ? 'Valor inválido' : 'Invalid value';

  // Recipe Builder
  String get newRecipeTitle => _isPt ? 'Nova Receita' : 'New Recipe';
  String get editRecipeTitle => _isPt ? 'Editar Receita' : 'Edit Recipe';
  String get save => _isPt ? 'Salvar' : 'Save';
  String get recipeDetails => _isPt ? 'Detalhes da Receita' : 'Recipe Details';
  String get recipeName => _isPt ? 'Nome da Receita' : 'Recipe Name';
  String get ingredientsSection => _isPt ? 'Ingredientes' : 'Ingredients';
  String get selectIngredient =>
      _isPt ? 'Selecionar Ingrediente' : 'Select Ingredient';
  String get quantity => _isPt ? 'Qtd' : 'Qty';
  String get operationalCosts =>
      _isPt ? 'Custos Operacionais' : 'Operational Costs';
  String get operationalCostLabel =>
      _isPt ? 'Custo Operacional (gás, energia...) R\$' : 'Operational Cost (gas, electricity...) R\$';
  String get pricing => _isPt ? 'Precificação' : 'Pricing';
  String get costSummary => _isPt ? 'Resumo de Custo' : 'Cost Summary';
  String get profitMargin => _isPt ? 'Margem de lucro' : 'Profit margin';
  String get saveRecipe => _isPt ? 'Salvar Receita' : 'Save Recipe';
  String get updateRecipe => _isPt ? 'Atualizar Receita' : 'Update Recipe';
  String get addAtLeastOneIngredient => _isPt
      ? 'Adicione pelo menos um ingrediente'
      : 'Add at least one ingredient';
  String get noIngredientsWarning => _isPt
      ? 'Nenhum ingrediente cadastrado. Vá em Ingredientes para adicionar.'
      : 'No ingredients registered. Go to Ingredients to add some.';

  // Settings Screen
  String get settingsTitle => _isPt ? 'Configurações' : 'Settings';
  String get appearance => _isPt ? 'Aparência' : 'Appearance';
  String get theme => _isPt ? 'Tema' : 'Theme';
  String get darkTheme => _isPt ? 'Escuro' : 'Dark';
  String get lightTheme => _isPt ? 'Claro' : 'Light';
  String get systemTheme => _isPt ? 'Sistema' : 'System';
  String get language => _isPt ? 'Idioma' : 'Language';
  String get portuguese => 'Português (BR)';
  String get english => 'English (US)';
  String get about => _isPt ? 'Sobre' : 'About';
  String get version => _isPt ? 'Versão' : 'Version';
  String get aboutApp => _isPt ? 'Sobre o CustoDoce' : 'About CustoDoce';
  String get aboutDescription => _isPt
      ? 'Calculadora de custos para confeiteiros e empreendedores da culinária.'
      : 'Cost calculator for bakers and culinary entrepreneurs.';
  String get dataAndPrivacy => _isPt ? 'Dados e Privacidade' : 'Data & Privacy';
  String get clearAllData => _isPt ? 'Limpar todos os dados' : 'Clear all data';
  String get clearAllDataConfirm => _isPt
      ? 'Isso irá apagar todas as receitas e ingredientes. Esta ação não pode ser desfeita.'
      : 'This will erase all recipes and ingredients. This action cannot be undone.';
  String get confirm => _isPt ? 'Confirmar' : 'Confirm';
  String get pro => 'Pro';
  String get upgradeToPro => _isPt ? 'Upgrade para Pro' : 'Upgrade to Pro';
  String get upgradeDescription => _isPt
      ? 'Receitas ilimitadas + sincronização na nuvem'
      : 'Unlimited recipes + cloud sync';

  // Paywall
  String get paywallTitle => 'CustoDoce Pro';
  String get paywallSubtitle => _isPt
      ? 'Você atingiu o limite de 3 receitas do plano gratuito.'
      : 'You reached the 3-recipe limit of the free plan.';
  String get subscribeNow => _isPt ? 'Assinar Pro Agora 🚀' : 'Subscribe Pro Now 🚀';
  String get restorePurchases => _isPt ? 'Restaurar Compras' : 'Restore Purchases';
}
