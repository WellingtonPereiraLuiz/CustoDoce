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
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:custo_doce/presentation/providers/recipe_providers.dart';
import 'package:custo_doce/core/providers/subscription_provider.dart';
import 'package:custo_doce/core/utils/price_utils.dart';
import 'package:custo_doce/domain/entities/recipe_entity.dart';
import 'package:custo_doce/core/enums/recipe_category.dart';

class DigitalMenuScreen extends ConsumerStatefulWidget {
  const DigitalMenuScreen({super.key});

  @override
  ConsumerState<DigitalMenuScreen> createState() => _DigitalMenuScreenState();
}

class _DigitalMenuScreenState extends ConsumerState<DigitalMenuScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();

  String _categoryLabel(RecipeCategory cat) {
    switch (cat) {
      case RecipeCategory.bolo: return 'Bolos';
      case RecipeCategory.torta: return 'Tortas';
      case RecipeCategory.brigadeiro: return 'Brigadeiros';
      case RecipeCategory.cookies: return 'Cookies';
      case RecipeCategory.paes: return 'Pães';
      case RecipeCategory.salgados: return 'Salgados';
      case RecipeCategory.bebidas: return 'Bebidas';
      case RecipeCategory.outro: return 'Outros';
      default: return 'Outros';
    }
  }

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
              context.go('/paywall');
            },
            child: const Text('Ver planos'),
          ),
        ],
      ),
    );
  }

  Future<void> _shareAsText(List<RecipeEntity> recipes) async {
    if (recipes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhuma receita no cardápio para compartilhar.')),
      );
      return;
    }

    final buffer = StringBuffer();
    buffer.writeln('🍰 CARDÁPIO — CustoDoce');
    buffer.writeln('─────────────────────────');
    buffer.writeln();

    final Map<String, List<RecipeEntity>> grouped = {};
    for (final r in recipes) {
      final label = _categoryLabel(r.category);
      grouped.putIfAbsent(label, () => []).add(r);
    }

    for (final entry in grouped.entries) {
      buffer.writeln('📌 ${entry.key.toUpperCase()}');
      for (final r in entry.value) {
        final price = r.sellingPrice ?? PriceUtils.roundSuggestedPrice(r.suggestedSellPrice);
        final unitPrice = (r.yieldQuantity > 0)
            ? ' (R\$ ${(price / r.yieldQuantity).toStringAsFixed(2)} por unidade)'
            : '';
        buffer.writeln('• ${r.name} — R\$ ${price.toStringAsFixed(2)}$unitPrice');
      }
      buffer.writeln();
    }

    buffer.writeln('─────────────────────────');
    buffer.writeln('Calculado com CustoDoce 🍬');
    buffer.writeln('custodoce-b07ce.web.app');

    await Share.share(buffer.toString(), subject: 'Meu Cardápio — CustoDoce');
  }

  Future<void> _exportAsJpg() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No navegador, use "Exportar PDF" para salvar o cardápio.'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    try {
      final image = await _screenshotController.capture(pixelRatio: 2.0);
      if (image == null) return;
      final dir = await getTemporaryDirectory();
      final file = await File('${dir.path}/cardapio_custodoce.png').writeAsBytes(image);
      await Share.shareXFiles([XFile(file.path)], text: 'Meu cardápio CustoDoce');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao exportar imagem: $e')),
      );
    }
  }

  Future<void> _exportAsPdf(List<RecipeEntity> recipes) async {
    final doc = pw.Document();
    
    final primaryColor = PdfColor.fromHex('#1E0A07');
    final highlightColor = PdfColor.fromHex('#6B5A60');
    final borderColor = PdfColor.fromHex('#D4C3BF');
    final creamColor = PdfColor.fromHex('#FFF8F6');
    final whiteColor = PdfColors.white;

    doc.addPage(pw.MultiPage(
      pageTheme: pw.PageTheme(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        buildBackground: (ctx) => pw.FullPage(
          ignoreMargins: true,
          child: pw.Container(color: whiteColor),
        ),
      ),
      build: (ctx) => [
        pw.Center(
          child: pw.Column(
            children: [
              pw.Text('Cardápio', style: pw.TextStyle(fontSize: 32, fontWeight: pw.FontWeight.bold, color: primaryColor)),
              pw.SizedBox(height: 4),
              pw.Text('Confeitaria Artesanal', style: pw.TextStyle(fontSize: 14, color: highlightColor)),
            ],
          ),
        ),
        pw.SizedBox(height: 16),
        pw.Divider(color: primaryColor, thickness: 1.5),
        pw.SizedBox(height: 8),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text('Atualizado em ${DateFormat('dd/MM/yyyy').format(DateTime.now())}', style: pw.TextStyle(fontSize: 10, color: highlightColor)),
        ),
        pw.SizedBox(height: 24),
        
        ...recipes.map((r) {
          final price = r.sellingPrice ?? PriceUtils.roundSuggestedPrice(r.suggestedSellPrice);
          return pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 8),
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: creamColor,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              border: pw.Border.all(color: borderColor, width: 1),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(r.name, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: primaryColor)),
                    pw.Text('R\$ ${price.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: highlightColor)),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Divider(color: borderColor, thickness: 0.5),
                pw.SizedBox(height: 4),
                pw.Text(_categoryLabel(r.category), style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
              ],
            ),
          );
        }),
      ],
      footer: (ctx) => pw.Column(
        children: [
          pw.Divider(color: primaryColor, thickness: 1),
          pw.SizedBox(height: 4),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Feito com CustoDoce • custodoce.app', style: pw.TextStyle(fontSize: 10, color: highlightColor)),
              pw.Text('${ctx.pageNumber} / ${ctx.pagesCount}', style: pw.TextStyle(fontSize: 10, color: highlightColor)),
            ],
          ),
        ],
      ),
    ));
    await Printing.layoutPdf(onLayout: (_) async => doc.save());
  }

  Widget _buildUpgradeBanner(BuildContext context, String message) => Scaffold(
    appBar: AppBar(title: const Text('Cardápio Digital')),
    body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 600), child: Center(
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
    ))),
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
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'Cardápio',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Toque para exportar',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...menuRecipes.map((recipe) {
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (recipe.imagePath != null && File(recipe.imagePath!).existsSync())
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                              child: Image.file(
                                File(recipe.imagePath!),
                                width: double.infinity,
                                height: 160,
                                fit: BoxFit.cover,
                              ),
                            )
                          else
                            Container(
                              height: 160,
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                                gradient: LinearGradient(
                                  colors: [Color(0xFFE8E0DD), Color(0xFFD4C3BF)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: const Center(
                                child: Icon(Icons.cake_rounded, size: 64, color: Colors.white70),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        recipe.name,
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        recipe.category.label,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context).colorScheme.secondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF8F6),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    formatter.format(
                                      recipe.sellingPrice ?? PriceUtils.roundSuggestedPrice(recipe.suggestedSellPrice),
                                    ),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF6B5A60),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
