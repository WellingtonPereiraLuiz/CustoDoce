# Antigravity Prompt v8 — Dark Mode Fix + Paywall Web Pro Screen

## Contexto
App: CustoDoce (Flutter — Bun, Hono, Riverpod, GoRouter, sqflite)
Repo: https://github.com/WellingtonPereiraLuiz/CustoDoce

Faça as mudanças em **dois passos**. Cada passo = 1 commit + push para origin/main.

---

## PASSO 1 — Corrigir Dark Mode + Gradiente do Plano Pro

### Problema
O dark mode está com cores incorretas:
- `AppTheme.primaryColor = Color(0xFF1E0A07)` é quase preto — em fundo escuro, elementos usando essa cor ficam invisíveis (botões, ícones de seção, borda de seleção de tema).
- O `_SectionHeader` em `settings_screen.dart` usa `AppTheme.primaryColor` como `textColor` quando `isDark`, tornando o texto praticamente invisível.
- O `_ThemeOption` selecionado usa `AppTheme.primaryColor` como `color` do container — no dark mode fica um bloco quase preto sobre fundo escuro.
- O card de "Upgrade Pro" na settings usa `AppTheme.primaryColor` como `backgroundColor` da badge — invisível no dark.
- O gradiente da tela paywall/plano (quando existe) não contrasta bem no dark mode.

### O que fazer

#### 1.1 — `lib/core/theme/app_theme.dart`

Adicionar uma cor de acento "quente" legível para o dark mode — use o tom rosé-âmbar que é o inverso do `primaryColor` escuro:

```dart
// Adicionar após as constantes existentes:
/// Cor de acento usada em dark mode onde primaryColor seria invisível
static const Color accentWarm = Color(0xFFE5BEB6);
```

#### 1.2 — `lib/presentation/screens/settings/settings_screen.dart`

**`_SectionHeader.build`** — trocar a lógica de cor:
```dart
// ANTES:
final textColor = isDark ? AppTheme.primaryColor : Theme.of(context).colorScheme.onSurface;
// ... icon color: isDark ? AppTheme.primaryColor : ...

// DEPOIS:
final textColor = isDark ? AppTheme.accentWarm : Theme.of(context).colorScheme.onSurface;
// ... icon color: isDark ? AppTheme.accentWarm : Theme.of(context).colorScheme.onSurface
```

**`_ThemeOption.build`** — o container selecionado fica preto no dark:
```dart
// ANTES:
color: isSelected ? AppTheme.primaryColor : Colors.transparent,

// DEPOIS:
color: isSelected
    ? (Theme.of(context).brightness == Brightness.dark
        ? AppTheme.accentWarm
        : AppTheme.primaryColor)
    : Colors.transparent,
```
E os textos/ícones dentro do option selecionado:
```dart
// ANTES:
color: isSelected ? Theme.of(context).colorScheme.onPrimary : ...

// DEPOIS:
color: isSelected
    ? (Theme.of(context).brightness == Brightness.dark
        ? AppTheme.primaryColor   // texto escuro sobre fundo claro
        : Theme.of(context).colorScheme.onPrimary)
    : Theme.of(context).colorScheme.onSurfaceVariant,
```

**Badge PRO no `_SettingsTile` de upgrade** — no settings_screen, onde monta o trailing da badge "PRO":
```dart
// ANTES:
color: AppTheme.primaryColor,

// DEPOIS:
color: Theme.of(context).brightness == Brightness.dark
    ? AppTheme.accentWarm
    : AppTheme.primaryColor,
// E o texto da badge:
color: Theme.of(context).brightness == Brightness.dark
    ? AppTheme.primaryColor
    : Theme.of(context).colorScheme.onPrimary,
```

