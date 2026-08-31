import 'package:flutter/material.dart';
import 'package:custo_doce/core/constants/layout_constants.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:custo_doce/core/providers/auth_provider.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _isCurrentPasswordObscured = true;
  bool _isNewPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(authServiceProvider).changePassword(
            currentPassword: _currentPasswordController.text,
            newPassword: _newPasswordController.text,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Senha alterada com sucesso!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erro ao alterar senha: $e'),
              backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
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
      appBar: AppBar(title: const Text('Alterar Senha')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _currentPasswordController,
                    obscureText: true,
                    decoration:
                        const InputDecoration(labelText: 'Senha Atual'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Informe a senha atual';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _newPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Nova Senha'),
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'A senha deve ter no mínimo 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                        labelText: 'Confirmar Nova Senha'),
                    validator: (value) {
                      if (value != _newPasswordController.text) {
                        return 'As senhas não coincidem';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _save,
                    child: _isLoading
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimary),
                          )
                        : const Text('Salvar Nova Senha'),
                  ),
                ],
              ),
            ),
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Alterar Senha',
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.secondaryContainer.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.security, color: colorScheme.secondary),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SEGURANÇA',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: colorScheme.secondary,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Para sua segurança, escolha uma senha forte que você não use em outros sites.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  height: 1.4,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Senha Atual',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _currentPasswordController,
                      obscureText: _isCurrentPasswordObscured,
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        suffixIcon: IconButton(
                          icon: Icon(_isCurrentPasswordObscured ? Icons.visibility : Icons.visibility_off, color: colorScheme.onSurfaceVariant),
                          onPressed: () => setState(() => _isCurrentPasswordObscured = !_isCurrentPasswordObscured),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Informe a senha atual';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Nova Senha',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _newPasswordController,
                      obscureText: _isNewPasswordObscured,
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        suffixIcon: IconButton(
                          icon: Icon(_isNewPasswordObscured ? Icons.visibility : Icons.visibility_off, color: colorScheme.onSurfaceVariant),
                          onPressed: () => setState(() => _isNewPasswordObscured = !_isNewPasswordObscured),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'A senha deve ter no mínimo 6 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Confirmar Nova Senha',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _isConfirmPasswordObscured,
                      decoration: InputDecoration(
                        hintText: '••••••••',
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
                        if (value != _newPasswordController.text) {
                          return 'As senhas não coincidem';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colorScheme.surfaceContainerHighest),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: colorScheme.secondary, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'A senha deve conter no mínimo 6 caracteres.',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primaryContainer,
                        foregroundColor: colorScheme.onPrimaryContainer,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: _isLoading ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: colorScheme.onPrimaryContainer, strokeWidth: 2)) : const Text('Salvar Nova Senha', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}