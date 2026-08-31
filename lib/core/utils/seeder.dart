import 'package:custo_doce/data/local/database/database_helper.dart';
import 'package:flutter/foundation.dart';

/// Popula o banco local com um catálogo de ingredientes e um portfólio de
/// receitas de exemplo, para que o app já abra com conteúdo em telas de
/// demonstração.
///
/// É idempotente: cada ingrediente/receita só é inserido se ainda não existir
/// um registro com o mesmo nome, então nunca duplica dados nem apaga o que o
/// usuário criou. Se já houver 15+ receitas cadastradas, não faz nada.
Future<void> seedDatabase() async {
  try {
    final db = await DatabaseHelper.instance.database;

    final countRows =
        await db.rawQuery('SELECT COUNT(*) as c FROM recipes');
    final recipeCount = (countRows.first['c'] as int?) ?? 0;
    if (recipeCount >= 15) return;

    var seq = DateTime.now().microsecondsSinceEpoch;

    // ── Catálogo de ingredientes ────────────────────────────────────────
    // [nome, unidade, tamanho da embalagem, custo da embalagem fechada]
    const ingredientSeed = <List<Object>>[
      ['Leite Condensado', 'g', 395.0, 6.50],
      ['Creme de Leite', 'g', 200.0, 3.50],
      ['Chocolate em Pó 50%', 'g', 200.0, 9.90],
      ['Chocolate Granulado', 'g', 150.0, 6.00],
      ['Chocolate Meio Amargo', 'g', 1000.0, 45.00],
      ['Cacau em Pó', 'g', 200.0, 12.00],
      ['Manteiga', 'g', 200.0, 9.00],
      ['Açúcar Refinado', 'g', 1000.0, 4.50],
      ['Açúcar de Confeiteiro', 'g', 500.0, 6.00],
      ['Farinha de Trigo', 'g', 1000.0, 5.00],
      ['Fubá', 'g', 500.0, 4.00],
      ['Polvilho Doce', 'g', 500.0, 7.50],
      ['Amido de Milho', 'g', 200.0, 4.50],
      ['Ovo', 'unidade', 12.0, 9.00],
      ['Leite Integral', 'ml', 1000.0, 5.00],
      ['Óleo de Soja', 'ml', 900.0, 7.50],
      ['Fermento Químico', 'g', 100.0, 4.50],
      ['Fermento Biológico Seco', 'g', 10.0, 3.00],
      ['Sal', 'g', 1000.0, 3.00],
      ['Essência de Baunilha', 'ml', 30.0, 8.00],
      ['Erva Doce', 'g', 20.0, 3.00],
      ['Coco Ralado', 'g', 100.0, 4.50],
      ['Nozes', 'g', 100.0, 15.00],
      ['Morango', 'g', 500.0, 8.00],
      ['Limão', 'unidade', 6.0, 4.50],
      ['Cenoura', 'g', 500.0, 3.50],
      ['Cream Cheese', 'g', 150.0, 8.50],
      ['Requeijão', 'g', 200.0, 6.50],
      ['Queijo Mussarela', 'g', 500.0, 25.00],
      ['Presunto', 'g', 200.0, 8.00],
      ['Biscoito Maisena', 'g', 400.0, 6.00],
      ['Doce de Leite', 'g', 400.0, 12.00],
      ['Café Solúvel', 'g', 50.0, 9.00],
    ];

    final unitCostByName = <String, double>{};
    final idByName = <String, String>{};

    for (final row in ingredientSeed) {
      final name = row[0] as String;
      final unit = row[1] as String;
      final packageSize = row[2] as double;
      final packageCost = row[3] as double;
      final unitCost = packageCost / packageSize;
      unitCostByName[name] = unitCost;

      final existing = await db.query('ingredients',
          columns: ['id'], where: 'name = ?', whereArgs: [name], limit: 1);
      if (existing.isNotEmpty) {
        idByName[name] = existing.first['id'] as String;
        continue;
      }

      final id = 'seed_ing_${seq++}';
      idByName[name] = id;
      await db.insert('ingredients', {
        'id': id,
        'name': name,
        'unit_of_measure': unit,
        'package_size': packageSize,
        'cost_per_package': packageCost,
        'calculated_unit_cost': unitCost,
        'user_id': null,
      });
    }

    // ── Portfólio de receitas ───────────────────────────────────────────
    const recipeSeed = <_SeedRecipe>[
      _SeedRecipe('Brigadeiro Gourmet', 'brigadeiro', 30, 120, 2.0, true, {
        'Leite Condensado': 395,
        'Chocolate em Pó 50%': 40,
        'Manteiga': 15,
        'Chocolate Granulado': 100,
      }),
      _SeedRecipe('Beijinho de Coco', 'brigadeiro', 30, 110, 2.0, true, {
        'Leite Condensado': 395,
        'Creme de Leite': 30,
        'Coco Ralado': 60,
        'Manteiga': 15,
      }),
      _SeedRecipe('Docinho de Nozes', 'brigadeiro', 25, 130, 3.0, false, {
        'Leite Condensado': 395,
        'Nozes': 80,
        'Creme de Leite': 20,
        'Açúcar de Confeiteiro': 40,
      }),
      _SeedRecipe('Bolo de Cenoura com Cobertura', 'bolo', 12, 90, 3.0, true, {
        'Cenoura': 300,
        'Ovo': 3,
        'Óleo de Soja': 180,
        'Açúcar Refinado': 300,
        'Farinha de Trigo': 250,
        'Fermento Químico': 15,
        'Chocolate em Pó 50%': 60,
      }),
      _SeedRecipe('Bolo de Chocolate', 'bolo', 12, 100, 3.0, true, {
        'Farinha de Trigo': 250,
        'Açúcar Refinado': 300,
        'Cacau em Pó': 80,
        'Ovo': 3,
        'Leite Integral': 200,
        'Óleo de Soja': 120,
        'Fermento Químico': 15,
        'Chocolate Meio Amargo': 150,
      }),
      _SeedRecipe('Bolo Formigueiro', 'bolo', 12, 85, 2.5, false, {
        'Farinha de Trigo': 250,
        'Açúcar Refinado': 250,
        'Ovo': 3,
        'Leite Integral': 200,
        'Óleo de Soja': 120,
        'Chocolate Granulado': 100,
        'Fermento Químico': 15,
      }),
      _SeedRecipe('Bolo de Fubá com Erva-Doce', 'bolo', 12, 80, 2.0, false, {
        'Fubá': 250,
        'Farinha de Trigo': 150,
        'Açúcar Refinado': 250,
        'Ovo': 3,
        'Leite Integral': 200,
        'Óleo de Soja': 120,
        'Erva Doce': 5,
        'Fermento Químico': 15,
      }),
      _SeedRecipe('Bolo Recheado de Doce de Leite', 'bolo', 14, 95, 4.0, true, {
        'Farinha de Trigo': 300,
        'Açúcar Refinado': 250,
        'Ovo': 4,
        'Leite Integral': 150,
        'Óleo de Soja': 100,
        'Fermento Químico': 15,
        'Doce de Leite': 400,
      }),
      _SeedRecipe('Torta de Limão', 'torta', 10, 85, 3.0, true, {
        'Biscoito Maisena': 200,
        'Manteiga': 100,
        'Leite Condensado': 395,
        'Limão': 3,
        'Creme de Leite': 200,
      }),
      _SeedRecipe('Cheesecake de Morango', 'torta', 12, 95, 4.0, true, {
        'Biscoito Maisena': 200,
        'Manteiga': 90,
        'Cream Cheese': 300,
        'Açúcar Refinado': 150,
        'Ovo': 2,
        'Morango': 250,
      }),
      _SeedRecipe('Pavê de Chocolate', 'torta', 12, 80, 3.0, false, {
        'Biscoito Maisena': 200,
        'Leite Integral': 500,
        'Amido de Milho': 60,
        'Açúcar Refinado': 150,
        'Chocolate em Pó 50%': 60,
        'Creme de Leite': 200,
        'Ovo': 2,
      }),
      _SeedRecipe('Cookies com Gotas de Chocolate', 'cookies', 20, 130, 2.0,
          true, {
        'Farinha de Trigo': 300,
        'Manteiga': 150,
        'Açúcar Refinado': 150,
        'Açúcar de Confeiteiro': 50,
        'Ovo': 1,
        'Chocolate Meio Amargo': 200,
        'Essência de Baunilha': 5,
      }),
      _SeedRecipe('Brownie com Nozes', 'cookies', 16, 120, 3.0, true, {
        'Chocolate Meio Amargo': 200,
        'Manteiga': 150,
        'Açúcar Refinado': 200,
        'Ovo': 3,
        'Farinha de Trigo': 120,
        'Cacau em Pó': 30,
        'Nozes': 50,
      }),
      _SeedRecipe('Pão de Queijo', 'paes', 25, 100, 2.0, true, {
        'Polvilho Doce': 500,
        'Ovo': 2,
        'Óleo de Soja': 100,
        'Leite Integral': 200,
        'Queijo Mussarela': 200,
        'Sal': 10,
      }),
      _SeedRecipe('Pão Caseiro', 'paes', 2, 70, 1.5, false, {
        'Farinha de Trigo': 1000,
        'Fermento Biológico Seco': 10,
        'Açúcar Refinado': 40,
        'Sal': 15,
        'Óleo de Soja': 60,
      }),
      _SeedRecipe('Enroladinho de Presunto e Queijo', 'salgados', 25, 115, 3.0,
          true, {
        'Farinha de Trigo': 500,
        'Fermento Biológico Seco': 10,
        'Leite Integral': 200,
        'Óleo de Soja': 50,
        'Presunto': 200,
        'Queijo Mussarela': 200,
      }),
      _SeedRecipe('Empada de Frango', 'salgados', 20, 110, 4.0, false, {
        'Farinha de Trigo': 400,
        'Manteiga': 200,
        'Ovo': 1,
        'Sal': 8,
        'Requeijão': 100,
      }),
      _SeedRecipe('Coxinha', 'salgados', 30, 120, 5.0, true, {
        'Farinha de Trigo': 500,
        'Leite Integral': 500,
        'Manteiga': 30,
        'Requeijão': 150,
        'Sal': 10,
      }),
      _SeedRecipe('Chocolate Quente Cremoso', 'bebidas', 10, 140, 1.0, false, {
        'Leite Integral': 1000,
        'Chocolate em Pó 50%': 100,
        'Amido de Milho': 30,
        'Açúcar Refinado': 100,
        'Creme de Leite': 200,
      }),
      _SeedRecipe('Cappuccino Cremoso', 'bebidas', 12, 150, 1.0, false, {
        'Café Solúvel': 40,
        'Chocolate em Pó 50%': 40,
        'Açúcar Refinado': 150,
        'Amido de Milho': 20,
        'Leite Integral': 200,
      }),
    ];

    final nowMs = DateTime.now().millisecondsSinceEpoch;

    for (var i = 0; i < recipeSeed.length; i++) {
      final r = recipeSeed[i];

      final exists = await db.query('recipes',
          columns: ['id'], where: 'name = ?', whereArgs: [r.name], limit: 1);
      if (exists.isNotEmpty) continue;

      final recipeId = 'seed_rec_${seq++}';
      var ingredientsCost = 0.0;
      final riRows = <Map<String, Object?>>[];

      r.items.forEach((ingName, qty) {
        final unitCost = unitCostByName[ingName];
        if (unitCost == null) return;
        final cost = unitCost * qty;
        ingredientsCost += cost;
        riRows.add({
          'recipe_id': recipeId,
          'ingredient_id': idByName[ingName],
          'quantity_used': qty.toDouble(),
          'calculated_ingredient_cost': cost,
        });
      });

      final totalCost = ingredientsCost + r.operationalCost;
      final suggested = totalCost * (1 + r.margin / 100);
      final sellingPrice = ((suggested * 2).ceil()) / 2; // arredonda p/ R$0,50

      await db.insert('recipes', {
        'id': recipeId,
        'name': r.name,
        'profit_margin_percentage': r.margin.toDouble(),
        'additional_operational_cost': r.operationalCost,
        'total_cost': totalCost,
        'suggested_sell_price': suggested,
        'selling_price': sellingPrice,
        'image_path': null,
        'show_in_menu': r.showInMenu ? 1 : 0,
        // espaça as datas em ~1 dia para uma linha do tempo realista
        'created_at': nowMs - i * 86400000,
        'user_id': null,
        'yield_quantity': r.yieldQuantity,
        'category': r.category,
      });

      for (final ri in riRows) {
        await db.insert('recipe_ingredients', ri);
      }
    }
  } catch (e) {
    debugPrint('Erro ao fazer seed: $e');
  }
}

class _SeedRecipe {
  final String name;
  final String category;
  final int yieldQuantity;
  final double margin;
  final double operationalCost;
  final bool showInMenu;

  /// nome do ingrediente -> quantidade usada (na unidade do ingrediente)
  final Map<String, num> items;

  const _SeedRecipe(
    this.name,
    this.category,
    this.yieldQuantity,
    this.margin,
    this.operationalCost,
    this.showInMenu,
    this.items,
  );
}
