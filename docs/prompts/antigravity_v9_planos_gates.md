# Antigravity Prompt v9 — Sistema de 4 Planos + Gates Reais + Funcionalidades Pro

## Contexto
App: CustoDoce (Flutter — Riverpod, GoRouter, sqflite)
Repo: https://github.com/WellingtonPereiraLuiz/CustoDoce

**IMPORTANTE — Escopo:** o app NÃO trabalha com "estoque/inventory". Trate a tela de ingredientes como **cadastro de ingredientes** (não estoque). Não adicione nenhuma menção a estoque em texto de UI.

Faça em **6 passos**. Cada passo = 1 commit + push para origin/main. Rode `flutter analyze` antes de cada commit.

---

## ESTRUTURA DOS 4 PLANOS (fonte da verdade)

| Recurso | Free | Light (R$4,90/mês) | Pro (R$9,90/mês) | Premium (R$14,90/mês) |
|---|---|---|---|---|
| Receitas | 3 | 30 | Ilimitado | Ilimitado |
| Ingredientes | 15 | 100 | Ilimitado | Ilimitado |
| Equipamentos (consumo elétrico) | ❌ | 5 | Ilimitado | Ilimitado |
| Relatórios e gráficos (dashboard) | ❌ | ❌ | ✅ | ✅ |
| Cardápio digital (link compartilhável) | ❌ | ❌ | ❌ | ✅ |
| Backup / sincronização em nuvem | ❌ | ❌ | ✅ | ✅ |

Funcionalidades novas escolhidas: **Equipamentos**, **Relatórios/Dashboard**, **Cardápio digital**, **Backup nuvem**.

---

## PASSO 1 — Modelo de Planos e Enum

### 1.1 — Criar `lib/core/models/subscription_plan.dart`

```dart
enum SubscriptionPlan { free, light, pro, premium }

class PlanLimits {
  final SubscriptionPlan plan;
  final String name;
  final String priceLabel;          // ex: "R$ 9,90/mês"
  final int recipeLimit;            // -1 = ilimitado
  final int ingredientLimit;        // -1 = ilimitado
  final int equipmentLimit;         // 0 = bloqueado, -1 = ilimitado
  final bool hasReports;
  final bool hasDigitalMenu;
  final bool hasCloudBackup;

  const PlanLimits({
    required this.plan,
    required this.name,
    required this.priceLabel,
    required this.recipeLimit,
    required this.ingredientLimit,
    required this.equipmentLimit,
    required this.hasReports,
    required this.hasDigitalMenu,
    required this.hasCloudBackup,
  });

  bool get isUnlimitedRecipes => recipeLimit == -1;
  bool get isUnlimitedIngredients => ingredientLimit == -1;

  static const free = PlanLimits(
    plan: SubscriptionPlan.free,
    name: 'Free',
    priceLabel: 'Grátis',
    recipeLimit: 3,
    ingredientLimit: 15,
    equipmentLimit: 0,
    hasReports: false,
    hasDigitalMenu: false,
    hasCloudBackup: false,
  );

  static const light = PlanLimits(
    plan: SubscriptionPlan.light,
    name: 'Light',
    priceLabel: 'R\$ 4,90/mês',
    recipeLimit: 30,
    ingredientLimit: 100,
    equipmentLimit: 5,
    hasReports: false,
    hasDigitalMenu: false,
    hasCloudBackup: false,
  );

  static const pro = PlanLimits(
    plan: SubscriptionPlan.pro,
    name: 'Pro',
    priceLabel: 'R\$ 9,90/mês',
    recipeLimit: -1,
    ingredientLimit: -1,
    equipmentLimit: -1,
    hasReports: true,
    hasDigitalMenu: false,
    hasCloudBackup: true,
  );

  static const premium = PlanLimits(
    plan: SubscriptionPlan.premium,
    name: 'Premium',
    priceLabel: 'R\$ 14,90/mês',
    recipeLimit: -1,
    ingredientLimit: -1,
    equipmentLimit: -1,
    hasReports: true,
    hasDigitalMenu: true,
    hasCloudBackup: true,
  );

  static const all = [free, light, pro, premium];

  static PlanLimits forPlan(SubscriptionPlan p) {
    return all.firstWhere((e) => e.plan == p, orElse: () => free);
  }
}
```

**Commit:** `feat: modelo de 4 planos (Free/Light/Pro/Premium) com limites`

---

## PASSO 2 — Provider de Plano (substituir o boolean atual)

O provider atual (`subscriptionNotifierProvider`) é um `StateNotifier<bool>`. Vamos evoluir pra um `StateNotifier<SubscriptionPlan>` mantendo compatibilidade.

