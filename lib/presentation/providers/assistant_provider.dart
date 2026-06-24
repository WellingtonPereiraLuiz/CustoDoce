import 'dart:convert';

import 'package:custo_doce/core/enums/assistant_action_status.dart';
import 'package:custo_doce/core/enums/assistant_action_type.dart';
import 'package:custo_doce/core/enums/assistant_message_role.dart';
import 'package:custo_doce/core/enums/assistant_message_type.dart';
import 'package:custo_doce/core/enums/unit_of_measure.dart';
import 'package:custo_doce/core/services/assistant_models.dart';
import 'package:custo_doce/core/services/assistant_service.dart';
import 'package:custo_doce/core/utils/uuid_generator.dart';
import 'package:custo_doce/data/local/datasources/local_assistant_datasource.dart';
import 'package:custo_doce/data/local/models/assistant_action_model.dart';
import 'package:custo_doce/data/local/models/assistant_conversation_model.dart';
import 'package:custo_doce/data/local/models/assistant_message_model.dart';
import 'package:custo_doce/domain/entities/assistant_action_entity.dart';
import 'package:custo_doce/domain/entities/assistant_conversation_entity.dart';
import 'package:custo_doce/domain/entities/assistant_message_entity.dart';
import 'package:custo_doce/domain/entities/ingredient_entity.dart';
import 'package:custo_doce/domain/entities/recipe_entity.dart';
import 'package:custo_doce/presentation/providers/ingredient_providers.dart';
import 'package:custo_doce/presentation/providers/recipe_providers.dart';
import 'package:custo_doce/presentation/providers/repository_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AssistantState {
  final AssistantConversationEntity conversation;
  final List<AssistantMessageEntity> messages;
  final AssistantResponse? pendingResponse;
  final bool isSending;
  final bool isApplying;
  final String? errorMessage;

  const AssistantState({
    required this.conversation,
    required this.messages,
    this.pendingResponse,
    this.isSending = false,
    this.isApplying = false,
    this.errorMessage,
  });

  AssistantState copyWith({
    AssistantConversationEntity? conversation,
    List<AssistantMessageEntity>? messages,
    AssistantResponse? Function()? pendingResponse,
    bool? isSending,
    bool? isApplying,
    String? Function()? errorMessage,
  }) {
    return AssistantState(
      conversation: conversation ?? this.conversation,
      messages: messages ?? this.messages,
      pendingResponse:
          pendingResponse != null ? pendingResponse() : this.pendingResponse,
      isSending: isSending ?? this.isSending,
      isApplying: isApplying ?? this.isApplying,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }
}

class AssistantNotifier extends AsyncNotifier<AssistantState> {
  late LocalAssistantDataSource _assistantDataSource;
  late AssistantService _assistantService;

  @override
  Future<AssistantState> build() async {
    _assistantDataSource = ref.watch(localAssistantDataSourceProvider);
    _assistantService = ref.watch(assistantServiceProvider);

    final existing = await _assistantDataSource.getLatestConversation();
    if (existing != null) {
      final messages = await _assistantDataSource.getMessages(existing.id);
      return AssistantState(
        conversation: existing.toEntity(),
        messages: messages.map((message) => message.toEntity()).toList(),
      );
    }

    final now = DateTime.now();
    final conversation = AssistantConversationEntity(
      id: generateUuid(),
      title: 'Assistente Premium',
      createdAt: now,
      updatedAt: now,
    );
    final welcomeMessage = AssistantMessageEntity(
      id: generateUuid(),
      conversationId: conversation.id,
      role: AssistantMessageRole.assistant,
      type: AssistantMessageType.text,
      content:
          'Oi! Posso ajudar com ingredientes, receitas, nota fiscal por imagem e duvidas de confeitaria.',
      createdAt: now,
    );
    await _assistantDataSource.saveConversation(
      AssistantConversationModel.fromEntity(conversation),
    );
    await _assistantDataSource.saveMessage(
      AssistantMessageModel.fromEntity(welcomeMessage),
    );
    return AssistantState(
      conversation: conversation,
      messages: [welcomeMessage],
    );
  }

