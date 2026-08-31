import 'package:flutter/material.dart';
import 'package:custo_doce/core/constants/layout_constants.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:custo_doce/core/theme/app_theme.dart';
import 'package:custo_doce/core/providers/auth_provider.dart';
import 'package:custo_doce/presentation/widgets/auth_split_layout.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  String _loginLocation() {
    final redirect = GoRouterState.of(context).uri.queryParameters['redirect'];
    if (redirect == null || redirect.isEmpty) return '/login';
    return Uri(path: '/login', queryParameters: {'redirect': redirect})
        .toString();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final authService = ref.read(authServiceProvider);

      await authService.signUp(
          _emailController.text.trim(), _passwordController.text);
      await authService.updateDisplayName(
          _firstNameController.text.trim(), _lastNameController.text.trim());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Conta criada com sucesso!')),
        );
        context.go(_loginLocation());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erro ao criar conta: $e'),
              backgroundColor: AppTheme.errorColor),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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
        title: const Text('Criar Conta'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: AuthSplitLayout(
        headline: 'Comece a precificar com confiança.',
        subtitle:
            'Crie sua conta gratuita e transforme sua confeitaria em um negócio lucrativo com cálculos precisos de custo e preço.',
        formChild: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.person_add_rounded,
                  size: 64, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 32),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(labelText: 'Nome'),
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.trim().length < 2) {
                          return 'Nome deve ter pelo menos 2 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _lastNameController,
                      decoration:
                          const InputDecoration(labelText: 'Sobrenome'),
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.trim().length < 2) {
                          return 'Sobrenome deve ter pelo menos 2 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
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
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration:
                          const InputDecoration(labelText: 'Confirmar Senha'),
                      obscureText: true,
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return 'As senhas não coincidem';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
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
                    : const Text('Criar conta'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go(_loginLocation()),
                child: Text(
                  'Já tem conta? Entrar',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
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
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.primary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Criar Conta',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
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
                  Icons.person_add_rounded,
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
                      letterSpacing: -0.5,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Crie sua conta artesanal',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 32),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _firstNameController,
                      decoration: InputDecoration(
                        hintText: 'Nome',
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.trim().length < 2) {
                          return 'Nome deve ter pelo menos 2 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _lastNameController,
                      decoration: InputDecoration(
                        hintText: 'Sobrenome',
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.trim().length < 2) {
                          return 'Sobrenome deve ter pelo menos 2 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: 'Email',
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _isPasswordObscured,
                      decoration: InputDecoration(
                        hintText: 'Senha',
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        suffixIcon: IconButton(
                          icon: Icon(_isPasswordObscured ? Icons.visibility : Icons.visibility_off, color: colorScheme.onSurfaceVariant),
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
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _isConfirmPasswordObscured,
                      decoration: InputDecoration(
                        hintText: 'Confirmar Senha',
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        suffixIcon: IconButton(
                          icon: Icon(_isConfirmPasswordObscured ? Icons.visibility : Icons.visibility_off, color: colorScheme.onSurfaceVariant),
                          onPressed: () => setState(() => _isConfirmPasswordObscured = !_isConfirmPasswordObscured),
                        ),
                      ),
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return 'As senhas não coincidem';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primaryContainer,
                        foregroundColor: colorScheme.onPrimaryContainer,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: colorScheme.onPrimaryContainer, strokeWidth: 2)) : const Text('Criar conta', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Já tem conta? ',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                  GestureDetector(
                    onTap: () => context.go(_loginLocation()),
                    child: Text(
                      'Entrar',
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
    );
  }
}