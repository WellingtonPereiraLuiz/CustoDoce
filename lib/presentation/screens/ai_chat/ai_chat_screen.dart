import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:custo_doce/core/providers/subscription_provider.dart';
import 'package:custo_doce/core/models/subscription_plan.dart';
import 'package:custo_doce/core/services/ai_service.dart';

class _ChatMessage {
  final String text;
  final bool isUser;
  final String? imageBase64;
  final DateTime timestamp;

  _ChatMessage({
    required this.text,
    required this.isUser,
    this.imageBase64,
    required this.timestamp,
  });
}

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final List<_ChatMessage> _messages = [];
  final _controller = TextEditingController();
  bool _isLoading = false;

  Widget _buildUpgradeBanner() => Scaffold(
        appBar: AppBar(title: const Text('Assistente CustoDoce')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.auto_awesome_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'O Assistente IA está disponível nos planos Pro e Premium.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.go('/paywall'),
                  child: const Text('Ver planos'),
                ),
              ],
            ),
          ),
        ),
      );

  Future<void> _sendMessage([String? imageBase64]) async {
    final text = _controller.text.trim();
    if (text.isEmpty && imageBase64 == null) return;
    
    _controller.clear();
    setState(() {
      _messages.add(_ChatMessage(
        text: text.isEmpty ? '[imagem]' : text,
        isUser: true,
        imageBase64: imageBase64,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });

    final ai = ref.read(aiServiceProvider);
    final response = await ai.sendMessage(text, imageBase64: imageBase64);

    if (mounted) {
      setState(() {
        _messages.add(_ChatMessage(
          text: response,
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
    }
  }

  Future<void> _pickAndSendImage() async {
    final limits = ref.read(currentPlanProvider);

    if (!limits.hasInvoiceScan) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Análise de nota fiscal é exclusiva do plano Premium.')),
      );
      return;
    }

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 800);
    if (picked == null) return;

    final bytes = await File(picked.path).readAsBytes();
    final base64Img = base64Encode(bytes);
    await _sendMessage(base64Img);
  }

  @override
  Widget build(BuildContext context) {
    final limits = ref.watch(currentPlanProvider);

    if (!limits.hasChatAi) return _buildUpgradeBanner();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assistente CustoDoce'),
        actions: const [
          Icon(Icons.auto_awesome_rounded),
          SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Align(
                  alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: msg.isUser
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      msg.text,
                      style: TextStyle(
                        color: msg.isUser ? Theme.of(context).colorScheme.onPrimary : null,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Digite sua mensagem...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  if (limits.hasInvoiceScan)
                    IconButton(
                      icon: const Icon(Icons.camera_alt),
                      onPressed: _pickAndSendImage,
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.grey),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Análise de nota fiscal é exclusiva do plano Premium.')),
                        );
                      },
                    ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _sendMessage,
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
