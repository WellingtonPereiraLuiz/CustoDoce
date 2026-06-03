# 🍰 CustoDoce

![CustoDoce Logo](assets/images/logo.png)

CustoDoce é a calculadora definitiva de custos de receitas e precificação de produtos para confeiteiros, padeiros e empreendedores da culinária. Desenvolvido para transformar o processo exaustivo de calcular custos e lucros em uma experiência ágil, automatizada e visualmente incrível.

---

## 🎯 Inspiração e Motivos

A precificação correta é um dos maiores desafios na gastronomia. Muitos empreendedores perdem dinheiro por não calcularem custos ocultos (como gás, energia elétrica e embalagens) ou por terem dificuldade em ratear ingredientes de pacotes grandes para gramas/mililitros utilizados na receita.

**O CustoDoce nasceu para resolver esse problema:**
- **Automatizando:** Você cadastra um pacote de farinha de 1kg por R$ 5,00, e ao usar 250g, o app já calcula o custo exato.
- **Maximizando Lucros:** Sugere preços de venda baseados em margens de lucro reais e custos operacionais adicionais.
- **Offline First:** Cozinhas e estoques muitas vezes não têm bom sinal de internet. O aplicativo funciona primariamente offline com banco de dados local.

## 🚀 Detalhes e Funcionalidades

- **Gerenciamento de Ingredientes:** Cadastre insumos, tamanhos de pacote, preço pago e deixe o cálculo do custo unitário por nossa conta.
- **Construtor de Receitas:** Adicione ingredientes à receita dinamicamente e veja o custo subindo em tempo real.
- **Precificação Inteligente:** Adicione margem de lucro (%) e custos operacionais. Obtenha instantaneamente o custo total e o preço sugerido de venda.
- **Modo Escuro / Claro:** Um design premium que se adapta ao seu sistema, com microinterações focadas em conversão e conforto visual.
- **Modelo Freemium (Pro):** Usuários gratuitos podem cadastrar até 3 receitas. Usuários que assinarem o "CustoDoce Pro" possuem receitas ilimitadas.

## 🏗 Estrutura e Fluxo de Criação (Arquitetura)

O aplicativo foi construído em **Flutter** usando **Clean Architecture** e **Riverpod** para o gerenciamento de estado:

```text
lib/
├── core/            # Constantes, Temas (Dark/Light), Tratamento de Erros, Serviços (RevenueCat), Router.
├── data/            # Banco de Dados local (SQLite) e implementações de Data Sources/Models.
├── domain/          # Entidades limpas e Interfaces de Repositório (Regras de negócio isoladas).
└── presentation/    # Telas, Widgets visuais e Providers (Riverpod) para injetar os casos de uso na UI.
```

O fluxo de criação garantiu que toda a camada de banco de dados (`sqflite` com `PRAGMA foreign_keys = ON`) estivesse pronta antes de qualquer tela ser construída. A comunicação com RevenueCat (`purchases_ui_flutter`) foi isolada na camada de serviço para não acoplar a UI.

## 📦 Downloads (APK e iOS)

### Android (APK)
O APK final de produção (Release) para Android é gerado diretamente na pasta de builds do projeto. Após rodar a build, você pode encontrá-lo neste caminho no seu computador:
👉 `build/app/outputs/flutter-apk/app-release.apk`

### iOS (IPA)
*Nota:* Aplicativos iOS não utilizam APK, mas sim arquivos IPA. Para construir o aplicativo para iOS, é necessário abrir o projeto no Xcode utilizando um computador macOS (`flutter build ipa`).

---

## 🛠 Tecnologias Utilizadas

- **Flutter & Dart:** Base de desenvolvimento multiplataforma.
- **Riverpod:** Gerenciamento de estado reativo e injeção de dependência.
- **GoRouter:** Navegação baseada em URLs, pronta para web e deep links.
- **Sqflite:** Banco de dados relacional (SQL) embarcado e rápido.
- **RevenueCat:** Gestão de infraestrutura de pagamentos in-app e assinaturas nativas.

---
Feito com dedicação para empoderar negócios locais. 👩‍🍳👨‍🍳
