import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:go_router/go_router.dart';

import 'package:custo_doce/presentation/providers/recipe_providers.dart';
import 'package:custo_doce/core/providers/subscription_provider.dart';
import 'package:custo_doce/core/models/subscription_plan.dart';
import 'package:custo_doce/core/utils/price_utils.dart';
import 'package:custo_doce/domain/entities/recipe_entity.dart';

class DigitalMenuScreen extends ConsumerStatefulWidget {
  const DigitalMenuScreen({super.key});

  @override
  ConsumerState<DigitalMenuScreen> createState() => _DigitalMenuScreenState();
}

class _DigitalMenuScreenState extends ConsumerState<DigitalMenuScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();

  void _showUpgradeDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Funcionalidade Premium'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              ctx.pop();
              context.go('/plans'); // Ou /paywall dependendo da rota correta
            },
            child: const Text('Ver planos'),
          ),
        ],
      ),
    );
  }

  void _shareAsText(List<RecipeEntity> recipes) {
    final buffer = StringBuffer();
    buffer.writeln('🍰 Cardápio');
    buffer.writeln('─────────────────────────');
    for (final r in recipes) {
      final price = r.sellingPrice ?? PriceUtils.roundSuggestedPrice(r.suggestedSellPrice);
      buffer.writeln('•  — R\$ ');
    }
    buffer.writeln('─────────────────────────');
    buffer.writeln('Feito com CustoDoce 🎂');
    Share.share(buffer.toString(), subject: 'Cardápio');
  }

  Future<void> _exportAsJpg() async {
    final image = await _screenshotController.capture(pixelRatio: 2.0);
    if (image == null) return;
    final dir = await getTemporaryDirectory();
    final file = await File('\/cardapio_custodoce.png').writeAsBytes(image);
    await Share.shareXFiles([XFile(file.path)], text: 'Cardápio CustoDoce');
  }

  Future<void> _exportAsPdf(List<RecipeEntity> recipes) async {
    final doc = pw.Document();
    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (ctx) => [
        pw.Header(level: 0, child: pw.Text('Cardápio', style: pw.TextStyle(fontSize: 28))),
        pw.SizedBox(height: 16),
        ...recipes.map((r) {
          final price = r.sellingPrice ?? PriceUtils.roundSuggestedPrice(r.suggestedSellPrice);
          return pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 12),
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(border: pw.Border.all()),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(r.name, style: pw.TextStyle(fontSize: 16)),
                pw.Text('R\$ ${price.toStringAsFixed(2)}',
                    style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              ],
            ),
          );
        }),
      ],
    ));
    await Printing.layoutPdf(onLayout: (_) async => doc.save());
  }

  Widget _buildUpgradeBanner(BuildContext context, String message) => Scaffold(
    appBar: AppBar(title: const Text('Cardápio Digital')),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.menu_book_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
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

  @override
  Widget build(BuildContext context) {
    final limits = ref.watch(currentPlanProvider);

    if (!limits.hasDigitalMenu) {
      return _buildUpgradeBanner(context, 'O cardápio digital está disponível nos planos Pro e Premium.');
    }

    final recipesAsync = ref.watch(recipesProvider);
    return recipesAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, s) => Scaffold(body: Center(child: Text('Erro: $e'))),
      data: (recipes) {
        final menuRecipes = recipes.where((r) => r.showInMenu).toList();

        if (menuRecipes.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Cardápio Digital')),
            body: const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Nenhuma receita no cardápio ainda.\nEdite suas receitas e ative 'Exibir no cardápio'.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          );
        }

        final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

        return Scaffold(
          appBar: AppBar(
            title: const Text('Cardápio Digital'),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_rounded),
                onPressed: () {
                  if (limits.hasShareText) {
                    _shareAsText(menuRecipes);
                  } else {
                    _showUpgradeDialog('Compartilhar texto está disponível nos planos Pro e Premium.');
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.image_rounded),
                onPressed: () {
                  if (limits.hasExportJpg) {
                    _exportAsJpg();
                  } else {
                    _showUpgradeDialog('Exportar em JPG está disponível nos planos Pro e Premium.');
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.picture_as_pdf_rounded),
                onPressed: () {
                  if (limits.hasExportPdf) {
                    _exportAsPdf(menuRecipes);
                  } else {
                    _showUpgradeDialog('Export em PDF é exclusivo do plano Premium.');
                  }
                },
              ),
            ],
          ),
          body: Screenshot(
            controller: _screenshotController,
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: ListView.builder(
                itemCount: menuRecipes.length,
                itemBuilder: (context, index) {
                  final recipe = menuRecipes[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (recipe.imagePath != null)
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            child: Image.file(
                              File(recipe.imagePath!),
                              width: double.infinity,
                              height: 140,
                              fit: BoxFit.cover,
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(recipe.name,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                              Text(
                                formatter.format(
                                  recipe.sellingPrice ?? PriceUtils.roundSuggestedPrice(recipe.suggestedSellPrice),
                                ),
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

