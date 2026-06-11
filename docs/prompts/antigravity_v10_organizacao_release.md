# Antigravity Prompt v10 — Organização do Repo + Versionamento 1.1.0 + CHANGELOG + Release

## Contexto
App: CustoDoce (Flutter)
Repo: https://github.com/WellingtonPereiraLuiz/CustoDoce

Objetivo: limpar a bagunça de arquivos `.md` soltos no raiz, organizar prompts/análises em `/docs`, subir a versão para **1.1.0+2**, criar **CHANGELOG.md** e preparar o terreno para o **GitHub Release** com o novo APK.

Faça em **4 passos**. Cada passo = 1 commit + push para origin/main. Rode `flutter analyze` no final.

---

## PASSO 1 — Limpar e organizar arquivos de documentação

### Estado atual do raiz (poluído):
```
README.md                      <- MANTER no raiz
analise_custoDoce.md
analise_seguranca_repo.md
antigravity_v7_ui_ux.md
prompt_antigravity.md
prompt_antigravity_v2.md
prompt_antigravity_v3.md
prompt_antigravity_v4.md
prompt_antigravity_v5.md
prompt_antigravity_v6.md
prompt_stitch_v2.md
prompts/                       <- pasta com v8 e v9
  antigravity_v8_darkmode_paywall.md
  antigravity_v9_planos_gates.md
  antigravity_v10_organizacao_release.md  (este arquivo)
```

### O que fazer:

1. **APAGAR** os prompts antigos já aplicados (não são mais necessários):
```bash
git rm prompt_antigravity.md
git rm prompt_antigravity_v2.md
git rm prompt_antigravity_v3.md
git rm prompt_antigravity_v4.md
git rm prompt_antigravity_v5.md
git rm prompt_antigravity_v6.md
git rm antigravity_v7_ui_ux.md
git rm prompt_stitch_v2.md
```

2. **MOVER** as análises técnicas para `docs/` (são úteis como histórico):
```bash
mkdir -p docs
git mv analise_custoDoce.md docs/analise_custoDoce.md
git mv analise_seguranca_repo.md docs/analise_seguranca_repo.md
```

3. **MOVER** a pasta `prompts/` (v8, v9, v10) para `docs/prompts/`:
```bash
mkdir -p docs/prompts
git mv prompts/antigravity_v8_darkmode_paywall.md docs/prompts/
git mv prompts/antigravity_v9_planos_gates.md docs/prompts/
git mv prompts/antigravity_v10_organizacao_release.md docs/prompts/
```
(Se a pasta `prompts/` ficar vazia, ela some sozinha do Git.)

4. **Estado final esperado do raiz** (limpo):
```
README.md
CHANGELOG.md          (criado no passo 3)
.env.example
.gitignore
pubspec.yaml
android/ ios/ web/ lib/ test/ assets/
custodoce-apresentacao.image-slides/
docs/
  analise_custoDoce.md
  analise_seguranca_repo.md
  prompts/
    antigravity_v8_darkmode_paywall.md
    antigravity_v9_planos_gates.md
    antigravity_v10_organizacao_release.md
```

**Commit:** `chore: organizar docs em /docs e remover prompts antigos aplicados`

---

## PASSO 2 — Subir a versão para 1.1.0+2

### `pubspec.yaml`

```yaml
# ANTES:
version: 1.0.0+1

# DEPOIS:
version: 1.1.0+2
```

**Commit:** `chore: bump version 1.0.0+1 -> 1.1.0+2`

---

## PASSO 3 — Criar CHANGELOG.md

Criar arquivo `CHANGELOG.md` no **raiz** com o conteúdo abaixo (formato Keep a Changelog):

```markdown
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
```

**Commit:** `docs: adicionar CHANGELOG.md com histórico de versões`

---

## PASSO 4 — Atualizar README com seção de Download/Release

No `README.md`, adicionar (ou atualizar) uma seção perto do topo para apontar para os Releases:

```markdown
## 📥 Download

A versão mais recente do APK está disponível na página de
[**Releases**](https://github.com/WellingtonPereiraLuiz/CustoDoce/releases).

Versão atual: **1.1.0**

> O app também está disponível na versão **Web** (responsiva para desktop e mobile).
```

Também adicionar um link para o CHANGELOG no final do README:
```markdown
## 📋 Changelog

Veja o histórico completo de mudanças em [CHANGELOG.md](CHANGELOG.md).
```

**Commit:** `docs: README aponta para Releases e CHANGELOG`

Rodar `flutter analyze` (deve continuar limpo — nada de código mudou aqui).

---

## DEPOIS DOS COMMITS — Gerar e publicar o APK (passo manual do Wellington)

> Estas instruções são para você (Wellington) rodar localmente — o Antigravity não builda o APK.

### 1. Gerar o APK release
```bash
flutter clean
flutter pub get
flutter build apk --release --dart-define-from-file=.env
```
O APK sai em: `build/app/outputs/flutter-apk/app-release.apk`

> Renomeie para algo claro antes de subir, ex: `custodoce-1.1.0.apk`.

### 2. Criar o Release no GitHub (NÃO commitar o APK no código!)

**Opção A — pela interface web:**
1. Vá em `https://github.com/WellingtonPereiraLuiz/CustoDoce/releases/new`
2. Crie uma tag: `v1.1.0`
3. Título: `CustoDoce 1.1.0`
4. Cole o conteúdo da seção `[1.1.0]` do CHANGELOG na descrição
5. Arraste o `custodoce-1.1.0.apk` para a área de anexos
6. Publish release

**Opção B — pela CLI (gh):**
```bash
# Cria a tag e o release, anexando o APK
gh release create v1.1.0 \
  build/app/outputs/flutter-apk/app-release.apk \
  --title "CustoDoce 1.1.0" \
  --notes-file CHANGELOG.md
```

### Por que NÃO commitar o APK no repositório?
- APKs são binários grandes (dezenas de MB) que incham o histórico do Git permanentemente.
- O Git não consegue fazer "diff" de binários — cada nova versão duplica o tamanho.
- Releases mantêm o repo leve e organizam os downloads por versão com changelog.

---

## Checklist final

- [ ] Prompts antigos (v1-v6, v7, stitch_v2) removidos
- [ ] Análises movidas para `docs/`
- [ ] Pasta `prompts/` movida para `docs/prompts/`
- [ ] Raiz limpo (só README, CHANGELOG, configs e pastas)
- [ ] `pubspec.yaml` em `1.1.0+2`
- [ ] `CHANGELOG.md` criado no raiz
- [ ] README com seção de Download/Release e link pro CHANGELOG
- [ ] `flutter analyze` limpo
- [ ] 4 commits + push para origin/main
- [ ] (Manual) APK 1.1.0 gerado e publicado no GitHub Releases com tag `v1.1.0`
