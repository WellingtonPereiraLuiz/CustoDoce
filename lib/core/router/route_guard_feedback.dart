import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:custo_doce/core/theme/app_theme.dart';

class RouteGuardFeedback extends StatefulWidget {
  final Widget child;
  final GoRouterState state;

  const RouteGuardFeedback({
    super.key,
    required this.child,
    required this.state,
  });

  static Widget wrap({
    required GoRouterState state,
    required Widget child,
  }) {
    return RouteGuardFeedback(state: state, child: child);
  }

  @override
  State<RouteGuardFeedback> createState() => _RouteGuardFeedbackState();
}

class _RouteGuardFeedbackState extends State<RouteGuardFeedback> {
  @override
  void initState() {
    super.initState();
    final message = _buildMessage(widget.state.uri);
    if (message == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );

      final cleanLocation = _cleanLocation(widget.state.uri);
      if (cleanLocation != widget.state.uri.toString()) {
        context.replace(cleanLocation);
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;

  String? _buildMessage(Uri uri) {
    final guard = uri.queryParameters['guard'];
    final feature = uri.queryParameters['feature'];
    final requiredPlan = uri.queryParameters['requiredPlan'];

    switch (guard) {
      case 'auth':
        final target = feature ?? 'este recurso';
        return 'Faça login para acessar $target.';
      case 'plan':
        if (feature != null && requiredPlan != null) {
          return '$feature exige o plano $requiredPlan.';
        }
        if (requiredPlan != null) {
          return 'Este recurso exige o plano $requiredPlan.';
        }
        return 'Seu plano atual não permite acessar este recurso.';
      default:
        return null;
    }
  }

  String _cleanLocation(Uri uri) {
    final query = Map<String, String>.from(uri.queryParameters)
      ..remove('guard')
      ..remove('feature')
      ..remove('requiredPlan');

    final cleanUri = uri.replace(
      queryParameters: query.isEmpty ? null : query,
    );

    return cleanUri.toString();
  }
}
