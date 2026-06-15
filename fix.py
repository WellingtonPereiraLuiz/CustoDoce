import re

with open('lib/presentation/screens/digital_menu/digital_menu_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Fix string interpolation syntax errors
content = content.replace("pw.Text('R$ `", "pw.Text('R$ ${")
content = content.replace(")}',", ")}',")
content = content.replace("Text('Erro: `$e'))),", "Text('Erro: ${e}'))),")

# Also fix the incorrect PDF text string if it was corrupted
content = re.sub(r"pw\.Text\('R\$ \\',", r"pw.Text('R$ ${price.toStringAsFixed(2)}',", content)
content = re.sub(r"Text\('Erro: \\'\)\)\),", r"Text('Erro: ${e}'))),", content)

# Remove unused imports
content = content.replace("import 'package:custo_doce/core/enums/recipe_category.dart';\n", "")
content = content.replace("import 'package:custo_doce/core/providers/auth_provider.dart';\n", "")

with open('lib/presentation/screens/digital_menu/digital_menu_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
