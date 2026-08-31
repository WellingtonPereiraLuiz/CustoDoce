import 'dart:convert';
import 'dart:typed_data';

import 'package:custo_doce/core/enums/assistant_action_type.dart';
import 'package:custo_doce/core/enums/assistant_message_role.dart';
import 'package:custo_doce/core/enums/assistant_message_type.dart';
import 'package:custo_doce/core/services/assistant_models.dart';
import 'package:custo_doce/domain/entities/assistant_message_entity.dart';
import 'package:custo_doce/presentation/providers/assistant_provider.dart';
import 'package:custo_doce/core/constants/layout_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();

  Uint8List? _selectedImageBytes;
  String? _selectedImageDataUri;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final file = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null) {
      return;
    }
    final bytes = await file.readAsBytes();
    setState(() {
      _selectedImageBytes = bytes;
      _selectedImageDataUri = 'data:image/jpeg;base64,${base64Encode(bytes)}';
    });
  }

  void _applyQuickAction(String prompt) {
    _controller.text = prompt;
    _controller.selection =
        TextSelection.collapsed(offset: _controller.text.length);
  }

  Future<void> _send() async {
    final imageDataUri = _selectedImageDataUri;
    final text = _controller.text;
    if (text.trim().isEmpty && imageDataUri == null) {
      return;
    }
    _controller.clear();
    setState(() {
      _selectedImageBytes = null;
      _selectedImageDataUri = null;
    });
    await ref.read(assistantProvider.notifier).sendMessage(
          text: text,
          imageDataUri: imageDataUri,
        );
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent + 240,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  Widget _buildDesktop(
      BuildContext context, AsyncValue<AssistantState> assistantAsync) {
    final assistantAsync = ref.watch(assistantProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assistente IA'),
        actions: [
          IconButton(
            tooltip: 'Nova conversa',
            onPressed: assistantAsync.isLoading
                ? null
                : () =>
                    ref.read(assistantProvider.notifier).startNewConversation(),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: assistantAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Erro: $error')),
        data: (assistantState) {
          final theme = Theme.of(context);
          final hasPending = assistantState.pendingResponse != null;
          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                color: theme.colorScheme.surfaceContainerLow,
                child: Text(
                  'Premium: consulta, ingredientes, receitas e nota fiscal por imagem. Alteracoes so acontecem apos confirmacao.',
                  style: theme.textTheme.bodySmall,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: assistantState.messages.length,
                  itemBuilder: (context, index) {
                    final message = assistantState.messages[index];
                    return _MessageBubble(message: message);
                  },
                ),
              ),
              if (hasPending)
                _PendingActionBar(
                  isApplying: assistantState.isApplying,
                  onConfirm: () => ref
                      .read(assistantProvider.notifier)
                      .confirmPendingAction(),
                  onCancel: () => ref
                      .read(assistantProvider.notifier)
                      .cancelPendingAction(),
                ),
              if (_selectedImageBytes != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              _selectedImageBytes!,
                              width: 96,
                              height: 96,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedImageBytes = null;
                                  _selectedImageDataUri = null;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.inverseSurface
                                      .withValues(alpha: 0.7),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close,
                                  size: 14,
                                  color: theme.colorScheme.onInverseSurface,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              if (!hasPending)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ActionChip(
                          avatar:
                              const Icon(Icons.calculate_outlined, size: 16),
                          label: const Text('Calcular Custo'),
                          onPressed: assistantState.isSending
                              ? null
                              : () => _applyQuickAction(
                                  'Ajude-me a calcular o custo de uma receita.'),
                        ),
                        const SizedBox(width: 8),
                        ActionChip(
                          avatar:
                              const Icon(Icons.swap_horiz_rounded, size: 16),
                          label: const Text('Sugerir Substituição'),
                          onPressed: assistantState.isSending
                              ? null
                              : () => _applyQuickAction(
                                  'Sugira uma substituição para um ingrediente da minha receita.'),
                        ),
                        const SizedBox(width: 8),
                        ActionChip(
                          avatar:
                              const Icon(Icons.receipt_long_outlined, size: 16),
                          label: const Text('Ler Nota Fiscal'),
                          onPressed: assistantState.isSending
                              ? null
                              : () async {
                                  await _pickImage();
                                  _applyQuickAction(
                                      'Leia esta nota fiscal e atualize os ingredientes.');
                                },
                        ),
                      ],
                    ),
                  ),
                ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: assistantState.isSending ? null : _pickImage,
                        icon: const Icon(Icons.photo_camera_outlined),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          minLines: 1,
                          maxLines: 4,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _send(),
                          decoration: const InputDecoration(
                            hintText:
                                'Ex.: atualize farinha 1kg para R\$ 6,90 ou crie uma receita...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: assistantState.isSending ? null : _send,
                        child: assistantState.isSending
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.send_rounded),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMobile(
      BuildContext context, AsyncValue<AssistantState> assistantAsync) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.smart_toy,
                size: 16,
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Chef IA',
                    style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary)),
                Text('Assistente de Confeitaria',
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: assistantAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Erro: $error')),
        data: (assistantState) {
          final hasPending = assistantState.pendingResponse != null;
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: assistantState.messages.isEmpty
                      ? 1
                      : assistantState.messages.length,
                  itemBuilder: (context, index) {
                    if (assistantState.messages.isEmpty) {
                      return Column(
                        children: [
                          const SizedBox(height: 24),
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.cake,
                                size: 32,
                                color: theme.colorScheme.onSurfaceVariant),
                          ),
                          const SizedBox(height: 8),
                          Text('Como posso ajudar na sua cozinha hoje?',
                              style: theme.textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center),
                          const SizedBox(height: 4),
                          Text(
                              'Especialista em custos, receitas e notas fiscais.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant),
                              textAlign: TextAlign.center),
                          const SizedBox(height: 32),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                ActionChip(
                                  avatar: const Icon(Icons.calculate_outlined,
                                      size: 16),
                                  label:
                                      const Text('Calcular custo de receita'),
                                  onPressed: () => _applyQuickAction(
                                      'Calcular custo de receita'),
                                ),
                                const SizedBox(width: 8),
                                ActionChip(
                                  avatar: const Icon(
                                      Icons.find_replace_outlined,
                                      size: 16),
                                  label: const Text('Sugerir substituição'),
                                  onPressed: () =>
                                      _applyQuickAction('Sugerir substituição'),
                                ),
                                const SizedBox(width: 8),
                                ActionChip(
                                  avatar: const Icon(
                                      Icons.receipt_long_outlined,
                                      size: 16),
                                  label: const Text('Analisar nota fiscal'),
                                  onPressed: () =>
                                      _applyQuickAction('Analisar nota fiscal'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }
                    return _MessageBubble(
                        message: assistantState.messages[index]);
                  },
                ),
              ),
              if (hasPending)
                _PendingActionBar(
                  isApplying: assistantState.isApplying,
                  onConfirm: () => ref
                      .read(assistantProvider.notifier)
                      .confirmPendingAction(),
                  onCancel: () => ref
                      .read(assistantProvider.notifier)
                      .cancelPendingAction(),
                ),
              if (_selectedImageBytes != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          _selectedImageBytes!,
                          width: 96,
                          height: 96,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedImageBytes = null;
                              _selectedImageDataUri = null;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.inverseSurface
                                  .withValues(alpha: 0.7),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.close,
                                size: 14,
                                color: theme.colorScheme.onInverseSurface),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  border: Border(
                      top: BorderSide(color: theme.colorScheme.surfaceContainerHighest)),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.attach_file),
                            onPressed:
                                assistantState.isSending ? null : _pickImage,
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color:
                                    theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: TextField(
                                controller: _controller,
                                minLines: 1,
                                maxLines: 4,
                                textInputAction: TextInputAction.send,
                                onSubmitted: (_) => _send(),
                                decoration: const InputDecoration(
                                  hintText: 'Digite sua mensagem ou pedido...',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              onPressed:
                                  assistantState.isSending ? null : _send,
                              icon: assistantState.isSending
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2))
                                  : Icon(Icons.send,
                                      color: theme
                                          .colorScheme.onSecondaryContainer),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'IA pode cometer erros. Verifique os cálculos importantes.',
                        style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.5)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final assistantAsync = ref.watch(assistantProvider);
    final isDesktop = MediaQuery.of(context).size.width >= kDesktopBreakpoint;

    if (isDesktop) {
      return _buildDesktop(context, assistantAsync);
    }

    return _buildMobile(context, assistantAsync);
  }
}

