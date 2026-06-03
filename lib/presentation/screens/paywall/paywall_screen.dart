import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:custo_doce/core/providers/subscription_provider.dart';

class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(title: const Text('CustoDoce Pro')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Assinaturas não são suportadas na Web.'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Voltar'),
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      body: SafeArea(
        child: PaywallView(
          onPurchaseCompleted: (customerInfo, storeTransaction) {
            // Update provider state
            ref.read(subscriptionNotifierProvider.notifier).checkStatus();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bem-vindo ao CustoDoce Pro! 🚀')),
              );
              context.pop(); // Go back
            }
          },
          onRestoreCompleted: (customerInfo) {
            ref.read(subscriptionNotifierProvider.notifier).checkStatus();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Compras restauradas com sucesso.')),
              );
              context.pop();
            }
          },
          onDismiss: () {
            if (context.mounted) {
              context.pop();
            }
          },
        ),
      ),
    );
  }
}