  Future<void> sendMessage({
    required String text,
    String? imageDataUri,
  }) async {
    final current = state.valueOrNull;
    if (current == null || (text.trim().isEmpty && imageDataUri == null)) {
      return;
    }

    final now = DateTime.now();
    final userMessage = AssistantMessageEntity(
      id: generateUuid(),
      conversationId: current.conversation.id,
      role: AssistantMessageRole.user,
      type: imageDataUri == null
          ? AssistantMessageType.text
          : AssistantMessageType.image,
      content: text.trim().isEmpty
          ? 'Analise esta imagem de nota fiscal.'
          : text.trim(),
      metadata: imageDataUri == null
          ? null
          : buildAssistantMetadata(imageDataUri: imageDataUri),
      createdAt: now,
    );

    final optimisticMessages = [...current.messages, userMessage];
    state = AsyncValue.data(
      current.copyWith(
        messages: optimisticMessages,
        isSending: true,
        pendingResponse: () => null,
        errorMessage: () => null,
      ),
    );
    await _assistantDataSource.saveMessage(
      AssistantMessageModel.fromEntity(userMessage),
    );

    try {
      final ingredients = ref.read(ingredientsProvider).valueOrNull ??
          const <IngredientEntity>[];
      final recipes =
          ref.read(recipesProvider).valueOrNull ?? const <RecipeEntity>[];
      final rawResponse = await _assistantService.sendMessage(
        userMessage: userMessage.content,
        history: current.messages,
        context: AssistantContextSnapshot(
          ingredients: ingredients,
          recipes: recipes
              .take(8)
              .map(
                (recipe) => {
                  'id': recipe.id,
                  'name': recipe.name,
                  'yield_quantity': recipe.yieldQuantity,
                  'category': recipe.category.name,
                  'total_cost': recipe.totalCost,
                  'suggested_sell_price': recipe.suggestedSellPrice,
                },
              )
              .toList(),
        ),
        imageDataUri: imageDataUri,
      );
      final response = _resolveIngredientIntent(rawResponse, ingredients);

      final assistantMessage = AssistantMessageEntity(
        id: generateUuid(),
        conversationId: current.conversation.id,
        role: AssistantMessageRole.assistant,
        type: response.requiresConfirmation
            ? AssistantMessageType.actionPreview
            : AssistantMessageType.text,
        content: response.reply,
        metadata: _buildPreviewMetadata(response),
        createdAt: DateTime.now(),
      );

      final updatedConversation = current.conversation.copyWith(
        lastIntent: () => response.intent.value,
        updatedAt: DateTime.now(),
      );
      await _assistantDataSource.saveMessage(
        AssistantMessageModel.fromEntity(assistantMessage),
      );
      await _assistantDataSource.updateConversation(
        AssistantConversationModel.fromEntity(updatedConversation),
      );

      state = AsyncValue.data(
        current.copyWith(
          conversation: updatedConversation,
          messages: [...optimisticMessages, assistantMessage],
          pendingResponse:
              response.requiresConfirmation ? () => response : () => null,
          isSending: false,
        ),
      );
    } catch (error) {
      final failureMessage = AssistantMessageEntity(
        id: generateUuid(),
        conversationId: current.conversation.id,
        role: AssistantMessageRole.assistant,
        type: AssistantMessageType.text,
        content:
            'Nao consegui concluir essa solicitacao agora. Detalhe: $error',
        createdAt: DateTime.now(),
      );
      await _assistantDataSource.saveMessage(
        AssistantMessageModel.fromEntity(failureMessage),
      );
      state = AsyncValue.data(
        current.copyWith(
          messages: [...optimisticMessages, failureMessage],
          isSending: false,
          errorMessage: () => error.toString(),
        ),
      );
    }
  }

