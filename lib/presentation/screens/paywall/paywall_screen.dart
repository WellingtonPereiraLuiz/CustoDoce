import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:custo_doce/core/providers/subscription_provider.dart';

class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
