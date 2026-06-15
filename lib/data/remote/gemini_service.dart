import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GeminiService {
  late final GenerativeModel _model;

  GeminiService() {
    // For tests, you should provide an API key. 
    // Usually this comes from an environment variable.
    const apiKey = 'API_KEY'; 
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );
  }

  Future<String> askGemini(String prompt, String contextData) async {
    try {
      final fullPrompt = '$contextData\n\nUsuário: $prompt';
      final response = await _model.generateContent([Content.text(fullPrompt)]);
      return response.text ?? 'Sem resposta.';
    } catch (e) {
      return 'Erro ao contatar a IA: $e';
    }
  }
}

final geminiServiceProvider = Provider<GeminiService>((ref) {
  return GeminiService();
});
