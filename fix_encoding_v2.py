import os

def fix_file(filepath):
    with open(filepath, 'rb') as f:
        content = f.read()
    
    try:
        text = content.decode('utf-8')
    except:
        return
        
    fixed_lines = []
    changed = False
    
    # We will do a regex or direct replace based on the actual bytes found if decoding latin1 works.
    # Alternatively, we can just replace the specific sequences that are known to be double-encoded utf-8.
    
    replacements = {
        'Ã£': 'ã',
        'Ã§': 'ç',
        'Ã¡': 'á',
        'Ã©': 'é',
        'Ã\xad': 'í', # \xad is soft hyphen
        'Ã³': 'ó',
        'Ãª': 'ê',
        'Ãº': 'ú',
        'Ã¢': 'â',
        'Ãµ': 'õ',
        'Ã€': 'À',
        'Ã ': 'Á',
        'Ã‰': 'É',
        'Ã ': 'Í',
        'Ã“': 'Ó',
        'Ãš': 'Ú',
        'Ã‡': 'Ç',
        'Ã•': 'Õ',
        'Ã‚': 'Â',
        'ÃŠ': 'Ê',
        # Fallbacks for other weird latin1 decoded characters
        'Ã§Ã£': 'çã',
        'Ãµes': 'ões',
        'Ã§Ãµes': 'ções',
    }

    new_text = text
    for bad, good in replacements.items():
        if bad in new_text:
            new_text = new_text.replace(bad, good)
            changed = True
            
    # some characters like Ã followed by non-breaking space etc.
    # Let's also do a generic pass: find words containing Ã and try to fix them.
    # Actually, a simpler way is:
    
    try:
        # If the entire file is double-encoded
        double_decoded = text.encode('latin1').decode('utf-8')
        # If it succeeds without error, and it's different
        if double_decoded != text:
            new_text = double_decoded
            changed = True
    except:
        pass

    if changed and new_text != text:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_text)
        print(f"Fixed {filepath}")

for root, _, files in os.walk('lib'):
    for file in files:
        if file.endswith('.dart'):
            fix_file(os.path.join(root, file))
