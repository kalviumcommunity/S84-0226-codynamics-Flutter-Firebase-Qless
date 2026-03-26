import os
import glob
import re

directory = "lib/"

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    original_content = content
    
    # We mainly target Center(child: CircularProgressIndicator())
    # and const Center(child: CircularProgressIndicator())
    # Replace With Center(child: FoodLoadingIndicator(size: 40))
    
    content = re.sub(r'const\s+Center\(\s*child:\s*CircularProgressIndicator\(\)\s*\)', 
                     r'const Center(child: FoodLoadingIndicator(size: 40))', content)
    
    content = re.sub(r'Center\(\s*child:\s*CircularProgressIndicator\(\)\s*\)', 
                     r'const Center(child: FoodLoadingIndicator(size: 40))', content)
                     
    content = re.sub(r'const\s+CircularProgressIndicator\(\)', 
                     r'const FoodLoadingIndicator(size: 30)', content)
                     
    content = re.sub(r'CircularProgressIndicator\(\)', 
                     r'const FoodLoadingIndicator(size: 30)', content)

    # Some customized ones
    content = re.sub(r'CircularProgressIndicator\(.*?\)', 
                     r'FoodLoadingIndicator(size: 30)', content)

    if content != original_content:
        # Need to add import if it doesn't have it
        if "import" in content and "FoodLoadingIndicator" in content:
            # check if import exists
            if 'food_loading_indicator.dart' not in content:
                # count depth
                path_parts = filepath.replace("\\", "/").split('/')
                depth = len(path_parts) - 2 # 2 because 'lib' and 'filename'
                if depth == 0:
                    import_str = "import 'widgets/food_loading_indicator.dart';\n"
                else:
                    import_str = f"import '{"../" * depth}widgets/food_loading_indicator.dart';\n"
                
                # inject import after the first import
                content = content.replace("import 'package:flutter/material.dart';", f"import 'package:flutter/material.dart';\n{import_str}", 1)

        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Updated {filepath}")

for root, dirs, files in os.walk(directory):
    for file in files:
        if file.endswith(".dart"):
            process_file(os.path.join(root, file))
