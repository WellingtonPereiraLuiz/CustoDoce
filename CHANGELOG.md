# Changelog

Todas as mudanças relevantes do CustoDoce são documentadas neste arquivo.

O formato segue [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/)
e o projeto adota [Versionamento Semântico](https://semver.org/lang/pt-BR/).

## [1.1.0] - 2026-06-11

### Adicionado
- Sistema de **4 planos**: Free, Light (R$ 4,90), Pro (R$ 9,90) e Premium (R$ 14,90).
- **Limites reais (gates)** por plano para receitas e ingredientes — bloqueio ao atingir o limite.
- **Seletor de planos na versão Web** para testar qualquer plano (modo demonstração).
- Contador visual de uso ("X / Y") nas listas de receitas e ingredientes.
- Tela de planos com benefícios e comparativo de recursos.
- Base para recursos premium: equipamentos (consumo elétrico), relatórios/dashboard,
  cardápio digital e backup em nuvem.

### Alterado
- **Dark mode** totalmente revisado — cores de acento legíveis (accentWarm),
  badges, seletor de tema e gradientes corrigidos.
- Provider de assinatura migrado de booleano para enum de planos (SubscriptionPlan).
- **Layout responsivo** na Web/Desktop com NavigationRail em telas largas.
- Telas com largura máxima (maxWidth) para melhor leitura no desktop.
- Tela de detalhe da receita com ingredientes em cards visuais.
- Configurações refletem o plano atual e protegem recursos Pro/Premium.

### Removido
- Toda menção a "Estoque/inventory" — o foco é receitas, precificação e relatórios.
- Prompts de desenvolvimento antigos do raiz do repositório.

### Corrigido
- Overflow do botão "Apagar" vs. preço do ingrediente no construtor de receitas.
- Botão principal invisível no dark mode.

## [1.0.0] - 2026-06-08

### Adicionado
- Versão inicial do CustoDoce.
- Gestão de ingredientes com cálculo de custo por grama/ml/unidade.
- Calculadora de receitas com custo em tempo real.
- Cálculo de preço de venda com margem de lucro.
- Tema claro/escuro e suporte a português e inglês.
- Versão Web e Android.
