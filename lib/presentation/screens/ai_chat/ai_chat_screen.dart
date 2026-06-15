import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:custo_doce/core/theme/app_theme.dart';
import 'package:custo_doce/data/remote/gemini_service.dart';
import 'package:custo_doce/presentation/providers/recipe_providers.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

class AiChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  AiChatState({this.messages = const [], this.isLoading = false});
}

class AiChatNotifier extends Notifier<AiChatState> {
  @override
  AiChatState build() => AiChatState();

  Future<void> sendMessage(String text, WidgetRef ref) async {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessage(text: text, isUser: true);
    state = AiChatState(messages: [...state.messages, userMsg], isLoading: true);

    final recipes = ref.read(recipesProvider).value ?? [];
    final contextData = StringBuffer();
    contextData.writeln('Você é o assistente CustoDoce. Aqui estão as receitas do usuário:');
    for (final r in recipes) {
      contextData.writeln('- ${r.name}: Custo R\$${r.totalCost.toStringAsFixed(2)}, Preço Sugerido R\$${r.suggestedSellPrice.toStringAsFixed(2)}');
    }

    final gemini = ref.read(geminiServiceProvider);
    final response = await gemini.askGemini(text, contextData.toString());

    final botMsg = ChatMessage(text: response, isUser: false);
    state = AiChatState(messages: [...state.messages, botMsg], isLoading: false);
  }
}

final aiChatProvider = NotifierProvider<AiChatNotifier, AiChatState>(
  AiChatNotifier.new,
);

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  void _send() {
    final text = _controller.text;
    _controller.clear();
    ref.read(aiChatProvider.notifier).sendMessage(text, ref);
    
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiChatProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assistente CustoDoce'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: state.messages.length,
              itemBuilder: (context, index) {
                final msg = state.messages[index];
                return Align(
                  alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: msg.isUser ? AppTheme.primaryColor : Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    child: Text(
                      msg.text,
                      style: TextStyle(color: msg.isUser ? Colors.white : Theme.of(context).colorScheme.onSurface),
                    ),
                  ),
                );
              },
            ),
          ),
          if (state.isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            color: Theme.of(context).colorScheme.surface,
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Pergunte algo...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    icon: const Icon(Icons.send),
                    onPressed: _send,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
