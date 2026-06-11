# CustoDoce 🍫

> Calculadora de custos e precificação para confeiteiros e padeiros.

Desenvolvido por Wellington Pereira Luiz — Hackathon IFRO 2025.

---

## Sobre o Projeto

O **CustoDoce** resolve a principal dor de quem trabalha com confeitaria artesanal: saber exatamente quanto custa cada receita e por quanto vender para ter lucro de verdade.

Com ele, o confeiteiro cadastra seus ingredientes com base no valor da embalagem comprada, monta suas receitas informando as quantidades utilizadas, e o app calcula automaticamente o custo total, o custo por porção e o preço de venda com a margem de lucro desejada.

---

## Funcionalidades

- **Gestão de Ingredientes** — cadastro com preço por embalagem; o app calcula o custo por grama/ml/unidade automaticamente
- **Calculadora de Receitas** — monte receitas selecionando ingredientes e quantidades; custo calculado em tempo real
- **Precificação Inteligente** — defina sua margem de lucro e taxa de desperdício; o app sugere o preço de venda ideal
- **Tela de Detalhes** — visualize custo por porção, preço sugerido e lista completa de ingredientes com custos individuais
- **Compartilhar Receita** — envie o resumo financeiro da receita via qualquer app (WhatsApp, e-mail etc.)
- **Login com Google** — autenticação via Firebase Auth (Google Sign-In)
- **Tema Claro e Escuro** — Modo Claro refinado e Modo Escuro premium (paleta Chocolate/Espresso)
- **Banco de Dados Local** — armazenamento offline com SQLite; funciona sem internet
- **Proteção Free/Pro** — usuários gratuitos podem cadastrar até 3 receitas

---

## Telas

| Tela | Descrição |
|------|-----------|
| Splash | Inicialização e verificação de autenticação |
| Login | Acesso com e-mail/senha ou Google |
| Home | Lista de receitas com custo e preço sugerido |
| Gerenciar Ingredientes | CRUD completo de ingredientes |
| Construtor de Receitas | Montagem de receita com ingredientes e quantidades |
| Detalhes da Receita | Custos detalhados + lista de ingredientes |
| Configurações | Tema, idioma e dados da conta |
| Paywall | Apresentação do plano Pro |

---

## Estrutura do Projeto

```
lib/
├── core/
│   ├── constants/       # Constantes globais (rotas, limites, chaves)
│   ├── enums/           # Enums de categoria de receita e unidades de medida
│   ├── error/           # Classes de falha (Failures)
│   ├── l10n/            # Strings localizadas (pt-BR / en-US)
│   ├── providers/       # Providers globais (auth, settings, subscription)
│   ├── router/          # Configuração de rotas com GoRouter
│   ├── services/        # AuthService, SubscriptionService (RevenueCat)
│   ├── theme/           # Design System — AppTheme (fonte da verdade)
│   └── utils/           # Utilitários (seeder, uuid)
├── data/
│   ├── local/
│   │   ├── database/    # DatabaseHelper (SQLite via sqflite)
│   │   ├── datasources/ # Datasources locais de ingredientes e receitas
│   │   └── models/      # Models de ingrediente, receita e recipe_ingredient
│   └── repositories/    # Implementações dos repositórios
├── domain/
│   ├── entities/        # Entidades puras (Ingredient, Recipe, RecipeIngredient)
│   └── repositories/    # Interfaces dos repositórios
├── presentation/
│   ├── providers/       # Providers de UI (recipe, ingredient, recipe_builder)
│   └── screens/         # Telas do app (auth, home, recipe, settings etc.)
├── firebase_options.dart
└── main.dart
```

---

## Como Rodar

### Pré-requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) >= 3.3.0
- Arquivo `.env` na raiz do projeto com as chaves do Firebase (não versionado — solicitar ao time)

### Rodar na Web

```bash
flutter pub get
flutter run -d chrome --dart-define-from-file=.env
```

Acessem em `http://localhost:PORT` (porta exibida no terminal).

### Rodar no Emulador Android

```bash
flutter pub get
flutter run -d emulator-5554 --dart-define-from-file=.env
```

> Substitua `emulator-5554` pelo ID do seu emulador (`flutter devices` para listar).

### Rodar no Dispositivo Físico (Android)

1. Ative o **Modo Desenvolvedor** e **Depuração USB** no celular
2. Conecte via USB
3. Execute:
```bash
flutter run --dart-define-from-file=.env
```

---

## Gerar APK (Release)

```bash
flutter build apk --release --dart-define-from-file=.env
```

O APK gerado estará em:
```
build/app/outputs/flutter-apk/app-release.apk
```

Para instalar diretamente no dispositivo conectado via USB:
```bash
flutter install
```

> O arquivo `.env` deve conter as variáveis do Firebase. Veja `.env.example` para o formato esperado.

---

## Variáveis de Ambiente

O projeto usa `--dart-define-from-file=.env` para injetar as chaves em tempo de compilação. Crie um arquivo `.env` na raiz com base no exemplo abaixo:

```
FIREBASE_API_KEY=sua_chave_aqui
FIREBASE_APP_ID_ANDROID=seu_app_id_android
FIREBASE_APP_ID_WEB=seu_app_id_web
FIREBASE_MESSAGING_SENDER_ID=seu_sender_id
FIREBASE_PROJECT_ID=seu_project_id
FIREBASE_AUTH_DOMAIN=seu_project.firebaseapp.com
FIREBASE_STORAGE_BUCKET=seu_project.firebasestorage.app
FIREBASE_MEASUREMENT_ID=G-XXXXXXXXXX
```

> **Nunca versione o `.env` real.** Ele está no `.gitignore`.

---

## Stack

| Tecnologia | Uso |
|-----------|-----|
| Flutter | Framework multiplataforma |
| Riverpod | Gerenciamento de estado |
| GoRouter | Navegação declarativa |
| SQLite (sqflite) | Banco de dados local offline |
| Firebase Auth | Autenticação (e-mail + Google) |
| RevenueCat | Monetização e controle de assinatura |
| share_plus | Compartilhamento de receitas |

---

## Time

Desenvolvido como projeto para o Hackathon IFRO 2025.
