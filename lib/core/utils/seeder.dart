import 'package:custo_doce/data/local/database/database_helper.dart';
import 'package:flutter/foundation.dart';

Future<void> seedDatabase() async {
  try {
    final db = await DatabaseHelper.instance.database;
    
    final countResult = await db.rawQuery('SELECT COUNT(*) as count FROM ingredients WHERE name = ?', ['Leite Condensado']);
    final count = countResult.first['count'] as int;
    if (count > 0) return;

    String generateId() => DateTime.now().microsecondsSinceEpoch.toString();

    final leiteCondId = generateId() + '1';
    final farinhaId = generateId() + '2';
    final ovoId = generateId() + '3';
    final acucarId = generateId() + '4';
    final leiteId = generateId() + '5';

    final ingredients = [
      [leiteCondId, 'Leite Condensado', 'g', 450.0, 7.00, 7.00/450.0, null],
      [farinhaId, 'Farinha de Trigo', 'g', 1000.0, 5.50, 5.50/1000.0, null],
      [ovoId, 'Ovo', 'unidade', 12.0, 10.0, 10.0/12.0, null],
      [acucarId, 'Açúcar', 'g', 1000.0, 4.00, 4.00/1000.0, null],
      [leiteId, 'Leite', 'ml', 1000.0, 5.00, 5.00/1000.0, null],
    ];

    for (final ing in ingredients) {
      await db.insert('ingredients', {
        'id': ing[0],
        'name': ing[1],
        'unit_of_measure': ing[2],
        'package_size': ing[3],
        'cost_per_package': ing[4],
        'calculated_unit_cost': ing[5],
        'user_id': ing[6],
      });
    }

    final recipeId = generateId() + '6';
    final totalCost = (10.0/12.0)*3 + (5.50/1000.0)*300 + (4.00/1000.0)*200 + (5.00/1000.0)*200; 
    final suggestedPrice = totalCost + (totalCost * 0.50); 
    
    await db.insert('recipes', {
      'id': recipeId,
      'name': 'Bolo Simples de Trigo',
      'profit_margin_percentage': 50.0,
      'additional_operational_cost': 0.0,
      'total_cost': totalCost,
      'suggested_sell_price': suggestedPrice,
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'user_id': null,
    });

    final recipeIngredients = [
      [recipeId, ovoId, 3.0, (10.0/12.0)*3],
      [recipeId, farinhaId, 300.0, (5.50/1000.0)*300],
      [recipeId, acucarId, 200.0, (4.00/1000.0)*200],
      [recipeId, leiteId, 200.0, (5.00/1000.0)*200],
    ];

    for (final ri in recipeIngredients) {
      await db.insert('recipe_ingredients', {
        'recipe_id': ri[0],
        'ingredient_id': ri[1],
        'quantity_used': ri[2],
        'calculated_ingredient_cost': ri[3],
      });
    }
  } catch (e) {
    debugPrint('Erro ao fazer seed: $e');
  }
}
