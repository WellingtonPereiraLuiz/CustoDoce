# Deploy Firebase Hosting

## Pré-requisitos
- Flutter 3+ instalado
- Firebase CLI instalado (
pm install -g firebase-tools)
- Arquivo .env preenchido (ver .env.example)

## Passos

1. Instalar dependências:
   `
   flutter pub get
   `

2. Build web:
   `
   flutter build web --dart-define-from-file=.env
   `
   Se não tiver .env, usar:
   `
   flutter build web
   `

3. Deploy:
   `
   firebase deploy --only hosting
   `

4. Copiar a URL gerada e atualizar o link no README.md.

## Link MVP
[a preencher após deploy]
