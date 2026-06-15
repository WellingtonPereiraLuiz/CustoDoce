import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import 'package:custo_doce/core/enums/recipe_category.dart';
import 'package:custo_doce/core/providers/auth_provider.dart';
import 'package:custo_doce/core/theme/app_theme.dart';
import 'package:custo_doce/presentation/providers/recipe_providers.dart';
import 'package:custo_doce/core/utils/plan_gate.dart';
import 'package:custo_doce/core/providers/subscription_provider.dart';
import 'package:custo_doce/core/utils/price_utils.dart';
import 'package:custo_doce/domain/entities/recipe_entity.dart';

class DigitalMenuScreen extends ConsumerWidget {
  const DigitalMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 7.4 — Bloqueio (Feature Toggle)
    final plan = ref.watch(currentPlanProvider);
    if (!plan.hasDigitalMenu) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        PlanGate.checkFeature(
          context: context,
          ref: ref,
          hasAccess: false,
          featureName: 'Cardápio digital',
          requiredPlan: 'Pro',
        );
      });
      return const Scaffold(body: Center(child: Text('Cardápio Digital não disponível neste plano.')));
    }

    final recipes = ref.watch(recipesProvider).value ?? [];
    final menuRecipes = recipes.where((r) => r.showInMenu).toList();
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(user?.displayName ?? 'Cardápio Digital'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => _exportPdf(context, menuRecipes, user?.displayName, currencyFormat),
            tooltip: 'Exportar PDF',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareMenu(menuRecipes, currencyFormat),
            tooltip: 'Compartilhar',
          ),
        ],
      ),
      body: menuRecipes.isEmpty
          ? const Center(
              child: Text(
                'Você ainda não adicionou produtos ao cardápio.\n\nEdite uma receita e marque "Exibir no cardápio digital".',
                textAlign: TextAlign.center,
              ),
            )
          : _buildMenuList(context, menuRecipes, currencyFormat),
    );
  }

  Widget _buildMenuList(BuildContext context, List<RecipeEntity> recipes, NumberFormat format) {
    // Group by category
    final grouped = <RecipeCategory, List<RecipeEntity>>{};
    for (var r in recipes) {
      grouped.putIfAbsent(r.category, () => []).add(r);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: grouped.keys.length,
      itemBuilder: (context, index) {
        final category = grouped.keys.elementAt(index);
        final items = grouped[category]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                category.label,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
              ),
            ),
            ...items.map((r) => _MenuCard(recipe: r, format: format)),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  void _shareMenu(List<RecipeEntity> recipes, NumberFormat format) {
    if (recipes.isEmpty) return;
    
    final grouped = <RecipeCategory, List<RecipeEntity>>{};
    for (var r in recipes) {
      grouped.putIfAbsent(r.category, () => []).add(r);
    }

    final sb = StringBuffer();
    sb.writeln('*Cardápio*');
    sb.writeln();

    for (final entry in grouped.entries) {
      sb.writeln(entry.key.label);
      for (final r in entry.value) {
        final price = r.sellingPrice ?? PriceUtils.roundSuggestedPrice(r.suggestedSellPrice);
        sb.writeln('- ${r.name}: ${format.format(price)}');
      }
      sb.writeln();
    }

    Share.share(sb.toString());
  }

  Future<void> _exportPdf(BuildContext context, List<RecipeEntity> recipes, String? userName, NumberFormat format) async {
    if (recipes.isEmpty) return;

    final doc = pw.Document();
    
    final grouped = <RecipeCategory, List<RecipeEntity>>{};
    for (var r in recipes) {
      grouped.putIfAbsent(r.category, () => []).add(r);
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context ctx) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(userName ?? 'Cardápio Digital', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            ),
            ...grouped.entries.map((entry) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.SizedBox(height: 16),
                  pw.Text(entry.key.label, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.pink)),
                  pw.SizedBox(height: 8),
                  ...entry.value.map((r) {
                    final price = r.sellingPrice ?? PriceUtils.roundSuggestedPrice(r.suggestedSellPrice);
                    return pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 8),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(r.name, style: const pw.TextStyle(fontSize: 14)),
                          pw.Text(format.format(price), style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                    );
                  }),
                ],
              );
            }),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat form) async => doc.save(),
      name: 'Cardapio_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }
}

class _MenuCard extends StatelessWidget {
  final RecipeEntity recipe;
  final NumberFormat format;

  const _MenuCard({required this.recipe, required this.format});

  @override
  Widget build(BuildContext context) {
    final price = recipe.sellingPrice ?? PriceUtils.roundSuggestedPrice(recipe.suggestedSellPrice);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          if (recipe.imagePath != null && File(recipe.imagePath!).existsSync())
            Image.file(
              File(recipe.imagePath!),
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            )
          else
            Container(
              width: 100,
              height: 100,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Icon(Icons.cake, size: 40, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    format.format(price),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.successColor),
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

