import 'package:flutter/material.dart';

class AppStrings {
  final Locale locale;
  AppStrings(this.locale);

  static AppStrings of(BuildContext context) {
    return AppStrings(Localizations.localeOf(context));
  }

  // App
  String get appName => 'CustoDoce';

  // Navigation
  String get home => 'Início';
  String get settings => 'Configurações';
  String get ingredients => 'Ingredientes';
  String get recipes => 'Receitas';

  // Home Screen
  String get noRecipesYet => 'Nenhuma receita ainda';
  String get noRecipesSubtitle => 'Toque em + para criar sua primeira receita';
  String get newRecipe => 'Nova Receita';
  String get manageIngredients => 'Gerenciar Ingredientes';
  String get errorLoadingRecipes => 'Erro ao carregar receitas';
  String get tryAgain => 'Tentar novamente';
  String get deleteRecipe => 'Excluir receita';
  String get deleteRecipeConfirm => 'Deseja excluir esta receita? Esta ação não pode ser desfeita.';
  String get cancel => 'Cancelar';
  String get delete => 'Excluir';
  String get edit => 'Editar';

  // Costs
  String get totalCost => 'Custo Total';
  String get suggestedPrice => 'Preço Sugerido';
  String get margin => 'Margem';

  // Ingredient Screen
  String get noIngredientsYet => 'Nenhum ingrediente cadastrado';
  String get addIngredient => 'Novo Ingrediente';
  String get newIngredient => 'Novo Ingrediente';
  String get editIngredient => 'Editar Ingrediente';
  String get ingredientName => 'Nome do Ingrediente';
  String get unitOfMeasure => 'Unidade de Medida';
  String get packageSize => 'Tamanho da Embalagem';
  String get packageCost => 'Custo da Embalagem (R\$)';
  String get calculatedUnitCost => 'Custo por unidade calculado';
  String get saveIngredient => 'Salvar Ingrediente';
  String get updateIngredient => 'Atualizar';
  String get deleteIngredient => 'Excluir ingrediente';
  String get perUnit => 'por';
  String get required => 'Obrigatório';
  String get enterName => 'Informe o nome';
  String get invalidValue => 'Valor inválido';

  // Recipe Builder
  String get newRecipeTitle => 'Nova Receita';
  String get editRecipeTitle => 'Editar Receita';
  String get save => 'Salvar';
  String get recipeDetails => 'Detalhes da Receita';
  String get recipeName => 'Nome da Receita';
  String get ingredientsSection => 'Ingredientes';
  String get selectIngredient => 'Selecionar Ingrediente';
  String get quantity => 'Qtd';
  String get operationalCosts => 'Custos Operacionais';
  String get operationalCostLabel => 'Custo Operacional (gás, energia...) R\$';
  String get pricing => 'Precificação';
  String get costSummary => 'Resumo de Custo';
  String get profitMargin => 'Margem de lucro';
  String get saveRecipe => 'Salvar Receita';
  String get updateRecipe => 'Atualizar Receita';
  String get addAtLeastOneIngredient => 'Adicione pelo menos um ingrediente';
  String get noIngredientsWarning => 'Nenhum ingrediente cadastrado. Vá em Ingredientes para adicionar.';

  // Settings Screen
  String get settingsTitle => 'Configurações';
  String get appearance => 'Aparência';
  String get theme => 'Tema';
  String get darkTheme => 'Escuro';
  String get lightTheme => 'Claro';
  String get systemTheme => 'Sistema';
  String get language => 'Idioma';
  String get about => 'Sobre';
  String get version => 'Versão';
  String get aboutApp => 'Sobre o CustoDoce';
  String get aboutDescription => 'Calculadora de custos para confeiteiros e empreendedores da culinária.';
  String get dataAndPrivacy => 'Dados e Privacidade';
  String get clearAllData => 'Limpar todos os dados';
  String get clearAllDataConfirm => 'Isso irá apagar todas as receitas e ingredientes. Esta ação não pode ser desfeita.';
  String get confirm => 'Confirmar';
  String get pro => 'Pro';
  String get upgradeToPro => 'Upgrade para Pro';
  String get upgradeDescription => 'Receitas ilimitadas + sincronização na nuvem';

  // Paywall
  String get paywallTitle => 'CustoDoce Pro';
  String get paywallSubtitle => 'Você atingiu o limite de 3 receitas do plano gratuito.';
  String get subscribeNow => 'Assinar Pro Agora 🚀';
  String get restorePurchases => 'Restaurar Compras';
}
