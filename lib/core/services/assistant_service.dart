import 'dart:convert';

import 'package:custo_doce/core/constants/app_constants.dart';
import 'package:custo_doce/core/enums/assistant_action_type.dart';
import 'package:custo_doce/core/services/assistant_models.dart';
import 'package:custo_doce/domain/entities/assistant_message_entity.dart';
import 'package:http/http.dart' as http;

class AssistantService {
  final http.Client _client;

  AssistantService({http.Client? client}) : _client = client ?? http.Client();

  bool get isConfigured => AppConstants.openRouterApiKey.isNotEmpty;

  Future<AssistantResponse> sendMessage({
    required String userMessage,
    required List<AssistantMessageEntity> history,
    required AssistantContextSnapshot context,
    String? imageDataUri,
  }) async {
    if (!isConfigured) {
      return const AssistantResponse(
        intent: AssistantActionType.consultation,
        reply:
            'A chave do OpenRouter nao foi configurada. Rode o app com --dart-define=OPENROUTER_API_KEY=...',
        requiresConfirmation: false,
        missingFields: [],
      );
    }

    final body = {
      'model': AppConstants.openRouterModel,
      'temperature': 0.2,
      'response_format': {
        'type': 'json_schema',
        'json_schema': {
          'name': 'assistant_response',
          'strict': true,
          'schema': _responseSchema,
        },
      },
      'messages': [
        {
          'role': 'system',
          'content': _buildSystemPrompt(context),
        },
        ...history.take(12).map((message) => {
              'role': message.role.value,
              'content': message.content,
            }),
        {
          'role': 'user',
          'content': [
            {
              'type': 'text',
              'text': userMessage,
            },
            if (imageDataUri != null)
              {
                'type': 'image_url',
                'image_url': {'url': imageDataUri},
              },
          ],
        },
      ],
    };

    final response = await _client.post(
      Uri.parse('${AppConstants.openRouterBaseUrl}/chat/completions'),
      headers: {
        'Authorization': 'Bearer ${AppConstants.openRouterApiKey}',
        'Content-Type': 'application/json',
        'HTTP-Referer': 'https://custodoce.app',
        'X-Title': AppConstants.appName,
      },
      body: jsonEncode(body),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
          'Falha OpenRouter (${response.statusCode}): ${response.body}');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final content = (((decoded['choices'] as List<dynamic>).first
                as Map<String, dynamic>)['message']
            as Map<String, dynamic>)['content']
        ?.toString();
    if (content == null || content.isEmpty) {
      throw Exception('OpenRouter retornou uma resposta vazia.');
    }
    try {
      final parsed = jsonDecode(content) as Map<String, dynamic>;
      return AssistantResponse.fromJson(parsed);
    } catch (_) {
      final normalized = _extractJsonObject(content);
      final parsed = jsonDecode(normalized) as Map<String, dynamic>;
      return AssistantResponse.fromJson(parsed);
    }
  }

  String _buildSystemPrompt(AssistantContextSnapshot context) {
    return '''
Voce e o Assistente Premium do app CustoDoce.
Responda sempre em portugues do Brasil.
Seu papel e ajudar com:
- consultation
- create_ingredient
- update_ingredient
- create_recipe
- invoice_scan

Regras:
- Nunca invente um ingrediente existente se ele nao estiver no catalogo.
- Toda alteracao de banco exige requires_confirmation=true.
- Se faltarem dados criticos, liste em missing_fields e nao monte uma acao invalida.
- Para receitas, use apenas ingredient_id do catalogo enviado.
- Para nota fiscal, sugira correspondencias somente quando houver boa semelhanca nominal.
- Em consultation, nao proponha acao de escrita.

Contexto do usuario:
${jsonEncode(context.toJson())}

Retorne apenas JSON valido seguindo o schema.
''';
  }

  String _extractJsonObject(String content) {
    final firstBrace = content.indexOf('{');
    final lastBrace = content.lastIndexOf('}');
    if (firstBrace == -1 || lastBrace == -1 || lastBrace <= firstBrace) {
      throw Exception('Nao foi possivel extrair JSON da resposta do modelo.');
    }
    return content.substring(firstBrace, lastBrace + 1);
  }
}

const Map<String, dynamic> _responseSchema = {
  'type': 'object',
  'additionalProperties': false,
  'required': [
    'intent',
    'reply',
    'requires_confirmation',
    'missing_fields',
    'ingredient_draft',
    'recipe_draft',
    'invoice_draft',
  ],
  'properties': {
    'intent': {
      'type': 'string',
      'enum': [
        'consultation',
        'create_ingredient',
        'update_ingredient',
        'create_recipe',
        'invoice_scan',
        'bulk_ingredient_update',
      ],
    },
    'reply': {'type': 'string'},
    'requires_confirmation': {'type': 'boolean'},
    'missing_fields': {
      'type': 'array',
      'items': {'type': 'string'},
    },
    'ingredient_draft': {
      'type': ['object', 'null'],
      'additionalProperties': false,
      'required': [
        'ingredient_id',
        'name',
        'unit',
        'package_size',
        'cost_per_package',
        'summary',
      ],
      'properties': {
        'ingredient_id': {
          'type': ['string', 'null']
        },
        'name': {'type': 'string'},
        'unit': {
          'type': 'string',
          'enum': ['g', 'kg', 'ml', 'L', 'unidade'],
        },
        'package_size': {'type': 'number'},
        'cost_per_package': {'type': 'number'},
        'summary': {'type': 'string'},
      },
    },
    'recipe_draft': {
      'type': ['object', 'null'],
      'additionalProperties': false,
      'required': [
        'name',
        'yield_quantity',
        'category',
        'summary',
        'items',
        'missing_ingredients',
      ],
      'properties': {
        'name': {'type': 'string'},
        'yield_quantity': {'type': 'integer'},
        'category': {
          'type': 'string',
          'enum': [
            'bolo',
            'torta',
            'brigadeiro',
            'cookies',
            'paes',
            'salgados',
            'bebidas',
            'outro',
          ],
        },
        'summary': {'type': 'string'},
        'items': {
          'type': 'array',
          'items': {
            'type': 'object',
            'additionalProperties': false,
            'required': ['ingredient_id', 'quantity_used'],
            'properties': {
              'ingredient_id': {'type': 'string'},
              'quantity_used': {'type': 'number'},
            },
          },
        },
        'missing_ingredients': {
          'type': 'array',
          'items': {'type': 'string'},
        },
      },
    },
    'invoice_draft': {
      'type': ['object', 'null'],
      'additionalProperties': false,
      'required': ['summary', 'items'],
      'properties': {
        'summary': {'type': 'string'},
        'items': {
          'type': 'array',
          'items': {
            'type': 'object',
            'additionalProperties': false,
            'required': [
              'raw_name',
              'ingredient_id',
              'package_size',
              'cost_per_package',
              'suggested_unit',
              'summary',
            ],
            'properties': {
              'raw_name': {'type': 'string'},
              'ingredient_id': {
                'type': ['string', 'null']
              },
              'package_size': {
                'type': ['number', 'null']
              },
              'cost_per_package': {
                'type': ['number', 'null']
              },
              'suggested_unit': {
                'type': ['string', 'null']
              },
              'summary': {'type': 'string'},
            },
          },
        },
      },
    },
  },
};