**`_LanguageTile`** — borda e texto selecionado:
```dart
// ANTES:
color: isSelected ? AppTheme.primaryColor.withAlpha(25) : cardBg,
// border color: isSelected ? AppTheme.primaryColor : Colors.transparent,
// text color: isSelected ? AppTheme.primaryColor : null,
// icon color: AppTheme.primaryColor

// DEPOIS: usar accentWarm em dark
final accent = Theme.of(context).brightness == Brightness.dark
    ? AppTheme.accentWarm
    : AppTheme.primaryColor;

color: isSelected ? accent.withAlpha(25) : cardBg,
// border: isSelected ? accent : transparent
// text: isSelected ? accent : null
// icon: accent
```

#### 1.3 — `lib/presentation/screens/home/home_screen.dart`

Procure qualquer uso direto de `AppTheme.primaryColor` em botões ou containers que aparecem no dark mode e troque por:
```dart
Theme.of(context).colorScheme.primary
```
(no dark theme, `colorScheme.primary = Color(0xFFE5BEB6)` — o rosé claro legível)

#### 1.4 — `lib/presentation/screens/paywall/paywall_screen.dart`

A tela web do paywall atual é só um texto simples. Vamos melhorar o gradiente/visual (o PASSO 2 vai substituir o conteúdo, mas já corrigir o fundo):

No bloco `if (kIsWeb)`, trocar o Scaffold body por um Container com gradiente que funcione em ambos os modos:
```dart
body: Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: Theme.of(context).brightness == Brightness.dark
          ? [
              const Color(0xFF1E1B1A),
              const Color(0xFF2C1A16),
              const Color(0xFF1E1B1A),
            ]
          : [
              const Color(0xFFFFF8F6),
              const Color(0xFFF5E6E0),
              const Color(0xFFFFF8F6),
            ],
    ),
  ),
  child: Center(/* conteúdo será substituído no passo 2 */),
),
```

**Commit mensagem:** `fix: corrigir dark mode — accentWarm, badges, theme selector e gradiente paywall`

---

## PASSO 2 — Tela Pro Web Completa (Simulação de Plano)

### Objetivo
Quando o usuário está **na web** e navega para `/paywall`, mostrar uma tela Pro real e funcional — com visual de gradiente artesanal, lista de benefícios e **botão que muda o plano no estado local para Pro** (sem RevenueCat), permitindo testar o app completo.

### O que fazer

#### 2.1 — `lib/core/providers/subscription_provider.dart`

Adicionar método `setProStatus` no `SubscriptionNotifier` para permitir troca manual no web:

```dart
// Adicionar no SubscriptionNotifier, após checkStatus():
/// Somente para uso em web/demo — troca o estado manualmente
void setProStatus(bool value) {
  if (kIsWeb) {
    state = value;
  }
}
```

#### 2.2 — `lib/presentation/screens/paywall/paywall_screen.dart`

Substituir completamente o bloco `if (kIsWeb)` por uma tela Pro completa:

```dart
if (kIsWeb) {
  final isAlreadyPro = ref.watch(isProUserProvider);
  return _WebProScreen(isAlreadyPro: isAlreadyPro);
}
```

Criar o widget `_WebProScreen` no mesmo arquivo:

