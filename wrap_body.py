import os
import glob

def find_matching_bracket(text, start_index):
    stack = []
    brackets = {'(': ')', '{': '}', '[': ']'}
    
    in_string = False
    string_char = ''
    
    for i in range(start_index, len(text)):
        char = text[i]
        
        if char in ['"', "'"] and (i == 0 or text[i-1] != '\\'):
            if not in_string:
                in_string = True
                string_char = char
            elif string_char == char:
                in_string = False
        
        if not in_string:
            if char in brackets.keys():
                stack.append(char)
            elif char in brackets.values():
                if not stack:
                    return i
                last = stack.pop()
                if brackets[last] != char:
                    # Mismatched bracket
                    return -1
                if not stack:
                    return i
                    
    return -1

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # We need to find 'body:'
    # However, some files might already have the constraint or be ai_chat_screen (which we will replace anyway)
    if 'ConstrainedBox(constraints: const BoxConstraints(maxWidth: 600)' in content or 'maxWidth: 400' in content:
        return
        
    idx = content.find('body:')
    if idx == -1:
        return
        
    # Find the start of the expression after 'body:'
    expr_start = idx + 5
    while expr_start < len(content) and content[expr_start].isspace():
        expr_start += 1
        
    # We find the matching bracket or the end of the statement
    # The statement might end with a comma (',') if it's an argument to a constructor like Scaffold(body: ..., )
    end_idx = -1
    stack = []
    brackets = {'(': ')', '{': '}', '[': ']'}
    in_string = False
    string_char = ''
    
    for i in range(expr_start, len(content)):
        char = content[i]
        if char in ['"', "'"] and (i == 0 or content[i-1] != '\\'):
            if not in_string:
                in_string = True
                string_char = char
            elif string_char == char:
                in_string = False
        
        if not in_string:
            if char in brackets.keys():
                stack.append(char)
            elif char in brackets.values():
                if not stack:
                    # We reached a closing bracket that doesn't belong to the body expression
                    end_idx = i - 1
                    break
                stack.pop()
            elif char == ',' and not stack:
                end_idx = i - 1
                break
                
    if end_idx != -1:
        while content[end_idx].isspace():
            end_idx -= 1
        end_idx += 1
        
        body_expr = content[expr_start:end_idx]
        new_body_expr = f'Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 600), child: {body_expr}))'
        
        new_content = content[:expr_start] + new_body_expr + content[end_idx:]
        
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Wrapped body in {filepath}")

if __name__ == '__main__':
    for root, dirs, files in os.walk('lib/presentation/screens'):
        for file in files:
            if file.endswith('_screen.dart') and file != 'ai_chat_screen.dart':
                process_file(os.path.join(root, file))
