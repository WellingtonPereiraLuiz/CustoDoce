import 'dart:convert';

import 'package:custo_doce/core/enums/assistant_action_type.dart';
import 'package:custo_doce/core/enums/recipe_category.dart';
import 'package:custo_doce/core/enums/unit_of_measure.dart';
import 'package:custo_doce/domain/entities/ingredient_entity.dart';
import 'package:custo_doce/domain/entities/recipe_ingredient_entity.dart';

class AssistantResponse {
  final AssistantActionType intent;
  final String reply;
  final bool requiresConfirmation;
  final List<String> missingFields;
  final IngredientDraft? ingredientDraft;
  final RecipeDraft? recipeDraft;
  final InvoiceDraft? invoiceDraft;

  const AssistantResponse({
    required this.intent,
    required this.reply,
    required this.requiresConfirmation,
    required this.missingFields,
    this.ingredientDraft,
    this.recipeDraft,
    this.invoiceDraft,
  });

  factory AssistantResponse.fromJson(Map<String, dynamic> json) {
    return AssistantResponse(
      intent: AssistantActionType.fromString(
        json['intent']?.toString() ?? 'consultation',
      ),
      reply:
          json['reply']?.toString() ?? 'Nao consegui interpretar a resposta.',
      requiresConfirmation: json['requires_confirmation'] == true,
      missingFields: (json['missing_fields'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      ingredientDraft: json['ingredient_draft'] is Map<String, dynamic>
          ? IngredientDraft.fromJson(
              json['ingredient_draft'] as Map<String, dynamic>,
            )
          : null,
      recipeDraft: json['recipe_draft'] is Map<String, dynamic>
          ? RecipeDraft.fromJson(json['recipe_draft'] as Map<String, dynamic>)
          : null,
      invoiceDraft: json['invoice_draft'] is Map<String, dynamic>
          ? InvoiceDraft.fromJson(
              json['invoice_draft'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  AssistantResponse copyWith({
    AssistantActionType? intent,
    String? reply,
    bool? requiresConfirmation,
    List<String>? missingFields,
    IngredientDraft? Function()? ingredientDraft,
    RecipeDraft? Function()? recipeDraft,
    InvoiceDraft? Function()? invoiceDraft,
  }) {
    return AssistantResponse(
      intent: intent ?? this.intent,
      reply: reply ?? this.reply,
      requiresConfirmation: requiresConfirmation ?? this.requiresConfirmation,
      missingFields: missingFields ?? this.missingFields,
      ingredientDraft:
          ingredientDraft != null ? ingredientDraft() : this.ingredientDraft,
      recipeDraft: recipeDraft != null ? recipeDraft() : this.recipeDraft,
      invoiceDraft: invoiceDraft != null ? invoiceDraft() : this.invoiceDraft,
    );
  }
}

class IngredientDraft {
  final String? ingredientId;
  final String name;
  final UnitOfMeasure unit;
  final double packageSize;
  final double costPerPackage;
  final String summary;

  const IngredientDraft({
    this.ingredientId,
    required this.name,
    required this.unit,
    required this.packageSize,
    required this.costPerPackage,
    required this.summary,
  });

  double get calculatedUnitCost {
    if (packageSize <= 0) {
      return 0;
    }
    return costPerPackage / packageSize;
  }

  factory IngredientDraft.fromJson(Map<String, dynamic> json) {
    return IngredientDraft(
      ingredientId: json['ingredient_id']?.toString(),
      name: json['name']?.toString() ?? '',
      unit: UnitOfMeasure.fromString(json['unit']?.toString() ?? 'unidade'),
      packageSize: _toDouble(json['package_size']),
      costPerPackage: _toDouble(json['cost_per_package']),
      summary: json['summary']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ingredient_id': ingredientId,
      'name': name,
      'unit': unit.label,
      'package_size': packageSize,
      'cost_per_package': costPerPackage,
      'summary': summary,
    };
  }

  IngredientDraft copyWith({
    String? Function()? ingredientId,
    String? name,
    UnitOfMeasure? unit,
    double? packageSize,
    double? costPerPackage,
    String? summary,
  }) {
    return IngredientDraft(
      ingredientId: ingredientId != null ? ingredientId() : this.ingredientId,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      packageSize: packageSize ?? this.packageSize,
      costPerPackage: costPerPackage ?? this.costPerPackage,
      summary: summary ?? this.summary,
    );
  }
}

class RecipeDraft {
  final String name;
  final int yieldQuantity;
  final RecipeCategory category;
  final String summary;
  final List<RecipeDraftItem> items;
  final List<String> missingIngredients;

  const RecipeDraft({
    required this.name,
    required this.yieldQuantity,
    required this.category,
    required this.summary,
    required this.items,
    required this.missingIngredients,
  });

  factory RecipeDraft.fromJson(Map<String, dynamic> json) {
    return RecipeDraft(
      name: json['name']?.toString() ?? '',
      yieldQuantity: (json['yield_quantity'] as num?)?.toInt() ?? 1,
      category: RecipeCategory.fromString(
        json['category']?.toString() ?? 'outro',
      ),
      summary: json['summary']?.toString() ?? '',
      items: (json['items'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(RecipeDraftItem.fromJson)
          .toList(),
      missingIngredients:
          (json['missing_ingredients'] as List<dynamic>? ?? const [])
              .map((item) => item.toString())
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'yield_quantity': yieldQuantity,
      'category': category.name,
      'summary': summary,
      'items': items.map((item) => item.toJson()).toList(),
      'missing_ingredients': missingIngredients,
    };
  }
}

class RecipeDraftItem {
  final String ingredientId;
  final double quantityUsed;

  const RecipeDraftItem({
    required this.ingredientId,
    required this.quantityUsed,
  });

  factory RecipeDraftItem.fromJson(Map<String, dynamic> json) {
    return RecipeDraftItem(
      ingredientId: json['ingredient_id']?.toString() ?? '',
      quantityUsed: _toDouble(json['quantity_used']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ingredient_id': ingredientId,
      'quantity_used': quantityUsed,
    };
  }
}

class InvoiceDraft {
  final String summary;
  final List<InvoiceDraftItem> items;

  const InvoiceDraft({
    required this.summary,
    required this.items,
  });

  factory InvoiceDraft.fromJson(Map<String, dynamic> json) {
    return InvoiceDraft(
      summary: json['summary']?.toString() ?? '',
      items: (json['items'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(InvoiceDraftItem.fromJson)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'summary': summary,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

class InvoiceDraftItem {
  final String rawName;
  final String? ingredientId;
  final double? packageSize;
  final double? costPerPackage;
  final String? suggestedUnit;
  final String summary;

  const InvoiceDraftItem({
    required this.rawName,
    this.ingredientId,
    this.packageSize,
    this.costPerPackage,
    this.suggestedUnit,
    required this.summary,
  });

  factory InvoiceDraftItem.fromJson(Map<String, dynamic> json) {
    return InvoiceDraftItem(
      rawName: json['raw_name']?.toString() ?? '',
      ingredientId: json['ingredient_id']?.toString(),
      packageSize:
          json['package_size'] == null ? null : _toDouble(json['package_size']),
      costPerPackage: json['cost_per_package'] == null
          ? null
          : _toDouble(json['cost_per_package']),
      suggestedUnit: json['suggested_unit']?.toString(),
      summary: json['summary']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'raw_name': rawName,
      'ingredient_id': ingredientId,
      'package_size': packageSize,
      'cost_per_package': costPerPackage,
      'suggested_unit': suggestedUnit,
      'summary': summary,
    };
  }
}

class AssistantContextSnapshot {
  final List<IngredientEntity> ingredients;
  final List<Map<String, dynamic>> recipes;

  const AssistantContextSnapshot({
    required this.ingredients,
    required this.recipes,
  });

  Map<String, dynamic> toJson() {
    return {
      'ingredients': ingredients
          .map((ingredient) => {
                'id': ingredient.id,
                'name': ingredient.name,
                'unit': ingredient.unitOfMeasure.label,
                'package_size': ingredient.packageSize,
                'cost_per_package': ingredient.costPerPackage,
                'unit_cost': ingredient.calculatedUnitCost,
              })
          .toList(),
      'recipes': recipes,
    };
  }
}

String buildAssistantMetadata({
  AssistantActionType? intent,
  Map<String, dynamic>? preview,
  String? imageDataUri,
}) {
  return jsonEncode({
    if (intent != null) 'intent': intent.value,
    if (preview != null) 'preview': preview,
    if (imageDataUri != null) 'image_data_uri': imageDataUri,
  });
}

Map<String, dynamic>? decodeAssistantMetadata(String? metadata) {
  if (metadata == null || metadata.isEmpty) {
    return null;
  }
  try {
    return jsonDecode(metadata) as Map<String, dynamic>;
  } catch (_) {
    return null;
  }
}

List<RecipeIngredientEntity> buildRecipeIngredientEntries(
  RecipeDraft draft,
  List<IngredientEntity> catalog,
) {
  final map = {for (final item in catalog) item.id: item};
  final entries = <RecipeIngredientEntity>[];
  for (final item in draft.items) {
    final ingredient = map[item.ingredientId];
    if (ingredient == null) {
      continue;
    }
    entries.add(
      RecipeIngredientEntity(
        recipeId: '',
        ingredientId: ingredient.id,
        ingredientName: ingredient.name,
        ingredientUnit: ingredient.unitOfMeasure.label,
        quantityUsed: item.quantityUsed,
        calculatedIngredientCost:
            item.quantityUsed * ingredient.calculatedUnitCost,
      ),
    );
  }
  return entries;
}

double _toDouble(Object? value) {
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

class IngredientMatchResult {
  final IngredientEntity ingredient;
  final double score;

  const IngredientMatchResult({
    required this.ingredient,
    required this.score,
  });
}

IngredientMatchResult? findBestIngredientMatch(
  String inputName,
  List<IngredientEntity> catalog,
) {
  if (inputName.trim().isEmpty || catalog.isEmpty) {
    return null;
  }

  IngredientMatchResult? best;
  final normalizedInput = _normalizeIngredientName(inputName);
  for (final ingredient in catalog) {
    final normalizedCandidate = _normalizeIngredientName(ingredient.name);
    final score =
        _ingredientSimilarityScore(normalizedInput, normalizedCandidate);
    if (best == null || score > best.score) {
      best = IngredientMatchResult(ingredient: ingredient, score: score);
    }
  }

  return best;
}

String normalizeIngredientName(String input) => _normalizeIngredientName(input);

double ingredientSimilarityScore(String a, String b) =>
    _ingredientSimilarityScore(
        _normalizeIngredientName(a), _normalizeIngredientName(b));

String _normalizeIngredientName(String input) {
  final lower = input.toLowerCase();
  const accents = {
    'á': 'a',
    'à': 'a',
    'â': 'a',
    'ã': 'a',
    'ä': 'a',
    'é': 'e',
    'ê': 'e',
    'è': 'e',
    'ë': 'e',
    'í': 'i',
    'ì': 'i',
    'î': 'i',
    'ï': 'i',
    'ó': 'o',
    'ò': 'o',
    'ô': 'o',
    'õ': 'o',
    'ö': 'o',
    'ú': 'u',
    'ù': 'u',
    'û': 'u',
    'ü': 'u',
    'ç': 'c',
  };
  final buffer = StringBuffer();
  for (final rune in lower.runes) {
    final char = String.fromCharCode(rune);
    buffer.write(accents[char] ?? char);
  }

  final cleaned = buffer
      .toString()
      .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  final tokens = cleaned
      .split(' ')
      .where((token) => token.isNotEmpty)
      .map(_singularizeToken)
      .toSet()
      .toList()
    ..sort();
  return tokens.join(' ');
}

String _singularizeToken(String token) {
  if (token.length > 4 && token.endsWith('es')) {
    return token.substring(0, token.length - 2);
  }
  if (token.length > 3 && token.endsWith('s')) {
    return token.substring(0, token.length - 1);
  }
  return token;
}

double _ingredientSimilarityScore(String a, String b) {
  if (a.isEmpty || b.isEmpty) {
    return 0;
  }
  if (a == b) {
    return 1;
  }
  if (a.contains(b) || b.contains(a)) {
    return 0.92;
  }

  final aTokens = a.split(' ').where((token) => token.isNotEmpty).toSet();
  final bTokens = b.split(' ').where((token) => token.isNotEmpty).toSet();
  final intersection = aTokens.intersection(bTokens).length;
  final union = aTokens.union(bTokens).length;
  final jaccard = union == 0 ? 0 : intersection / union;

  final maxLength = a.length > b.length ? a.length : b.length;
  final distance = _levenshtein(a, b);
  final normalizedDistance = maxLength == 0 ? 0 : distance / maxLength;
  final editScore = 1 - normalizedDistance;

  return (jaccard * 0.65) + (editScore * 0.35);
}

int _levenshtein(String a, String b) {
  final rows = a.length + 1;
  final cols = b.length + 1;
  final matrix = List.generate(
    rows,
    (_) => List<int>.filled(cols, 0),
  );

  for (var i = 0; i < rows; i++) {
    matrix[i][0] = i;
  }
  for (var j = 0; j < cols; j++) {
    matrix[0][j] = j;
  }

  for (var i = 1; i < rows; i++) {
    for (var j = 1; j < cols; j++) {
      final cost = a[i - 1] == b[j - 1] ? 0 : 1;
      matrix[i][j] = [
        matrix[i - 1][j] + 1,
        matrix[i][j - 1] + 1,
        matrix[i - 1][j - 1] + cost,
      ].reduce((left, right) => left < right ? left : right);
    }
  }

  return matrix[a.length][b.length];
}