class _MessageBubble extends StatelessWidget {
  final AssistantMessageEntity message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == AssistantMessageRole.user;
    final theme = Theme.of(context);
    final metadata = decodeAssistantMetadata(message.metadata);
    final imageDataUri = metadata?['image_data_uri']?.toString();

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isUser
                ? theme.colorScheme.primary
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment:
                isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (imageDataUri != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    _dataUriToBytes(imageDataUri),
                    width: 180,
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 10),
              ],
              Text(
                message.content,
                style: TextStyle(
                  color: isUser
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
                ),
              ),
              if (message.type == AssistantMessageType.actionPreview &&
                  metadata?['preview'] is Map<String, dynamic>) ...[
                const SizedBox(height: 12),
                _PreviewCard(
                  intent: AssistantActionType.fromString(
                    metadata?['intent']?.toString() ?? 'none',
                  ),
                  preview: metadata!['preview'] as Map<String, dynamic>,
                ),
              ],
              const SizedBox(height: 8),
              Text(
                DateFormat('HH:mm').format(message.createdAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isUser
                      ? theme.colorScheme.onPrimary.withValues(alpha: 0.75)
                      : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  final AssistantActionType intent;
  final Map<String, dynamic> preview;

  const _PreviewCard({
    required this.intent,
    required this.preview,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          ..._lines.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(line, style: theme.textTheme.bodyMedium),
            ),
          ),
        ],
      ),
    );
  }

  String get _title {
    switch (intent) {
      case AssistantActionType.createIngredient:
        return 'Previa de novo ingrediente';
      case AssistantActionType.updateIngredient:
        return 'Previa de atualizacao';
      case AssistantActionType.createRecipe:
        return 'Previa de receita';
      case AssistantActionType.invoiceScan:
      case AssistantActionType.bulkIngredientUpdate:
        return 'Previa da nota fiscal';
      case AssistantActionType.consultation:
      case AssistantActionType.none:
        return 'Previa';
    }
  }

  List<String> get _lines {
    switch (intent) {
      case AssistantActionType.createIngredient:
      case AssistantActionType.updateIngredient:
        return [
          'Nome: ${preview['name'] ?? '-'}',
          'Unidade: ${preview['unit'] ?? '-'}',
          'Pacote: ${preview['package_size'] ?? '-'}',
          'Preco: R\$ ${preview['cost_per_package'] ?? '-'}',
          if ((preview['summary'] ?? '').toString().isNotEmpty)
            preview['summary'].toString(),
        ];
      case AssistantActionType.createRecipe:
        final items = (preview['items'] as List<dynamic>? ?? const []);
        return [
          'Nome: ${preview['name'] ?? '-'}',
          'Rendimento: ${preview['yield_quantity'] ?? '-'}',
          'Categoria: ${preview['category'] ?? '-'}',
          'Itens reconhecidos: ${items.length}',
          if ((preview['missing_ingredients'] as List<dynamic>? ?? const [])
              .isNotEmpty)
            'Faltando no catalogo: ${(preview['missing_ingredients'] as List<dynamic>).join(', ')}',
          if ((preview['summary'] ?? '').toString().isNotEmpty)
            preview['summary'].toString(),
        ];
      case AssistantActionType.invoiceScan:
      case AssistantActionType.bulkIngredientUpdate:
        final items = (preview['items'] as List<dynamic>? ?? const []);
        return [
          'Itens sugeridos: ${items.length}',
          if ((preview['summary'] ?? '').toString().isNotEmpty)
            preview['summary'].toString(),
        ];
      case AssistantActionType.consultation:
      case AssistantActionType.none:
        return const ['Sem detalhes estruturados.'];
    }
  }
}

class _PendingActionBar extends StatelessWidget {
  final bool isApplying;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _PendingActionBar({
    required this.isApplying,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: isApplying ? null : onCancel,
              child: const Text('Cancelar'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              onPressed: isApplying ? null : onConfirm,
              child: isApplying
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Confirmar'),
            ),
          ),
        ],
      ),
    );
  }
}

Uint8List _dataUriToBytes(String dataUri) {
  final commaIndex = dataUri.indexOf(',');
  final encoded = commaIndex >= 0 ? dataUri.substring(commaIndex + 1) : dataUri;
  return base64Decode(encoded);
}
