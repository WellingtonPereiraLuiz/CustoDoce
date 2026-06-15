import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class AiService {
  Future<String> sendMessage(String message, {String? imageBase64});
}

class PlaceholderAiService implements AiService {
  @override
  Future<String> sendMessage(String message, {String? imageBase64}) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (imageBase64 != null) {
      return 'Analisei a imagem. Produtos identificados (simulado):\n'
             '• Farinha de trigo 1kg — R\$ 5,50\n'
             '• Açúcar refinado 1kg — R\$ 4,20\n'
             '• Manteiga 200g — R\$ 8,90\n\n'
             'Deseja adicionar esses ingredientes ao seu banco?';
    }
    return 'Olá! Sou o assistente do CustoDoce 🍰\n'
           'Posso te ajudar a:\n'
           '• Calcular custos de receitas\n'
           '• Sugerir preços de venda\n'
           '• Analisar notas fiscais (Premium)\n\n'
           'Me conta o que você precisa!';
  }
}

final aiServiceProvider = Provider<AiService>((ref) => PlaceholderAiService());