```dart
class _WebProScreen extends ConsumerWidget {
  final bool isAlreadyPro;
  const _WebProScreen({required this.isAlreadyPro});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppTheme.accentWarm : AppTheme.primaryColor;
    final onAccent = isDark ? AppTheme.primaryColor : Colors.white;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF1E1B1A),
                    const Color(0xFF2C1A16),
                    const Color(0xFF1A1210),
                  ]
                : [
                    const Color(0xFFFFF8F6),
                    const Color(0xFFF5E6E0),
                    const Color(0xFFFAF0ED),
                  ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Botão voltar
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: Icon(Icons.close_rounded, color: accent),
                        onPressed: () => context.pop(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Ícone
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: accent.withAlpha(25),
                        shape: BoxShape.circle,
                        border: Border.all(color: accent.withAlpha(60), width: 2),
                      ),
                      child: Icon(Icons.workspace_premium_rounded, color: accent, size: 36),
                    ),
                    const SizedBox(height: 20),

                    // Título
                    Text(
                      'CustoDoce Pro',
                      style: GoogleFonts.sourceSerif4(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Desbloqueie o poder total da sua confeitaria',
                      style: TextStyle(
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.onSurface.withAlpha(160),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Benefícios
                    _BenefitItem(icon: Icons.all_inclusive_rounded, accent: accent, text: 'Receitas ilimitadas'),
                    _BenefitItem(icon: Icons.bar_chart_rounded, accent: accent, text: 'Relatórios de custos avançados'),
                    _BenefitItem(icon: Icons.inventory_2_rounded, accent: accent, text: 'Ingredientes ilimitados no estoque'),
                    _BenefitItem(icon: Icons.sync_rounded, accent: accent, text: 'Sincronização em nuvem'),
                    _BenefitItem(icon: Icons.support_agent_rounded, accent: accent, text: 'Suporte prioritário'),
                    const SizedBox(height: 32),

                    // Card de preço
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: accent.withAlpha(isDark ? 20 : 15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: accent.withAlpha(80), width: 1.5),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'R\$ 9,90',
                            style: GoogleFonts.sourceSerif4(
                              fontSize: 40,
                              fontWeight: FontWeight.w700,
                              color: accent,
                            ),
                          ),
                          Text(
                            'por mês • cancele quando quiser',
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context).colorScheme.onSurface.withAlpha(140),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Botão principal
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: onAccent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          textStyle: GoogleFonts.workSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        onPressed: isAlreadyPro
                            ? null
                            : () {
                                ref
                                    .read(subscriptionNotifierProvider.notifier)
                                    .setProStatus(true);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('🎉 Bem-vindo ao CustoDoce Pro!'),
                                    backgroundColor: AppTheme.successColor,
                                  ),
                                );
                                context.pop();
                              },
                        child: Text(
                          isAlreadyPro ? 'Você já é Pro!' : 'Ativar Pro (Demo Web)',
                        ),
                      ),
                    ),

                    // Se já for pro, botão de reverter (para testes)
                    if (isAlreadyPro) ...[
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          ref
                              .read(subscriptionNotifierProvider.notifier)
                              .setProStatus(false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Plano revertido para Free.')),
                          );
                          context.pop();
                        },
                        child: Text(
                          'Reverter para Free (teste)',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withAlpha(120),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),
                    Text(
                      'Modo demonstração — pagamentos reais disponíveis no app mobile.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurface.withAlpha(80),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BenefitItem extends StatelessWidget {
  final IconData icon;
  final Color accent;
  final String text;

  const _BenefitItem({required this.icon, required this.accent, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accent.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accent, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          Icon(Icons.check_rounded, color: accent, size: 18),
        ],
      ),
    );
  }
}
```

**Atenção:** adicione o import do `google_fonts` no topo se não existir:
```dart
import 'package:google_fonts/google_fonts.dart';
```

**Commit mensagem:** `feat: tela Pro web completa — gradiente, benefícios, toggle demo pro/free`

---

## Checklist final

- [ ] `AppTheme.accentWarm` definida em `app_theme.dart`
- [ ] `_SectionHeader` usa `accentWarm` no dark
- [ ] `_ThemeOption` selecionado usa `accentWarm` no dark (texto legível)
- [ ] Badge PRO legível no dark
- [ ] `_LanguageTile` selecionado usa `accentWarm` no dark
- [ ] `SubscriptionNotifier.setProStatus()` adicionado (só executa em `kIsWeb`)
- [ ] `paywall_screen.dart` — bloco web substituído por `_WebProScreen`
- [ ] `_WebProScreen` — gradiente funciona em light e dark
- [ ] `_WebProScreen` — botão "Ativar Pro (Demo Web)" muda o estado via provider
- [ ] `_WebProScreen` — botão "Reverter para Free" aparece quando já é Pro
- [ ] Sem erros de compilação (`flutter analyze`)
- [ ] 2 commits feitos e push para origin/main
