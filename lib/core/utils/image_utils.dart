import 'dart:convert';
import 'dart:io' if (dart.library.html) 'package:custo_doce/core/utils/io_stub.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Resolve a exibição de imagens de receita de forma cross-platform.
/// Suporta:
///   - Base64 data URI (data:image/...;base64,...) → Image.memory — web e mobile
///   - URL HTTP(S) → Image.network — qualquer plataforma
///   - Caminho local → Image.file — somente mobile/desktop
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

    // Base64 data URI — funciona web e mobile
    if (imagePath.startsWith('data:image')) {
      try {
        final base64Data = imagePath.split(',').last;
        final bytes = base64Decode(base64Data);
        return Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (_, __, ___) => placeholder,
        );
      } catch (_) {
        return placeholder;
      }
    }

    // URL remota HTTP(S)
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => placeholder,
      );
    }

    // Caminho local: apenas mobile/desktop
    if (kIsWeb) {
      return placeholder;
    }

    return Image.file(
      File(imagePath) as dynamic,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => placeholder,
    );
  }

  /// Converte bytes para data URI base64.
  static String bytesToBase64Uri(Uint8List bytes) {
    return 'data:image/jpeg;base64,${base64Encode(bytes)}';
  }
}
