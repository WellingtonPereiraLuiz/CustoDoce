# CustoDoce 🍰

**CustoDoce** é o aplicativo definitivo para confeiteiros e empreendedores gastronômicos precificarem suas receitas de forma rápida, inteligente e profissional.

Não perca mais tempo calculando grama por grama no papel. O CustoDoce faz tudo por você: desde o controle do seu estoque de ingredientes até a definição da sua margem de lucro perfeita.

## 🚀 Funcionalidades

- **Autenticação Real:** Login nativo com E-mail/Senha e Google Sign-In (Firebase Auth).
- **Gestão de Ingredientes:** Cadastre os ingredientes com base no valor da embalagem fechada. O aplicativo calcula automaticamente a fração exata usada em cada receita.
- **Calculadora Automática de Custos:** Construa receitas arrastando ingredientes. Descubra o custo exato de produção.
- **Precificação e Margem de Lucro:** Defina sua taxa de desperdício (custo invisível) e sua margem de lucro desejada. O aplicativo te diz exatamente por quanto vender.
- **Temas Dinâmicos:** Um belíssimo **Modo Escuro** premium (Chocolate/Espresso) e um **Modo Claro** refinado.
- **Banco de Dados Local:** Alta velocidade com armazenamento offline usando SQLite (Persistência garantida na base de dados).

## 🛠️ Tecnologias Utilizadas

- **[Flutter](https://flutter.dev/):** Framework para desenvolvimento Multiplataforma.
- **[Riverpod](https://riverpod.dev/):** Gerenciamento de estado reativo e robusto.
- **[Firebase Authentication](https://firebase.google.com/docs/auth):** Backend de Autenticação para Google Sign-In e Contas de E-mail.
- **[Sqflite](https://pub.dev/packages/sqflite):** Banco de dados SQLite para cache de receitas e ingredientes.
- **[GoRouter](https://pub.dev/packages/go_router):** Navegação fluida e declarativa por rotas.

## 📦 Como Rodar o Projeto

### Pré-requisitos
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (versão >= 3.3.0)
- Um projeto configurado no [Firebase Console](https://console.firebase.google.com/)

### Passos para instalação

1. Clone este repositório:
   ```bash
   git clone https://github.com/SEU_USUARIO/custo_doce.git
   ```

2. Entre no diretório do projeto:
   ```bash
   cd custo_doce
   ```

3. Instale as dependências:
   ```bash
   flutter pub get
   ```

4. *Opcional: Configure suas chaves do Firebase* 
   Se quiser compilar as versões finais de Android/iOS, certifique-se de baixar os arquivos `google-services.json` e `GoogleService-Info.plist` no Firebase Console ou rode o `flutterfire configure`.

5. Inicie a aplicação (exemplo na web):
   ```bash
   flutter run -d chrome
   ```

## 📦 Gerar APK (Release)

### Pré-requisitos
- Flutter SDK instalado e configurado
- Variáveis de ambiente do Firebase configuradas

### Build local

1. Crie o arquivo `.env.dart_define` na raiz do projeto com as chaves Firebase:
   ```
   FIREBASE_API_KEY=sua_chave
   FIREBASE_APP_ID=seu_app_id
   FIREBASE_MESSAGING_SENDER_ID=seu_sender_id
   FIREBASE_PROJECT_ID=seu_project_id
   FIREBASE_AUTH_DOMAIN=seu_auth_domain
   FIREBASE_STORAGE_BUCKET=seu_storage_bucket
   ```

2. Execute o build:
   ```bash
   flutter build apk --release --dart-define-from-file=.env.dart_define
   ```

3. O APK gerado estará em:
   ```
   build/app/outputs/flutter-apk/app-release.apk
   ```

4. Para instalar no dispositivo via USB:
   ```bash
   flutter install
   ```
   Ou copie o APK manualmente para o dispositivo e instale habilitando "Fontes desconhecidas".

### Download direto
> Link do APK de demonstração: *(adicionar link após gerar e hospedar o APK)*

## 🏗️ Estrutura e Atualizações Recentes

Durante a última maratona de desenvolvimento, implementamos melhorias significativas na estrutura, segurança e estabilidade do projeto:

### 1. Migração de Variáveis de Ambiente (Segurança)
- **Problema:** A dependência `flutter_dotenv` estava causando inconsistências e conflitos (root clash) na leitura de chaves de API (Firebase) durante a geração da build de Release para o Android.
- **Solução:** Removemos totalmente o uso do pacote `dotenv` nos arquivos críticos (`firebase_options.dart` e `app_constants.dart`). Toda a injeção de dependências agora é feita no momento de compilação de forma segura nativa usando `--dart-define-from-file=.env.dart_define` com a função `String.fromEnvironment()`.

### 2. Design System Consistente (Artisanal Ledger)
- **Implementação:** Padronizamos a UI removendo todas as cores estáticas (ex: `Colors.orangeAccent`, `Colors.blue`) diretamente inseridas nas telas.
- **Estrutura:** O design agora é centralizado no `AppTheme` (arquivo `lib/core/theme/app_theme.dart`). As telas de `home_screen.dart`, `recipe_builder_screen.dart` e `ingredient_manager_screen.dart` consomem ativamente os *tokens* de tema (`Theme.of(context).colorScheme`).
- **Correção de Bugs:** Ajustamos a árvore de Widgets corrigindo problemas de parênteses soltos e chamadas irregulares de `const` (que não aceitam `Theme.of(context)` dinâmico) evitando assim *crashes* na tela preta.

### 3. Estabilidade do Gradle e Build Android
- **Problema:** A compilação do Android no ambiente Windows sofria paradas e *crashes* por estouro do limite de memória da máquina host (JVM Daemon desaparecia subitamente tentando alocar 12GB).
- **Solução:** Editamos o arquivo `android/gradle.properties` reduzindo drasticamente os limites do `org.gradle.jvmargs` de `-Xmx8G` para um valor seguro de `-Xmx2048M -XX:MaxMetaspaceSize=512m`. O compilador agora funciona perfeitamente bem, gerando o arquivo APK de produção limpo.

### 4. Proteção de Usuários Free
- **Funcionalidade:** Reforçamos o bloqueio na `recipe_builder_screen.dart` utilizando o `isProUserProvider`. Agora, o aplicativo automaticamente checa e proíbe a criação da 4ª receita para usuários gratuitos sem assinatura.


## 🧑‍🍳 Ficha Técnica
Criado com foco em resolver a principal dor dos confeiteiros: entender onde o dinheiro está indo e garantir que cada doce vendido gere lucro de verdade.
