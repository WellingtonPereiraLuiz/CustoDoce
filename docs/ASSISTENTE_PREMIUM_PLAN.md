# Assistente Premium

## Objetivo

Implementar um assistente Premium com quatro capacidades:

1. Consultoria culinaria e de precificacao
2. Cadastro e atualizacao de ingredientes por conversa
3. Criacao de receitas por conversa
4. Leitura de nota fiscal por imagem com revisao antes de aplicar

## Modelo selecionado

- Provedor: OpenRouter
- Modelo padrao: `google/gemini-3.1-flash-lite`
- Motivos:
  - baixo custo por entrada e saida
  - aceita imagem
  - aceita saida estruturada
  - contexto amplo, bom para catálogos longos de ingredientes

## Arquitetura

### Camadas

1. UI de chat
2. Orquestracao do assistente
3. Persistencia local de historico e logs
4. Integracao com OpenRouter
5. Aplicacao segura das alteracoes no banco

### Regras de confianca

- O assistente nunca grava direto sem confirmacao do usuario
- Toda alteracao vira uma previa primeiro
- Toda alteracao confirmada gera log de acao

## Fluxos

### Consulta

1. Usuario pergunta
2. Modelo responde em linguagem natural
3. Nenhuma alteracao em banco

### Ingrediente

1. Usuario descreve o ingrediente ou ajuste
2. Modelo devolve acao estruturada
3. App mostra card de previa
4. Usuario confirma
5. App cria ou atualiza ingrediente

### Receita

1. Usuario descreve a receita
2. Modelo mapeia ingredientes do catalogo existente
3. App monta previa de ficha tecnica
4. Usuario confirma
5. App salva receita

### Nota fiscal

1. Usuario envia imagem
2. Modelo extrai itens e sugere correspondencias
3. App mostra revisao
4. Usuario confirma
5. App atualiza os ingredientes selecionados

## Persistencia

### Tabelas

- `assistant_conversations`
- `assistant_messages`
- `assistant_actions`

## Fases

### Fase 1

- Infraestrutura do chat
- Historico local
- Integracao com OpenRouter

### Fase 2

- Consulta
- Ingrediente por texto

### Fase 3

- Receita por conversa

### Fase 4

- Nota fiscal por imagem

## Melhorias futuras

- Multi-conversas com lista e busca
- Continuacao contextual entre sessoes
- Telemetria de intents e taxa de confirmacao
- Backend seguro para esconder a chave do cliente