### 2.1 — `lib/core/providers/subscription_provider.dart`

Reescrever:

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:custo_doce/core/services/subscription_service.dart';
import 'package:custo_doce/core/models/subscription_plan.dart';

final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  return SubscriptionService();
});

class SubscriptionNotifier extends StateNotifier<SubscriptionPlan> {
  final SubscriptionService _service;

  SubscriptionNotifier(this._service) : super(SubscriptionPlan.free) {
    _init();
  }

  Future<void> _init() async {
    if (kIsWeb) {
      // Em web começa como free; usuário troca pelo seletor de planos
      state = SubscriptionPlan.free;
      return;
    }

    final isPro = await _service.checkProStatus();
    state = isPro ? SubscriptionPlan.pro : SubscriptionPlan.free;

    Purchases.addCustomerInfoUpdateListener((customerInfo) {
      final entitlement =
          customerInfo.entitlements.all[SubscriptionService.entitlementId];
      final isNowPro = entitlement != null && entitlement.isActive;
      final newPlan = isNowPro ? SubscriptionPlan.pro : SubscriptionPlan.free;
      if (state != newPlan) state = newPlan;
    });
  }

  Future<void> checkStatus() async {
    if (kIsWeb) return;
    final isPro = await _service.checkProStatus();
    final newPlan = isPro ? SubscriptionPlan.pro : SubscriptionPlan.free;
    if (state != newPlan) state = newPlan;
  }

  /// Somente web/demo — troca o plano manualmente para testes
  void setPlan(SubscriptionPlan plan) {
    if (kIsWeb) {
      state = plan;
    }
  }

  Future<void> restorePurchases() async {
    if (kIsWeb) return;
    final isPro = await _service.restorePurchases();
    final newPlan = isPro ? SubscriptionPlan.pro : SubscriptionPlan.free;
    if (state != newPlan) state = newPlan;
  }
}

final subscriptionNotifierProvider =
    StateNotifierProvider<SubscriptionNotifier, SubscriptionPlan>((ref) {
  final service = ref.watch(subscriptionServiceProvider);
  return SubscriptionNotifier(service);
});

/// Plano atual completo com limites
final currentPlanProvider = Provider<PlanLimits>((ref) {
  final plan = ref.watch(subscriptionNotifierProvider);
  return PlanLimits.forPlan(plan);
});

/// Compatibilidade: true se NÃO for free (qualquer plano pago)
final isProUserProvider = Provider<bool>((ref) {
  final plan = ref.watch(subscriptionNotifierProvider);
  return plan != SubscriptionPlan.free;
});
```

**ATENÇÃO:** ao mudar de `bool` para `SubscriptionPlan`, qualquer código que fazia `ref.watch(subscriptionNotifierProvider)` esperando bool vai quebrar. Procure por usos e troque por `ref.watch(isProUserProvider)` onde precisar de bool, ou `ref.watch(currentPlanProvider)` onde precisar dos limites.

**Commit:** `refactor: provider de assinatura agora usa SubscriptionPlan enum`

---

## PASSO 3 — Gates Reais (bloquear ao atingir limite)

### 3.1 — Criar helper `lib/core/utils/plan_gate.dart`

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:custo_doce/core/models/subscription_plan.dart';

class PlanGate {
  /// Retorna true se pode prosseguir. Se bloqueado, mostra dialog e retorna false.
  static bool checkLimit({
    required BuildContext context,
    required int currentCount,
    required int limit,            // -1 = ilimitado
    required String featureName,   // ex: "receitas"
    required String planName,
  }) {
    if (limit == -1) return true;
    if (currentCount < limit) return true;
    _showUpgradeDialog(context, featureName, limit, planName);
    return false;
  }

  /// Para features booleanas (relatórios, cardápio, etc)
  static bool checkFeature({
    required BuildContext context,
    required bool hasAccess,
    required String featureName,
    required String requiredPlan,
  }) {
    if (hasAccess) return true;
    _showFeatureDialog(context, featureName, requiredPlan);
    return false;
  }

  static void _showUpgradeDialog(
      BuildContext context, String feature, int limit, String planName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.lock_outline_rounded, size: 40),
        title: const Text('Limite atingido'),
        content: Text(
          'Seu plano $planName permite até $limit $feature.\n\n'
          'Faça upgrade para adicionar mais.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Agora não'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.push('/paywall');
            },
            child: const Text('Ver planos'),
          ),
        ],
      ),
    );
  }

  static void _showFeatureDialog(
      BuildContext context, String feature, String requiredPlan) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.workspace_premium_rounded, size: 40),
        title: Text('Recurso $requiredPlan'),
        content: Text(
          '$feature está disponível no plano $requiredPlan.\n\n'
          'Faça upgrade para desbloquear.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Agora não'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.push('/paywall');
            },
            child: const Text('Ver planos'),
          ),
        ],
      ),
    );
  }
}
```

