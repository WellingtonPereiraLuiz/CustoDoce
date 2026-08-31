import 'package:flutter/material.dart';
import 'package:custo_doce/core/constants/layout_constants.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:custo_doce/core/theme/app_theme.dart';
import 'package:custo_doce/core/providers/auth_provider.dart';
import 'package:custo_doce/core/providers/guest_mode_provider.dart';
import 'package:custo_doce/presentation/widgets/auth_split_layout.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordObscured = true;

  String _resolveRedirectTarget() {
    final state = GoRouterState.of(context);
    final extra = state.extra as Map<String, dynamic>?;
    return extra?['redirect'] as String? ??
        state.uri.queryParameters['redirect'] ??
        '/home';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final redirectTarget = _resolveRedirectTarget();
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final authService = ref.read(authServiceProvider);
      await authService.signIn(
          _emailController.text.trim(), _passwordController.text);
      ref.read(guestModeProvider.notifier).state = false;
      router.go(redirectTarget);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
            content: Text('Erro: $e'), backgroundColor: AppTheme.errorColor),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= kDesktopBreakpoint;
    if (isDesktop) return _buildDesktopLayout(context);
    return _buildMobileLayout(context);
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: AuthSplitLayout(
        headline: 'Transforme suas receitas em negócios lucrativos.',
        subtitle:
            'A plataforma definitiva para confeiteiros e pequenos empreendedores gastronômicos. Calcule custos com precisão, defina preços justos e acompanhe seus lucros.',
        formChild: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Acesse sua conta',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
              const SizedBox(height: 28),
              Icon(Icons.lock_rounded,
                  size: 64, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                'Precifique com confiança. Lucre com clareza.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 32),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Informe o email';
                        }
                        if (!value.contains('@') || !value.contains('.')) {
                          return 'Email inválido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: 'Senha'),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Informe a senha';
                        }
                        if (value.length < 6) {
                          return 'A senha deve ter no mínimo 6 caracteres';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.onPrimary))
                    : const Text('Entrar'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.push('/register'),
                child: Text(
                  'Não tem conta? Criar Conta',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
              ),
              const SizedBox(height: 24),
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('OU')),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: _isLoading
                    ? null
                    : () async {
                        try {
                          setState(() => _isLoading = true);
                          final cred = await ref
                              .read(authServiceProvider)
                              .signInWithGoogle();
                          if (cred != null && context.mounted) {
                            ref.read(guestModeProvider.notifier).state =
                                false;
                            context.go(_resolveRedirectTarget());
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('Erro no login com Google: $e')),
                            );
                          }
                        } finally {
                          if (mounted) setState(() => _isLoading = false);
                        }
                      },
                icon: const Icon(Icons.g_mobiledata_rounded, size: 32),
                label: const Text('Entrar com Google'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  ref.read(guestModeProvider.notifier).state = true;
                  context.go('/home');
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: Theme.of(context).dividerColor),
                ),
                child: const Text('Continuar sem login'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primaryContainer.withValues(alpha: 0.3),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.secondaryContainer.withValues(alpha: 0.2),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.surface.withValues(alpha: 0.5),
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.bakery_dining_rounded,
                        size: 40,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'CustoDoce',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Bem-vindo de volta!',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primaryContainer.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Column(
                          children: [
                            Container(
                              height: 4,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    colorScheme.secondaryContainer,
                                    colorScheme.primaryContainer,
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(24),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      'E-mail',
                                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    TextFormField(
                                      controller: _emailController,
                                      decoration: InputDecoration(
                                        hintText: 'confeiteira@exemplo.com',
                                        filled: true,
                                        fillColor: colorScheme.surface,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                                        ),
                                      ),
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Informe o email';
                                        }
                                        if (!value.contains('@') || !value.contains('.')) {
                                          return 'Email inválido';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Senha',
                                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Para recuperar a senha, entre em contato com o suporte: suporte@custodoce.app'),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            'Esqueci minha senha',
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelSmall
                                                ?.copyWith(
                                                  color: colorScheme.secondary,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    TextFormField(
                                      controller: _passwordController,
                                      obscureText: _isPasswordObscured,
                                      decoration: InputDecoration(
                                        hintText: '••••••••',
                                        filled: true,
                                        fillColor: colorScheme.surface,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(_isPasswordObscured ? Icons.visibility : Icons.visibility_off),
                                          onPressed: () => setState(() => _isPasswordObscured = !_isPasswordObscured),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Informe a senha';
                                        }
                                        if (value.length < 6) {
                                          return 'A senha deve ter no mínimo 6 caracteres';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 24),
                                    ElevatedButton(
                                      onPressed: _isLoading ? null : _submit,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: colorScheme.primary,
                                        foregroundColor: colorScheme.onPrimary,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: _isLoading ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: colorScheme.onPrimary, strokeWidth: 2)) : const Text('Entrar', style: TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                    const SizedBox(height: 24),
                                    Row(
                                      children: [
                                        Expanded(child: Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.5))),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16),
                                          child: Text(
                                            'OU ACESSE COM',
                                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                                                  letterSpacing: 1.2,
                                                ),
                                          ),
                                        ),
                                        Expanded(child: Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.5))),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    OutlinedButton.icon(
                                      onPressed: _isLoading ? null : () async {
                                          try {
                                            setState(() => _isLoading = true);
                                            final cred = await ref
                                                .read(authServiceProvider)
                                                .signInWithGoogle();
                                            if (cred != null && context.mounted) {
                                              ref.read(guestModeProvider.notifier).state =
                                                  false;
                                              context.go(_resolveRedirectTarget());
                                            }
                                          } catch (e) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                    content:
                                                        Text('Erro no login com Google: $e')),
                                              );
                                            }
                                          } finally {
                                            if (mounted) setState(() => _isLoading = false);
                                          }
                                        },
                                      icon: const Icon(Icons.g_mobiledata_rounded, size: 28),
                                      label: const Text('Continuar com Google', style: TextStyle(fontWeight: FontWeight.bold)),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.6)),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    OutlinedButton(
                                      onPressed: _isLoading ? null : () {
                                        ref.read(guestModeProvider.notifier).state = true;
                                        context.go('/home');
                                      },
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.6)),
                                      ),
                                      child: const Text('Acesse sem login', style: TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Ainda não tem uma conta? ',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                        ),
                        GestureDetector(
                          onTap: () => context.push('/register'),
                          child: Text(
                            'Cadastre-se',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.secondary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}