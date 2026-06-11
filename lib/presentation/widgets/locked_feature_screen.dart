import 'package:custo_doce/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class LockedFeatureScreen extends StatelessWidget {
  final String featureName;
  final String requiredPlan;

  const LockedFeatureScreen({
    super.key,
    required this.featureName,
    required this.requiredPlan,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppTheme.accentWarm : AppTheme.primaryColor;
    
    return Scaffold(
      appBar: AppBar(title: Text(featureName)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline_rounded, size: 64, color: accent.withAlpha(180)),
              const SizedBox(height: 20),
              Text(
                'Recurso $requiredPlan',
                style: GoogleFonts.sourceSerif4(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Text(
                '$featureName está disponível no plano $requiredPlan.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(160)),
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: () => context.push('/paywall'),
                icon: const Icon(Icons.workspace_premium_rounded),
                label: const Text('Ver planos'),
                style: FilledButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: isDark ? AppTheme.primaryColor : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