### 3.2 — Aplicar gate de RECEITAS

Em `lib/presentation/screens/home/home_screen.dart`, no botão "Criar Nova Receita" (por volta da linha 292). Hoje ele já checa `if (!isPro) push('/paywall')`. Trocar pela lógica de contagem:

```dart
onPressed: () {
  final plan = ref.read(currentPlanProvider);
  final recipes = ref.read(recipesProvider).value ?? [];
  final canCreate = PlanGate.checkLimit(
    context: context,
    currentCount: recipes.length,
    limit: plan.recipeLimit,
    featureName: 'receitas',
    planName: plan.name,
  );
  if (canCreate) context.push('/recipe-builder');
},
```
(Importe `currentPlanProvider`, `PlanGate`, `recipesProvider`. Remova a lógica antiga baseada em `isPro`.)

### 3.3 — Aplicar gate de INGREDIENTES

Em `lib/presentation/screens/ingredient_manager/ingredient_manager_screen.dart`, no `FloatingActionButton.extended` (linha ~93):

```dart
onPressed: () {
  final plan = ref.read(currentPlanProvider);
  final ingredients = ref.read(ingredientsProvider).value ?? [];
  final canAdd = PlanGate.checkLimit(
    context: context,
    currentCount: ingredients.length,
    limit: plan.ingredientLimit,
    featureName: 'ingredientes',
    planName: plan.name,
  );
  if (canAdd) _showIngredientForm(context, ref, null);
},
```

### 3.4 — Banner de contador (opcional, visual)

No topo da lista de ingredientes e receitas, se o plano NÃO for ilimitado, mostrar um chip discreto: `"12 / 15 ingredientes"`. Use `colorScheme.surfaceContainerHighest`. Se atingir o limite, cor de alerta (`AppTheme.errorColor` suave).

**Commit:** `feat: gates reais de limite para receitas e ingredientes`

---

## PASSO 4 — Seletor de Planos no Web (4 planos)

Substituir o `_WebProScreen` atual (que só tinha toggle Pro/Free) por uma tela com os **4 planos** selecionáveis.

### 4.1 — `lib/presentation/screens/paywall/paywall_screen.dart`

No bloco `if (kIsWeb)`, usar novo widget `_WebPlanSelector`:

```dart
if (kIsWeb) {
  return const _WebPlanSelector();
}
```

Criar `_WebPlanSelector` (ConsumerWidget) com:
- Fundo em gradiente (igual ao v8, adaptado light/dark)
- Título "Escolha seu plano"
- Os 4 cards de plano em coluna (`ConstrainedBox maxWidth: 480`), cada um mostrando:
  - Nome + preço (`PlanLimits.name`, `.priceLabel`)
  - Lista de limites/features (receitas, ingredientes, equipamentos, relatórios, cardápio, backup) com ✓/✗
  - Badge "ATUAL" se for o plano selecionado agora (`ref.watch(subscriptionNotifierProvider) == plan.plan`)
  - Botão "Selecionar" que chama `ref.read(subscriptionNotifierProvider.notifier).setPlan(plan.plan)` + SnackBar + `context.pop()`
- Card do plano atual com borda destacada (`accent`, 2px)
- Use `AppTheme.accentWarm` no dark e `AppTheme.primaryColor` no light para os acentos (mesma lógica do v8)
- Rodapé: "Modo demonstração — pagamentos reais disponíveis no app mobile."

Mapeie cada `PlanLimits` para linhas de feature assim:
```dart
List<({String label, bool ok})> featureRows(PlanLimits p) => [
  (label: p.isUnlimitedRecipes ? 'Receitas ilimitadas' : '${p.recipeLimit} receitas', ok: true),
  (label: p.isUnlimitedIngredients ? 'Ingredientes ilimitados' : '${p.ingredientLimit} ingredientes', ok: true),
  (label: p.equipmentLimit == 0 ? 'Equipamentos' : (p.equipmentLimit == -1 ? 'Equipamentos ilimitados' : '${p.equipmentLimit} equipamentos'), ok: p.equipmentLimit != 0),
  (label: 'Relatórios e gráficos', ok: p.hasReports),
  (label: 'Cardápio digital', ok: p.hasDigitalMenu),
  (label: 'Backup em nuvem', ok: p.hasCloudBackup),
];
```
Cada linha: ícone `Icons.check_rounded` (cor accent) se `ok`, senão `Icons.close_rounded` (cor cinza esmaecida), texto esmaecido quando `!ok`.