  Future<void> confirmPendingAction() async {
    final current = state.valueOrNull;
    final pending = current?.pendingResponse;
    if (current == null || pending == null) {
      return;
    }

    state = AsyncValue.data(
      current.copyWith(isApplying: true, errorMessage: () => null),
    );

    try {
      final resultSummary = await _applyPendingResponse(
        pending,
        current.conversation.id,
      );

      final resultMessage = AssistantMessageEntity(
        id: generateUuid(),
        conversationId: current.conversation.id,
        role: AssistantMessageRole.assistant,
        type: AssistantMessageType.actionResult,
        content: resultSummary,
        createdAt: DateTime.now(),
      );
      await _assistantDataSource.saveMessage(
        AssistantMessageModel.fromEntity(resultMessage),
      );
      state = AsyncValue.data(
        current.copyWith(
          messages: [...current.messages, resultMessage],
          pendingResponse: () => null,
          isApplying: false,
        ),
      );
    } catch (error) {
      state = AsyncValue.data(
        current.copyWith(
          isApplying: false,
          errorMessage: () => error.toString(),
        ),
      );
    }
  }

  Future<void> cancelPendingAction() async {
    final current = state.valueOrNull;
    final pending = current?.pendingResponse;
    if (current == null || pending == null) {
      return;
    }
    final message = AssistantMessageEntity(
      id: generateUuid(),
      conversationId: current.conversation.id,
      role: AssistantMessageRole.assistant,
      type: AssistantMessageType.actionResult,
      content: 'Tudo bem. Nao apliquei essa alteracao.',
      createdAt: DateTime.now(),
    );
    await _assistantDataSource.saveMessage(
      AssistantMessageModel.fromEntity(message),
    );
    await _assistantDataSource.saveAction(
      AssistantActionModel.fromEntity(
        AssistantActionEntity(
          id: generateUuid(),
          conversationId: current.conversation.id,
          type: pending.intent,
          status: AssistantActionStatus.cancelled,
          summary: 'Acao cancelada pelo usuario',
          payload: _encodeResponsePayload(pending),
          createdAt: DateTime.now(),
        ),
      ),
    );
    state = AsyncValue.data(
      current.copyWith(
        messages: [...current.messages, message],
        pendingResponse: () => null,
      ),
    );
  }

