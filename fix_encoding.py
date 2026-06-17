import os
import glob

replacements = {
    'Ã£': 'ã',
    'Ã§': 'ç',
    'Ã¡': 'á',
    'Ã©': 'é',
    'Ã­': 'í',
    'Ã³': 'ó',
    'Ãª': 'ê',
    'Ãº': 'ú',
    'Ã¢': 'â',
    'Ãµ': 'õ',
    'Ã€': 'À',
    'Ã': 'Á',
    'Ã‰': 'É',
    'Ã': 'Í',
    'Ã“': 'Ó',
    'Ãš': 'Ú',
    'Ã‡': 'Ç',
    'Ã•': 'Õ',
    'Ã‚': 'Â',
    'ÃŠ': 'Ê'
}

def fix_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    new_content = content
    for bad, good in replacements.items():
        new_content = new_content.replace(bad, good)
        
    if new_content != content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Fixed {filepath}")

for root, _, files in os.walk('lib'):
    for file in files:
        if file.endswith('.dart'):
            fix_file(os.path.join(root, file))
