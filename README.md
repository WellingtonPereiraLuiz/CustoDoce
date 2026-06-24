<div align="center">
  <img src="assets/images/CustoDoce.png" width="120" height="120" alt="CustoDoce Logo">
  <h1>CustoDoce 🍫</h1>
  <p><strong>A Calculadora de Custos Definitiva para Confeiteiros e Padeiros Artesanais</strong></p>

  ![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
  ![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
  ![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
  ![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)
  ![Web](https://img.shields.io/badge/Web-4285F4?style=for-the-badge&logo=googlechrome&logoColor=white)
</div>

---

## Equipe

- **Nome da equipe:** CoreMetrics
- **Integrantes:**
  - Wellington Pereira Luiz
  - Higor Rodrigues Lauer
  - João Vitor Gomes Zeri
  - Erick Saymon Contadini Markoviscz
- **Curso/Turma:** Tecnologia em Análise e Desenvolvimento de Sistemas (ADS) — IFRO Campus Ariquemes / 2024
- **Categoria:** Desafio Livre de Impacto Regional

---

## Problema

Confeiteiros e padeiros artesanais — em sua maioria microempreendedores e produtores de fins de semana em Ariquemes e região — frequentemente não sabem exatamente quanto custa cada receita nem por qual preço vender para ter lucro real. A precificação é feita "no chute" ou baseada na concorrência, o que gera perdas invisíveis, venda no prejuízo e subvalorização do trabalho artesanal.

**Público impactado:** microempreendedores, confeiteiros e padeiros artesanais de Ariquemes/RO e região — incluindo cantinas de instituições de ensino e produtores de fins de semana.

---

## Solução

O **CustoDoce** é um aplicativo multiplataforma (Android e Web) que resolve a precificação artesanal de ponta a ponta:

- **Cadastro de Ingredientes:** preço por embalagem, custo por grama/ml/unidade calculado automaticamente
- **Receitas Inteligentes:** custo total em tempo real ao montar a receita com os ingredientes
- **Precificação Completa:** custos invisíveis (gás, água, energia) + margem de lucro + preço de venda sugerido
- **Dashboard de Lucratividade:** custo bruto, custo invisível, fundo de investimento e lucro líquido por produto
- **Cardápio Digital:** exportação em PDF e compartilhamento por texto (Planos Pro e Premium)
- **Assistente de IA:** dúvidas de confeitaria, conversão de medidas, substituição de ingredientes via Gemini (Plano Premium)

---

## Link do MVP

> 🌐 **Acesse agora:** [https://custodoce-b07ce.web.app/#/login](https://custodoce-b07ce.web.app/#/login)

> ⚠️ A versão web é otimizada para **dispositivos móveis e tablets**. Em desktops, o layout não preenche toda a largura da tela — isso é intencional: o foco do projeto é o uso mobile. Para a experiência completa, use o app Android.

---

## Pitch / Slides

> 📊 **Acesse os slides:** [Apresentação CoreMetrics — CustoDoce](https://docs.google.com/presentation/d/1HMquVg4HxbltH5g_aBpzByMYrBl4BlXSMM0wFQwfzLU/edit?usp=sharing)

---

## Como Testar

**Acesse o MVP:** [https://custodoce-b07ce.web.app/#/login](https://custodoce-b07ce.web.app/#/login)

**Conta de teste (avaliador):**
```
E-mail: avaliador@custodoce.app
Senha:  hackathon2026
```

**Fluxo principal:**
1. Acesse **Ingredientes** → adicione insumos (ex: Leite Condensado 395g por R$ 6,00)
2. Vá em **Nova Receita** → adicione foto, rendimento e ingredientes utilizados
3. Ajuste os **Custos Invisíveis** (% para cobrir gás, energia e perdas)
4. Defina a **Estratégia de Lucro** (markup ou margem %)
5. Veja o resumo: custo total, lucro líquido e preço de venda sugerido

**Download do APK Android:** [Seção de Releases](https://github.com/WellingtonPereiraLuiz/CustoDoce/releases)

---

## Tecnologias Utilizadas

| Camada | Tecnologia |
|---|---|
| Framework | Flutter 3.22+ / Dart |
| Arquitetura | Clean Architecture + Riverpod |
| Banco local | SQLite (sqflite / drift) |
| Autenticação | Firebase Auth |
| Hospedagem web | Firebase Hosting |
| CI/CD | GitHub Actions (auto-deploy Firebase no push main) |
| Roteamento | go_router |
| Gráficos | fl_chart |
| Geração de PDF | pdf (Flutter) |
| Compartilhamento | share_plus |
| Fontes | Google Fonts (Source Serif 4 + DM Sans) |
| Plataformas | Android + Web |

---

## Uso de IA

| Ferramenta | Finalidade | Partes do projeto |
|---|---|---|
| **Runable (Claude)** | Planejamento de arquitetura, geração de prompts de desenvolvimento, análise de requisitos, documentação técnica | Roadmap, README, análise do edital, prompts de automação (v1 a v8) |
| **Antigravity CLI** | Execução dos prompts no projeto Flutter — geração de telas, providers, datasources, modelos, lógica de banco e roteamento | Todo o código-fonte do app |
| **Stitch (AI UI/UX)** | Definição da estética inicial, paleta de cores, tipografia e design system | Identidade visual e tema do app |
| **Google Gemini API** | Assistente integrado ao app (Plano Premium) — dúvidas de confeitaria, conversão de medidas, substituição de ingredientes | Feature `ai_chat_screen` |

**Sobre o uso responsável de IA:**
- Todo código gerado foi revisado, testado e ajustado manualmente pelos integrantes
- Prompts iterativos com múltiplas rodadas de correção e validação
- Decisões de produto (planos, preços, escopo de features, arquitetura) foram tomadas pela equipe
- Nenhuma credencial, chave de API ou dado sensível foi inserido em ferramentas externas de IA

---

## Validação

- **Caso real — origem do projeto:** o CustoDoce nasceu de uma necessidade identificada no negócio **"Nossos Quitutes"** (produção artesanal de trufas e biscoitos em Ariquemes/RO), operado por um dos integrantes da equipe. A precificação era feita no chute — muitas vezes cobrando certo por sorte, sem saber o custo real por unidade
- **Entrevistas com cantinas de instituições de ensino:** realizamos entrevistas com operadores de cantinas de faculdades em Ariquemes. O feedback foi positivo, com destaque para a funcionalidade do assistente de IA para atualização de preços de ingredientes e receitas, o que facilita o dia a dia de quem lida com variação de insumos
- **Teste prático com receitas reais:** o app foi testado com receitas reais (trufas, biscoitos) para validar os cálculos de custo, margem de lucro e preço sugerido
- **Conta de avaliação:** criada especificamente para que a banca possa testar o fluxo completo sem necessidade de cadastro

---

## Planos e Assinaturas

| Plano | Preço | Receitas | Ingredientes | Cardápio Digital | Assistente IA |
|---|---|---|---|---|---|
| Free | Grátis | 3 | 15 | ✗ | ✗ |
| Light | R$ 19,90/mês | 30 | 100 | ✗ | ✗ |
| Pro | R$ 34,90/mês | Ilimitado | Ilimitado | ✅ | ✗ |
| Premium | R$ 49,90/mês | Ilimitado | Ilimitado | ✅ | ✅ |

---

## Testes e Validação

Esta seção documenta o plano mínimo de teste do CustoDoce, atendendo ao item de qualidade exigido pelo edital da Hackathon Extensionista IFRO Ariquemes 2026/1.

### Oráculo da solução

O resultado está correto quando:
- Os valores calculados pelo app coincidem com os cálculos manuais nas fórmulas de negócio
- Os limites de plano impedem ações não permitidas sem quebrar o fluxo
- Os dados persistem entre sessões exatamente como foram inseridos

### Testes automatizados

A suíte de testes está em `test/` e cobre **8 grupos** com **30+ asserções**:

| Arquivo | Grupos | O que testa |
|---|---|---|
| `test/widget_test.dart` | Fórmulas de precificação, Limites de plano, Autenticação, Validação de formulários, Lógica de cardápio | Regras de negócio, limites de plano, guards de autenticação |
| `test/models_test.dart` | Models Test | Entidades de domínio (IngredientEntity, RecipeEntity, copyWith) |

### Plano mínimo de teste

| Funcionalidade | Oráculo | Caminho feliz | Erro / borda | Evidência |
|---|---|---|---|---|
| Cálculo de custo unitário | `custo_embalagem / quantidade_embalagem` | 1000g × R$5,50 → R$0,0055/g | Qty=0 → validação impede divisão por zero | `widget_test.dart` grupo "Fórmulas" |
| Preço sugerido com margem | `custo × (1 + margem/100)` | R$12,00 + 40% → R$16,80 | Margem 0% → preço = custo | `widget_test.dart` |
| Arredondamento psicológico | decimal < 0,50→X,50; 0,50–0,74→X,99; ≥0,75→inteiro | R$1,20 bruto → R$1,50 exibido | R$5,00 inteiro → sem alteração | `widget_test.dart` (4 casos de borda) |
| Limites de plano | Free: máx 3 receitas; Light: máx 30; Pro/Premium: ilimitado | Usuário Free cadastra 3ª → sucesso | Usuário Free tenta 4ª → paywall; 0 extras no banco | `widget_test.dart` grupo "Limites" |
| Cardápio — filtro showInMenu | Exibe só receitas marcadas para o menu | 2/3 receitas marcadas → cardápio exibe 2 | 0 marcadas → lista vazia sem crash | `widget_test.dart` grupo "Cardápio" |
| Validação de formulário de login | Email inválido e senha curta rejeitados antes de chamar Firebase | email válido + senha ≥6 → prossegue | Email sem @ → "Email inválido"; "123" → "Mínimo 6 caracteres" | `widget_test.dart` grupo "Formulários" |
| Persistência SQLite | Receita cadastrada disponível ao reabrir o app | Cadastro + restart → receita listada com todos os campos | — | Validação manual — receitas reais |
| Modo visitante — acesso restrito | Visitante não acessa features pagas | Visitante acessa telas públicas → sem redirecionamento indevido | Visitante tenta cardápio → `locked_feature_screen` sem crash | `widget_test.dart` grupo "Autenticação" |

### Validação com usuário real

- **Nossos Quitutes (Ariquemes/RO):** negócio artesanal de trufas e biscoitos. Receitas reais cadastradas e comparadas com planilha manual — resultados idênticos
- **Cantinas de faculdades em Ariquemes:** entrevistas realizadas; feedback positivo sobre cálculo de custo e IA para atualização de preços
- **Conta de avaliação pública:** `avaliador@custodoce.app` / `hackathon2026` — banca pode testar o fluxo completo sem cadastro

### Abordagem adotada (BSTQB, 2023, Cap. 6)

Testes baseados em exemplos (example-based testing): regras determinísticas de negócio permitem definir o oráculo com precisão e cobrir caminho feliz + caminhos de erro com entradas concretas. Complementado por validação manual com usuário real para cobertura de usabilidade e persistência.

> "Ter testes passando não prova que o sistema está integralmente correto" (BSTQB, 2023) — por isso a validação manual com dados reais complementa a suíte automatizada.

**Referências:**
- BSTQB. *Certified Tester Foundation Level Syllabus v4.0*, Cap. 6, p. 52-53. 2023.
- COUTINHO; NASCIMENTO. *Desafios e benefícios da implementação de testes automatizados em empresas de software.* Cuadernos de Educación y Desarrollo, v.17, n.4, 2025.

---

## Estrutura do Projeto

```
CustoDoce/
├── lib/
│   ├── main.dart                        # Entrypoint do app
│   ├── firebase_options.dart            # Configuração Firebase (gerado)
│   ├── core/
│   │   ├── constants/                   # Strings, chaves e constantes globais
│   │   ├── enums/                       # UnitOfMeasure, RecipeCategory, SubscriptionPlan
│   │   ├── models/                      # SubscriptionPlan, PlanLimits
│   │   ├── providers/                   # AuthProvider, SubscriptionProvider, ThemeProvider
│   │   ├── router/                      # GoRouter config + RouteGuardFeedback
│   │   ├── services/                    # FirebaseAuthService, FirestoreService
│   │   ├── theme/                       # AppTheme (dark/light)
│   │   └── utils/                       # ImageUtils, PriceUtils, ValidationUtils
│   ├── data/
│   │   ├── local/                       # SQLite datasources (v5 schema)
│   │   └── repositories/               # Implementações dos repositórios
│   ├── domain/
│   │   ├── entities/                    # IngredientEntity, RecipeEntity
│   │   └── repositories/               # Interfaces dos repositórios
│   └── presentation/
│       ├── providers/                   # RecipeBuilderProvider, RecipeListProvider, IngredientProvider
│       ├── screens/
│       │   ├── auth/                    # LoginScreen, RegisterScreen
│       │   ├── home/                    # HomeScreen
│       │   ├── recipe/                  # RecipesScreen, RecipeDetailScreen
│       │   ├── recipe_builder/          # RecipeBuilderScreen (criar/editar receita)
│       │   ├── ingredient_manager/      # IngredientManagerScreen
│       │   ├── digital_menu/            # DigitalMenuScreen (Pro/Premium)
│       │   ├── ai_chat/                 # AiChatScreen (Premium — Gemini API)
│       │   ├── paywall/                 # PaywallScreen, LockedFeatureScreen
│       │   ├── settings/                # SettingsScreen
│       │   ├── splash/                  # SplashScreen
│       │   └── main/                    # MainScreen (NavBar 4 abas)
│       └── widgets/                     # Componentes reutilizáveis
├── test/
│   ├── widget_test.dart                 # 24+ testes de regras de negócio e limites de plano
│   └── models_test.dart                 # Testes de entidades de domínio
├── assets/                              # Imagens, ícones, fontes
├── web/                                 # Configuração do build web (Firebase Hosting)
├── android/                             # Configuração Android
├── ios/                                 # Configuração iOS
├── .github/workflows/                   # CI/CD — deploy automático Firebase
├── CHANGELOG.md                         # Histórico de versões
├── DEPLOY.md                            # Instruções de deploy Firebase
└── pubspec.yaml                         # Dependências e versão (1.3.3+6)
```

---

## Segurança da Informação

Esta seção documenta as práticas de segurança adotadas no CustoDoce, alinhadas ao OWASP Top 10 e às diretrizes do Hackathon Extensionista IFRO 2026/1.

### Medidas implementadas

| Medida | Como foi aplicada |
|---|---|
| **Autenticação segura** | Firebase Authentication — senhas armazenadas com hash seguro (bcrypt/scrypt gerenciado pelo Firebase), nunca em texto puro |
| **Recuperação de senha** | Nativo via Firebase Auth — link enviado por e-mail |
| **Controle de acesso por perfil** | Quatro perfis: Free, Light, Pro e Premium — cada um com limites definidos em `PlanLimits` |
| **Proteção de rotas** | `RouteGuardFeedback` (`lib/core/router/`) bloqueia acesso a telas restritas e redireciona com feedback visual |
| **Validação de formulários** | Campos de e-mail, senha e dados de receita validados antes de qualquer requisição (testado em `widget_test.dart`) |
| **Proteção contra SQL Injection** | Todas as queries SQLite usam `whereArgs` com parâmetros separados — zero interpolação de string em queries |
| **HTTPS em produção** | Firebase Hosting aplica TLS automaticamente — toda comunicação web é criptografada |
| **Chaves e credenciais fora do GitHub** | Nenhuma chave de API, token ou senha foi commitada. `firebase_options.dart` usa configuração pública do Firebase (sem secret keys). Gemini API Key gerenciada em variável de ambiente |
| **Sem coleta de dados desnecessária** | O app armazena apenas: e-mail (autenticação), dados de receitas e ingredientes inseridos pelo próprio usuário. Nenhum dado de localização, biometria ou financeiro é coletado |
| **Modo visitante com acesso limitado** | Conta guest não acessa features pagas — guard implementado e testado |

---

### OWASP Top 10 — Análise aplicada ao CustoDoce

| # | Vulnerabilidade OWASP | Avaliação no projeto |
|---|---|---|
| A01 | Quebra de controle de acesso | **Mitigado** — RouteGuardFeedback + PlanLimits bloqueiam acesso indevido a rotas e features |
| A02 | Falhas criptográficas | **Mitigado** — Firebase Auth gerencia hash de senhas; HTTPS em produção |
| A03 | Injeção (SQL Injection) | **Mitigado** — sqflite com `whereArgs` parametrizados em 100% das queries |
| A04 | Projeto inseguro | **Parcialmente mitigado** — arquitetura Clean com separação de camadas; sem lógica de negócio exposta na UI |
| A05 | Configuração insegura | **Mitigado** — Firebase Hosting com HTTPS, sem portas expostas, sem painel admin público |
| A06 | Componentes vulneráveis | **Parcialmente mitigado** — dependências gerenciadas via `pubspec.yaml`; versões fixadas |
| A07 | Falhas de identificação e autenticação | **Mitigado** — Firebase Auth com validação de e-mail, senha mínima 6 caracteres, sem senhas em texto puro |
| A08 | Falhas de integridade de software | **Parcialmente mitigado** — builds gerados localmente; CI/CD via GitHub Actions sem execução de código externo |
| A09 | Falhas de registro e monitoramento | **Limitação conhecida** — sem log de auditoria de ações do usuário (ver seção abaixo) |
| A10 | SSRF | **Não aplicável** — app não faz requisições server-side baseadas em input do usuário |

---

### Uso de IA na revisão de segurança

- Trechos de código foram revisados com auxílio do **Runable (Claude)** para identificar padrões inseguros
- Nenhuma credencial, chave de API, senha ou dado sensível de usuário real foi enviado para ferramentas de IA
- A análise do OWASP Top 10 acima foi construída com apoio de IA e validada manualmente pelos integrantes

---

### Limitações conhecidas

- **Sem log de auditoria:** ações do usuário (login, criação de receita, upgrade de plano) não são registradas em log estruturado — melhoria prevista para versão pós-hackathon
- **Sem bloqueio por tentativas:** Firebase Auth não tem bloqueio automático por IP configurado neste MVP — mitigado pelo reCAPTCHA invisível do Firebase na web
- **Sem teste formal com OWASP ZAP:** o MVP web foi verificado manualmente; teste automatizado de vulnerabilidades fica como melhoria futura
- **Banco local sem criptografia:** o SQLite local no Android não usa SQLCipher — dados de receitas ficam no armazenamento interno do dispositivo (sem acesso externo sem root)

---



**Pré-requisitos:** Flutter SDK >= 3.22, conta Firebase configurada

```bash
git clone https://github.com/WellingtonPereiraLuiz/CustoDoce.git
cd CustoDoce
flutter pub get
flutter run -d chrome
```

Configure as variáveis de ambiente Firebase conforme `DEPLOY.md`.

---

## Licença

Projeto acadêmico desenvolvido para o **Hackathon Extensionista IFRO Ariquemes 2026/1**.  
Uso livre para fins educacionais e não comerciais.  
© 2026 — CoreMetrics | Wellington Pereira Luiz, Higor Rodrigues Lauer, João Vitor Gomes Zeri, Erick Saymon Contadini Markoviscz
