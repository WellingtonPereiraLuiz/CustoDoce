# CustoDoce 🍫

> Calculadora de custos e precificação para confeiteiros e padeiros artesanais.

---

## Equipe

- **Nome da equipe:** CustoDoce
- **Integrantes:** Wellington Pereira Luiz, Higor Rodrigues Lauer, João Vitor Gomes Zeri e Erick Saymon Contadini Markoviscz
- **Curso/Turma:** Tecnologia em Análise e Desenvolvimento de Sistemas (ADS) / IFRO Campus Ariquemes
- **Categoria:** Desafio Livre de Impacto Regional

---

## Problema

Confeiteiros e padeiros artesanais de Ariquemes e região — em sua maioria microempreendedores e produtores de fins de semana — não sabem exatamente quanto custa cada receita nem por qual preço vender para ter lucro real. A precificação é feita "no chute", o que leva à venda no prejuízo ou à subvalorização do trabalho.

**Público impactado:** confeiteiros artesanais, padeiros autônomos, microempreendedores de alimentação e estudantes de gastronomia de Ariquemes, Rondônia e região.

---

## Solução

O **CustoDoce** é um app multiplataforma (Android + Web) que resolve a precificação artesanal de ponta a ponta:

- Cadastro de ingredientes com preço por embalagem → app calcula custo por grama/ml/unidade
- Montagem de receitas com ingredientes e quantidades → custo total calculado em tempo real
- Precificação inteligente: informe a margem de lucro desejada → app sugere o preço de venda ideal
- Dashboard com relatórios de lucratividade e ranking de receitas (plano Pro)
- Cardápio digital compartilhável com link simulado (plano Premium)
- Gestão de equipamentos com cálculo de custo por hora de uso (kWh)
- Funciona offline (SQLite local) com login via Google (Firebase Auth)

---

## Link do MVP

> 🌐 **Acesse a versão Web:** [link do deploy — adicionar após publicação]

