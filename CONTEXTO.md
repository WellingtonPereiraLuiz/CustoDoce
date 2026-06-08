# CustoDoce - Contexto e Progresso do Projeto

Este documento serve como um registro do estado atual do projeto **CustoDoce**, detalhando a arquitetura atual, o que já foi construído, os desafios superados e o fluxo de trabalho seguido pelas IAs/Agentes e desenvolvedores envolvidos no projeto. 

Isso garantirá que qualquer nova interação ou desenvolvedor que entre no projeto tenha total clareza do ponto em que paramos.

---

## 1. Visão Geral e Contexto da Aplicação
O **CustoDoce** é um aplicativo mobile e web voltado para confeiteiros e pequenos empreendedores gastronômicos. Ele resolve a dor de "precificar produtos sem prejuízo", oferecendo:
- Gestão de ingredientes e unidades de medida.
- Construção de receitas detalhadas.
- Cálculo automático do custo por receita e por porção.
- Inclusão de "custos invisíveis" (água, luz, gás, perdas) via porcentagem.
- Estratégias de lucro usando Markup (multiplicador padrão na confeitaria) ou Margem de Lucro percentual.
- Limite de receitas para contas Free (Paywall/Premium).

**Stack Tecnológica:**
- **Framework:** Flutter (3.24.4) / Dart (3.5.4)
- **Gerenciamento de Estado:** Riverpod (AsyncNotifier)
- **Roteamento:** GoRouter
- **Banco de Dados Local:** SQLite (usando `sqflite` no mobile e `sqflite_common_ffi_web` no Flutter Web)
- **Autenticação:** Firebase Auth (Email/Senha e Google Sign-In)

---

## 2. O Que Foi Feito e a Ordem Cronológica

### Fase 1: Análise e Adequação Inicial
1. **Inspeção de Código:** Mapeamos toda a estrutura do Riverpod, SQLite e UI. O código já possuía uma base estrutural bem definida para Repositórios (`RecipeRepositoryImpl`), Entidades (`RecipeEntity`) e Providers.
2. **Correção de Chaves do Firebase:** O Firebase estava falhando ao fazer login e criar contas devido a credenciais padrão/inválidas.
   - *Como foi feito:* O usuário providenciou um novo arquivo `google-services.json` válido e as chaves reais de API da web.
   - *Segurança:* Substituímos o uso de `flutter_dotenv` (que carregava `.env` como um asset inseguro) pelo padrão oficial `--dart-define-from-file=.env`. O código agora puxa as variáveis em tempo de compilação com `String.fromEnvironment`.

### Fase 2: Correção de Bugs e Ajustes de UI/UX
1. **Identidade Visual:** 
   - *O que:* Mudamos o tema padrão para o Tema Claro (Light Mode) de forma nativa e fixa, já que o Dark Mode anterior não agradava a estética de "CustoDoce".
   - *Como:* O `AppTheme` ganhou cores em tons de Marrom Chocolate e Creme. A tipografia foi atualizada para `SourceSerif4` (Títulos) e `WorkSans` (Corpos).
2. **Correção do Bug de Cores Fixas:** 
   - A tela Home (`HomeScreen`) possuía cores *hardcoded* que conflitavam com o Light Mode (ex: textos pretos num fundo escuro). Estas foram removidas em favor do `Theme.of(context)`.
3. **Persistência de Switches na Edição:** 
   - No `RecipeBuilderScreen`, switches como "Custos Invisíveis" e "Markup" não refletiam o estado correto ao editar uma receita. 
   - *Solução:* Ajustado o `loadRecipeForEdit` no provider para derivar corretamente os booleanos (ex: se o `profitMarginPercentage` é >= 100, é markup, senão é margem).
4. **Bug de Logout:** 
   - O botão de "Sair" não deslogava completamente. O método no `auth_provider.dart` foi arrumado e a tela passou a redirecionar para `/login`.

