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

## Vídeo de Pitch

> 🎥 *(link a ser adicionado antes da culminância — 26/06/2026)*

O vídeo apresenta: o problema real, a solução desenvolvida, demonstração do MVP, ferramentas utilizadas, uso de IA, o que funciona e o que está em desenvolvimento.

---

## Pitch / Slides

> 📊 *(link a ser adicionado antes da culminância — 26/06/2026)*

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

## Rodando Localmente

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