  Future<void> startNewConversation() async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    await _assistantDataSource.clearConversation(current.conversation.id);
    ref.invalidateSelf();
  }

  Future<String> _applyPendingResponse(
    AssistantResponse response,
    String conversationId,
  ) async {
    switch (response.intent) {
      case AssistantActionType.createIngredient:
      case AssistantActionType.updateIngredient:
        return _applyIngredientDraft(response, conversationId);
      case AssistantActionType.createRecipe:
        return _applyRecipeDraft(response, conversationId);
      case AssistantActionType.invoiceScan:
      case AssistantActionType.bulkIngredientUpdate:
        return _applyInvoiceDraft(response, conversationId);
      case AssistantActionType.consultation:
      case AssistantActionType.none:
        return 'Essa resposta nao exigia alteracao no banco.';
    }
  }

  Future<String> _applyIngredientDraft(
    AssistantResponse response,
    String conversationId,
  ) async {
    final draft = response.ingredientDraft;
    if (draft == null) {
      throw Exception('Previa de ingrediente ausente.');
    }
    final notifier = ref.read(ingredientsProvider.notifier);
    final latestIngredients =
        ref.read(ingredientsProvider).valueOrNull ?? const <IngredientEntity>[];
    final matched = _findIngredientMatch(draft.name, latestIngredients);
    final shouldUpdate =
        response.intent == AssistantActionType.updateIngredient ||
            (matched != null && matched.score >= 0.85);
    final target = shouldUpdate
        ? (matched?.ingredient ??
            _findById(draft.ingredientId, latestIngredients))
        : null;
    final id = target?.id ?? draft.ingredientId ?? generateUuid();
    final entity = IngredientEntity(
      id: id,
      name: draft.name,
      unitOfMeasure: draft.unit,
      packageSize: draft.packageSize,
      costPerPackage: draft.costPerPackage,
      calculatedUnitCost: draft.calculatedUnitCost,
    );
    if (shouldUpdate && target != null) {
      await notifier.updateIngredient(entity);
    } else {
      await notifier.saveIngredient(entity);
    }
    await _assistantDataSource.saveAction(
      AssistantActionModel.fromEntity(
        AssistantActionEntity(
          id: generateUuid(),
          conversationId: conversationId,
          type: shouldUpdate
              ? AssistantActionType.updateIngredient
              : AssistantActionType.createIngredient,
          status: AssistantActionStatus.confirmed,
          summary: draft.summary,
          payload: jsonEncode(draft.toJson()),
          targetId: id,
          createdAt: DateTime.now(),
        ),
      ),
    );
    return shouldUpdate
        ? 'Ingrediente atualizado com sucesso: ${draft.name}.'
        : 'Ingrediente criado com sucesso: ${draft.name}.';
  }

  Future<String> _applyRecipeDraft(
    AssistantResponse response,
    String conversationId,
  ) async {
    final draft = response.recipeDraft;
    if (draft == null) {
      throw Exception('Previa de receita ausente.');
    }
    if (draft.items.isEmpty) {
      throw Exception('A receita nao possui ingredientes validos para salvar.');
    }
    final ingredients =
        ref.read(ingredientsProvider).valueOrNull ?? const <IngredientEntity>[];
    final recipeItems = buildRecipeIngredientEntries(draft, ingredients);
    if (recipeItems.isEmpty) {
      throw Exception(
          'Nenhum ingrediente da receita foi localizado no catalogo.');
    }
    final totalCost = recipeItems.fold<double>(
      0,
      (sum, item) => sum + item.calculatedIngredientCost,
    );
    final recipe = RecipeEntity(
      id: generateUuid(),
      name: draft.name,
      profitMarginPercentage: 50,
      additionalOperationalCost: 0,
      totalCost: totalCost,
      suggestedSellPrice: totalCost * 1.5,
      createdAt: DateTime.now(),
      ingredients: recipeItems
          .map((item) => item.copyWith(recipeId: 'pending'))
          .toList(),
      yieldQuantity: draft.yieldQuantity,
      category: draft.category,
    );
    final normalizedRecipe = recipe.copyWith(
      ingredients: recipe.ingredients
          .map((item) => item.copyWith(recipeId: recipe.id))
          .toList(),
    );
    await ref.read(recipesProvider.notifier).saveRecipe(normalizedRecipe);
    await _assistantDataSource.saveAction(
      AssistantActionModel.fromEntity(
        AssistantActionEntity(
          id: generateUuid(),
          conversationId: conversationId,
          type: response.intent,
          status: AssistantActionStatus.confirmed,
          summary: draft.summary,
          payload: jsonEncode(draft.toJson()),
          targetId: normalizedRecipe.id,
          createdAt: DateTime.now(),
        ),
      ),
    );
    return 'Receita criada com sucesso: ${draft.name}.';
  }

  Future<String> _applyInvoiceDraft(
    AssistantResponse response,
    String conversationId,
  ) async {
    final draft = response.invoiceDraft;
    if (draft == null || draft.items.isEmpty) {
      throw Exception('Nenhuma sugestao de nota fiscal foi encontrada.');
    }
    final existingIngredients =
        ref.read(ingredientsProvider).valueOrNull ?? const <IngredientEntity>[];
    final ingredientMap = {
      for (final item in existingIngredients) item.id: item
    };
    var updatedCount = 0;
    for (final item in draft.items) {
      final ingredientId = item.ingredientId;
      if (ingredientId == null) {
        continue;
      }
      final existing = ingredientMap[ingredientId];
      if (existing == null ||
          item.packageSize == null ||
          item.costPerPackage == null ||
          item.suggestedUnit == null) {
        continue;
      }
      final unit = _safeUnit(item.suggestedUnit!);
      final updated = IngredientEntity(
        id: existing.id,
        name: existing.name,
        unitOfMeasure: unit,
        packageSize: item.packageSize!,
        costPerPackage: item.costPerPackage!,
        calculatedUnitCost: item.costPerPackage! / item.packageSize!,
      );
      await ref.read(ingredientsProvider.notifier).updateIngredient(updated);
      updatedCount++;
    }
    await _assistantDataSource.saveAction(
      AssistantActionModel.fromEntity(
        AssistantActionEntity(
          id: generateUuid(),
          conversationId: conversationId,
          type: response.intent,
          status: AssistantActionStatus.confirmed,
          summary: draft.summary,
          payload: jsonEncode(draft.toJson()),
          createdAt: DateTime.now(),
        ),
      ),
    );
    return updatedCount == 0
        ? 'Nenhum ingrediente foi atualizado a partir da nota fiscal.'
        : '$updatedCount ingrediente(s) foram atualizados com base na nota fiscal.';
  }

  String? _buildPreviewMetadata(AssistantResponse response) {
    Map<String, dynamic>? preview;
    if (response.ingredientDraft != null) {
      preview = response.ingredientDraft!.toJson();
    } else if (response.recipeDraft != null) {
      preview = response.recipeDraft!.toJson();
    } else if (response.invoiceDraft != null) {
      preview = response.invoiceDraft!.toJson();
    }
    if (preview == null) {
      return null;
    }
    return buildAssistantMetadata(intent: response.intent, preview: preview);
  }

  String _encodeResponsePayload(AssistantResponse response) {
    return jsonEncode({
      'intent': response.intent.value,
      'reply': response.reply,
      'requires_confirmation': response.requiresConfirmation,
      'missing_fields': response.missingFields,
      'ingredient_draft': response.ingredientDraft?.toJson(),
      'recipe_draft': response.recipeDraft?.toJson(),
      'invoice_draft': response.invoiceDraft?.toJson(),
    });
  }

  UnitOfMeasure _safeUnit(String value) {
    return UnitOfMeasure.fromString(value);
  }

  AssistantResponse _resolveIngredientIntent(
    AssistantResponse response,
    List<IngredientEntity> ingredients,
  ) {
    final draft = response.ingredientDraft;
    if (draft == null ||
        (response.intent != AssistantActionType.createIngredient &&
            response.intent != AssistantActionType.updateIngredient)) {
      return response;
    }

    final match = _findIngredientMatch(draft.name, ingredients);
    if (match == null || match.score < 0.85) {
      return response;
    }

    final current = match.ingredient;
    final summary =
        'Ingrediente encontrado: ${current.name}. Valor atual: R\$ ${_money(current.costPerPackage)} por ${_measure(current.packageSize, current.unitOfMeasure.label)}. Novo valor: R\$ ${_money(draft.costPerPackage)} por ${_measure(draft.packageSize, draft.unit.label)}.';
    final reply =
        'Encontrei um ingrediente existente e vou tratar isso como atualizacao de valor. ${current.name} hoje custa R\$ ${_money(current.costPerPackage)} por ${_measure(current.packageSize, current.unitOfMeasure.label)}. O novo valor informado e R\$ ${_money(draft.costPerPackage)} por ${_measure(draft.packageSize, draft.unit.label)}. Deseja atualizar esse ingrediente?';

    return response.copyWith(
      intent: AssistantActionType.updateIngredient,
      reply: reply,
      requiresConfirmation: true,
      ingredientDraft: () => draft.copyWith(
        ingredientId: () => current.id,
        name: current.name,
        summary: summary,
      ),
    );
  }

  IngredientMatchResult? _findIngredientMatch(
    String name,
    List<IngredientEntity> ingredients,
  ) {
    return findBestIngredientMatch(name, ingredients);
  }

  IngredientEntity? _findById(String? id, List<IngredientEntity> ingredients) {
    if (id == null) {
      return null;
    }
    for (final ingredient in ingredients) {
      if (ingredient.id == id) {
        return ingredient;
      }
    }
    return null;
  }

  String _money(double value) {
    return value.toStringAsFixed(2).replaceAll('.', ',');
  }

  String _measure(double size, String unit) {
    final amount =
        size % 1 == 0 ? size.toStringAsFixed(0) : size.toStringAsFixed(2);
    return '$amount$unit';
  }
}

final assistantProvider =
    AsyncNotifierProvider<AssistantNotifier, AssistantState>(
  AssistantNotifier.new,
);
