enum RecipeCategory {
  bolo,
  torta,
  brigadeiro,
  cookies,
  paes,
  salgados,
  bebidas,
  outro;

  String get label {
    switch (this) {
      case RecipeCategory.bolo:
        return 'Bolo';
      case RecipeCategory.torta:
        return 'Torta';
      case RecipeCategory.brigadeiro:
        return 'Brigadeiro';
      case RecipeCategory.cookies:
        return 'Cookies';
      case RecipeCategory.paes:
        return 'Pães';
      case RecipeCategory.salgados:
        return 'Salgados';
      case RecipeCategory.bebidas:
        return 'Bebidas';
      case RecipeCategory.outro:
        return 'Outro';
    }
  }

  static RecipeCategory fromString(String value) {
    return RecipeCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => RecipeCategory.outro,
    );
  }
}