### Fase 3: Evolução do Banco de Dados SQLite (Versão 2 para 3)
Precisávamos incluir "Categoria" e "Rendimento" nas Receitas:
1. Adicionamos os campos `yieldQuantity` (Rendimento) e `category` (Categoria) na Entidade, Modelo e Mapper (`RecipeModel`).
2. Criamos o `enum RecipeCategory` (bolo, torta, brigadeiro, etc.).
3. **Migração do Banco:** Atualizamos a versão do banco no `DatabaseHelper` de `2` para `3`.
   - Adicionamos os comandos `ALTER TABLE recipes ADD COLUMN yield_quantity...` no bloco `_onUpgrade`.
   - Atualizamos também o `_onCreate` para novas instalações.

### Fase 4: Novas Features Completas (Baseadas no prompt_antigravity_v2)
Com a base estável, implementamos as features finais pedidas no roadmap:
1. **Rendimento (Yield):** Campo adicionado no `RecipeBuilderScreen`. O cálculo "Custo por Porção" foi embutido na aplicação.
2. **Sistema de Categorias:** Dropdown incluído na construção da receita.
3. **Animação de Loading (Shimmer):** Adicionado `shimmer` nos Cards de KPI da `HomeScreen` para as transições de carregamento ficarem fluídas e elegantes.
4. **Deslizar para Apagar (Swipe-to-delete):** Implementado `flutter_slidable` na lista de ingredientes. Fica muito mais intuitivo para o confeiteiro remover um item arrastando para a esquerda do que clicando em um `X`.
5. **Busca e Filtro em Tempo Real:** A `HomeScreen` ganhou uma barra de busca (`TextField`) que converteu a exibição da lista em um Widget *Stateful* para filtrar ingredientes da lista localmente de forma instantânea.
6. **Nova Tela de Detalhes (`/recipe/:id`):** 
   - Clicar numa receita não abre mais a edição instantaneamente. Em vez disso, abre uma tela visualmente polida que foca em *exibir* os resultados da receita (Custo da porção, Sugestão de Preço, Categorias).
7. **Botão de Compartilhar:** 
   - Implementado usando o plugin `share_plus`. O aplicativo gera um texto pré-formatado (emoji, nome, porções, valor de custo e valor de venda sugerido) para fácil envio pelo WhatsApp para clientes.

---

## 3. Principais Problemas Enfrentados & Soluções (Troubleshooting Log)
- **[Resolvido] api-key-not-valid no Firebase:** Chave antiga no código. Substituída e injetada via `String.fromEnvironment`.
- **[Resolvido] popup-closed-by-user:** Tratamento de erro quando o usuário cancela o fluxo do Google Sign-In, evitando *crash* na interface.
- **[Resolvido] Perda do tema e quebra de layout:** Atualizamos todas as referências diretas de `Colors.white` ou `Colors.black` para usarem o `Theme.of(context).colorScheme.onSurface` e análogos.
- **[Resolvido] Syntax Error no home_screen.dart:** Durante a injeção da busca, uma chave (`}`) foi fechada a mais, quebrando a compilação. Imediatamente identificado pelos logs do Flutter build e corrigido.

## 4. O Que Testar Atualmente?
Ao rodar a aplicação via `flutter run --dart-define-from-file=.env -d chrome`:
1. Você deve logar (Email ou Google) sem erros.
2. Acessar a Tela Inicial (Clara e Elegante com cores Marrom/Creme).
3. Ver o Shimmer (loading) atuar nos painéis de KPIs.
4. Testar a "Busca" com receitas já cadastradas.
5. Ao Criar/Editar, usar o "Deslizar para a Esquerda" na listagem de ingredientes.
6. Acessar a Tela de Detalhes da receita, ver os custos por porção divididos pelo rendimento, e usar o novo botão de Compartilhar.

## 5. Próximos Passos Sugeridos
- Validar se a versão Mobile (Android/iOS) compila de forma idêntica à Web.
- Testar o fluxo de Paywall (assinatura Premium) se/quando for implementado com RevenueCat.
- Criar a funcionalidade de geração de PDF ou "Modo Etiqueta" a partir da Tela de Detalhes.