**Importante:** importe `subscription_plan.dart`, `google_fonts`, `app_theme.dart`.

**Commit:** `feat: seletor de 4 planos no web para testes (Free/Light/Pro/Premium)`

---

## PASSO 5 — Settings reflete o plano atual + gates nas features Premium

### 5.1 — `lib/presentation/screens/settings/settings_screen.dart`

Onde hoje mostra "Upgrade Pro" vs "CustoDoce Pro", trocar pela lógica de plano:

```dart
final currentPlan = ref.watch(currentPlanProvider);
final isFree = currentPlan.plan == SubscriptionPlan.free;
```

- Se `isFree`: mostrar tile "Fazer upgrade" → `context.push('/paywall')`, badge com nome do próximo plano.
- Se pago: mostrar tile "Plano ${currentPlan.name}" com badge verde (`AppTheme.successColor`), subtítulo "Toque para gerenciar/trocar" → `context.push('/paywall')`.

Garanta que a badge use `accentWarm` no dark (lógica do v8).

### 5.2 — Gates nas entradas de features Pro/Premium

Se existir (ou quando criar) entradas de menu para **Relatórios**, **Cardápio Digital** ou **Backup**, proteja com `PlanGate.checkFeature`:

```dart
onTap: () {
  final plan = ref.read(currentPlanProvider);
  if (PlanGate.checkFeature(
    context: context,
    hasAccess: plan.hasReports,
    featureName: 'Relatórios e gráficos',
    requiredPlan: 'Pro',
  )) {
    context.push('/reports'); // ou abrir a tela
  }
},
```
(Cardápio → `hasDigitalMenu` / "Premium"; Backup → `hasCloudBackup` / "Pro".)

**Commit:** `feat: settings reflete plano atual e protege features Pro/Premium`

---

## PASSO 6 — Limpeza de "estoque" + verificação final

### 6.1 — Remover menções a "Estoque"

Procure em todos os arquivos `.dart` e em `app_strings.dart` por: `Estoque`, `estoque`, `inventory`, `Inventory`. Substitua por "Ingredientes" / "ingredientes". No `settings_screen.dart`, o texto do "Como usar" menciona `aba "Estoque"` — corrija para `aba "Ingredientes"`.

### 6.2 — `app_constants.dart`

O `freeRecipeLimit = 3` antigo pode ser removido (agora vem de `PlanLimits.free.recipeLimit`). Se algo ainda usa, aponte para o novo modelo.

### 6.3 — Verificação

```bash
flutter analyze
```
Corrija todos os erros. Não pode sobrar referência a `subscriptionNotifierProvider` esperando `bool`.

**Commit:** `chore: remover menções a estoque e limpar constantes legadas`

---

## Checklist final

- [ ] `SubscriptionPlan` enum + `PlanLimits` (4 planos) criados
- [ ] Provider migrado para `StateNotifier<SubscriptionPlan>` com `setPlan()` (só web)
- [ ] `currentPlanProvider` e `isProUserProvider` (compat) funcionando
- [ ] `PlanGate` criado e aplicado em receitas (home) e ingredientes
- [ ] Banner de contador "X / Y" nas listas (não ilimitado)
- [ ] `_WebPlanSelector` com 4 cards, badge "ATUAL", botão selecionar via `setPlan`
- [ ] Settings mostra plano atual e protege features Pro/Premium com `PlanGate.checkFeature`
- [ ] Nenhuma menção a "Estoque/inventory" no app
- [ ] `flutter analyze` limpo
- [ ] 6 commits + push para origin/main

---

## NOTA sobre as funcionalidades Pro (como cada uma funcionaria)

Para tua referência (Wellington) — não precisa implementar a lógica completa de todas agora, mas os **gates** já preparam o terreno:

- **Equipamentos (consumo elétrico):** cadastra equipamento com potência (W) e custo do kWh; ao montar receita, informa tempo de uso → app soma o custo elétrico ao custo da receita. (Light: até 5, Pro+: ilimitado.)
- **Relatórios/Dashboard (Pro):** gráficos de custo médio, margem de lucro, receitas mais lucrativas, evolução de preços de ingredientes.
- **Cardápio digital (Premium):** gera um link público com as receitas selecionadas e preços de venda — pra compartilhar no WhatsApp/Instagram.
- **Backup nuvem (Pro):** sincroniza receitas/ingredientes com Firebase, evita perda de dados ao trocar de aparelho.

Essas 4 viram telas próprias depois. Por enquanto, o v9 entrega: 4 planos, gates reais, seletor web e settings refletindo o plano.