A versão Web é responsiva e funciona no navegador, sem instalação. Para testar no Android, baixe o APK na seção [Releases](https://github.com/WellingtonPereiraLuiz/CustoDoce/releases).

---

## Vídeo de pitch

> 🎬 **Link do vídeo de pitch:** [link — adicionar após gravação]

O vídeo apresenta a solução completa, ferramentas utilizadas, uso de IA, o que funciona e o que ainda está em desenvolvimento.

---

## Pitch

> 📊 **Slides de apresentação:** [link — adicionar após criação]

---

## Como testar

### Versão Web (recomendado para avaliação)

1. Acesse o link do MVP acima
2. Faça login com Google ou use a conta de teste:
   - E-mail: `avaliador@custodoce.app`
   - Senha: `hackathon2026`
3. Navegue pelo app: Home → Ingredientes → Nova Receita → Precificar

### Fluxo principal

1. **Ingredientes** → cadastre um ingrediente (ex: Farinha de Trigo 1kg por R$ 5,50)
2. **Nova Receita** → selecione ingredientes e quantidades → o custo total é calculado automaticamente
3. **Precificação** → informe a margem desejada (ex: 40%) → veja o preço de venda sugerido
4. **Dashboard** *(plano Pro)* → veja relatórios de lucratividade
5. **Cardápio Digital** *(plano Premium)* → selecione receitas e compartilhe o cardápio

### Versão Android (APK)

```bash
# Baixe o APK em:
# https://github.com/WellingtonPereiraLuiz/CustoDoce/releases
```

Instale no dispositivo Android com APK de fontes desconhecidas habilitado.

### Rodar localmente (desenvolvimento)

**Pré-requisitos:** Flutter SDK >= 3.3.0, arquivo `.env` com chaves do Firebase.

```bash
git clone https://github.com/WellingtonPereiraLuiz/CustoDoce.git
cd CustoDoce
flutter pub get
flutter run -d chrome --dart-define-from-file=.env
```

> O arquivo `.env` não está versionado. Veja `.env.example` para o formato esperado.

---

## Tecnologias utilizadas

| Tecnologia | Uso |
|-----------|-----|
| Flutter 3 | Framework multiplataforma (Android + Web) |
| Dart | Linguagem de programação |
| Riverpod | Gerenciamento de estado reativo |
| GoRouter | Navegação declarativa |
| SQLite (sqflite) | Banco de dados local offline |
| Firebase Auth | Autenticação (e-mail + Google Sign-In) |
| fl_chart | Gráficos do Dashboard (barras e pizza) |
| share_plus | Compartilhamento de receitas |
| google_fonts | Tipografia (Source Serif 4 + DM Sans) |
| flutter_dotenv | Injeção de variáveis de ambiente |

**Hospedagem/Serviços:** Firebase (Auth), GitHub (repositório e Releases)

---

## Uso de IA

| Ferramenta | Finalidade |
|-----------|-----------|
| **Runable (Claude Sonnet)** | Planejamento de arquitetura, geração de prompts de desenvolvimento, revisão de lógica de negócio, documentação |
| **Antigravity CLI** | Execução de prompts de código no projeto Flutter — geração de telas, providers, modelos e lógica de banco |
| **Stitch (AI UI/UX)** | Refinamento de UI e experiência do usuário |
| **GitHub Copilot** | Autocompletar e sugestões de código durante desenvolvimento |

Todas as implementações geradas por IA foram revisadas, testadas e adaptadas manualmente pelo desenvolvedor. Nenhuma credencial, chave de API ou dado sensível foi inserido em ferramentas externas.

---

## Validação

- O CustoDoce foi inspirado em uma necessidade real: o empreendimento familiar **Nossos Quitutes** (Ariquemes/RO), que produz e vende trufas e biscoitos artesanais nos fins de semana. A precificação era feita de forma empírica, sem controle de custos.
- O app foi testado com receitas reais do negócio familiar, validando a precisão dos cálculos de custo e margem de lucro.
- A interface foi avaliada com usuários não técnicos para garantir usabilidade em smartphones Android de entrada.
- Feedback coletado informalmente com outros confeiteiros do entorno de Ariquemes sobre as funcionalidades prioritárias.

---

## Licença

Projeto acadêmico desenvolvido para a Hackathon Extensionista IFRO Ariquemes 2026/1.  
Finalidade: educacional e demonstrativa.  
Código-fonte disponível neste repositório para avaliação da banca.

---

## Estrutura do Projeto

```
lib/
├── core/
│   ├── constants/       # Constantes globais (rotas, limites, chaves)
│   ├── enums/           # Enums de categoria e unidades de medida
│   ├── providers/       # Providers globais (auth, settings, subscription)
│   ├── router/          # Configuração de rotas com GoRouter
│   ├── services/        # AuthService, SubscriptionService
│   ├── theme/           # Design System — AppTheme
│   └── utils/           # Utilitários (seeder, uuid)
├── data/
│   ├── local/
│   │   ├── database/    # DatabaseHelper (SQLite)
│   │   ├── datasources/ # Datasources locais
│   │   └── models/      # Models de dados
│   └── repositories/    # Implementações dos repositórios
├── domain/
│   ├── entities/        # Entidades puras
│   └── repositories/    # Interfaces dos repositórios
└── presentation/
    ├── providers/       # Providers de UI
    └── screens/         # Telas do app
```

---

## Planos

| Plano | Receitas | Ingredientes | Equipamentos | Relatórios | Cardápio Digital |
|-------|----------|--------------|--------------|------------|-----------------|
| Free | 3 | 15 | ❌ | ❌ | ❌ |
| Light R$4,90/mês | 30 | 100 | 5 | ❌ | ❌ |
| Pro R$9,90/mês | Ilimitado | Ilimitado | Ilimitado | ✅ | ❌ |
| Premium R$14,90/mês | Ilimitado | Ilimitado | Ilimitado | ✅ | ✅ |

---

## 📋 Changelog

Veja o histórico completo de mudanças em [CHANGELOG.md](CHANGELOG.md).
