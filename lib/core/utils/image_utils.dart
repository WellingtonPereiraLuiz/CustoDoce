import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Resolve a exibição de imagens de receita de forma cross-platform.
/// - Se o path for uma URL HTTP(S), usa Image.network em qualquer plataforma.
/// - Se for um caminho local: usa Image.file apenas no mobile/desktop.
///   Na web, caminhos locais não existem → retorna o placeholder.
class RecipeImage {
  static Widget build({
    required String? imagePath,
    required Widget placeholder,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    if (imagePath == null || imagePath.isEmpty) {
      return placeholder;
    }

    final isUrl = imagePath.startsWith('http://') || imagePath.startsWith('https://');

    if (isUrl) {
      return Image.network(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => placeholder,
      );
    }

    // Caminho local: só funciona fora da web.
    if (kIsWeb) {
      return placeholder;
    }

    return Image.file(
      File(imagePath),
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => placeholder,
    );
  }
}
