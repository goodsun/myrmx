#!/usr/bin/env python3
"""
SVG Optimization Script v2 - Enhanced compression for Onchain Cat Material Assets
Optimizes SVG files for minimal size while maintaining structure
"""

import os
import re
from pathlib import Path
from xml.etree import ElementTree as ET

# Define layer IDs for each category
LAYER_IDS = {
    'back': 'bg',  # Shortened for size
    'front': 'fg',
    'item': 'it',
    'main': 'mn'
}

def minify_svg_string(svg_str):
    """Aggressively minify SVG string"""
    # Remove all whitespace between tags
    svg_str = re.sub(r'>\s+<', '><', svg_str)
    # Remove newlines and extra spaces
    svg_str = re.sub(r'\s+', ' ', svg_str)
    # Remove spaces around = in attributes
    svg_str = re.sub(r'\s*=\s*', '=', svg_str)
    # Remove trailing spaces before />
    svg_str = re.sub(r'\s+/>', '/>', svg_str)
    # Remove spaces after >
    svg_str = re.sub(r'>\s+', '>', svg_str)
    # Remove spaces before <
    svg_str = re.sub(r'\s+<', '<', svg_str)
    return svg_str.strip()

def optimize_svg_minimal(file_path, category, add_groups=True):
    """Optimize SVG with minimal size focus"""
    try:
        # Read raw content first
        with open(file_path, 'r') as f:
            content = f.read()
        
        # For very simple patterns, we might not need groups
        rect_count = content.count('<rect')
        
        # Parse the SVG
        tree = ET.parse(file_path)
        root = tree.getroot()
        
        # Clean namespaces
        for elem in root.iter():
            if '}' in elem.tag:
                elem.tag = elem.tag.split('}')[1]
            attribs = list(elem.attrib.items())
            elem.attrib.clear()
            for key, value in attribs:
                if '}' in key:
                    key = key.split('}')[1]
                if not key.startswith('xmlns') or elem == root:
                    elem.attrib[key] = value
        
        # Set minimal attributes on root
        root.attrib = {'viewBox': '0 0 24 24', 'xmlns': 'http://www.w3.org/2000/svg'}
        
        # Keep shape-rendering only if present in original
        if 'shape-rendering' in content:
            root.attrib['shape-rendering'] = 'crispEdges'
        
        # Process elements
        all_elements = []
        for elem in list(root):
            if elem.tag == 'rect':
                # Optimize rect attributes
                for attr in ['x', 'y', 'width', 'height']:
                    if attr in elem.attrib:
                        try:
                            val = float(elem.attrib[attr])
                            if val == 0:
                                elem.attrib.pop(attr)  # Remove 0 values (default)
                            elif val.is_integer():
                                elem.attrib[attr] = str(int(val))
                        except:
                            pass
                
                # Optimize colors
                if 'fill' in elem.attrib:
                    fill = elem.attrib['fill']
                    # Shorten hex colors
                    match = re.match(r'^#([0-9a-fA-F])\1([0-9a-fA-F])\2([0-9a-fA-F])\3$', fill)
                    if match:
                        elem.attrib['fill'] = f'#{fill[1]}{fill[3]}{fill[5]}'
                    # Common color shortcuts
                    color_map = {
                        '#000': '#0',  # Even shorter black
                        '#000000': '#0',
                        '#FFFFFF': '#FFF',
                        '#FF0000': '#F00',
                        '#00FF00': '#0F0',
                        '#0000FF': '#00F',
                    }
                    if fill.upper() in color_map:
                        elem.attrib['fill'] = color_map[fill.upper()]
                
                # Remove default opacity
                if elem.attrib.get('opacity') == '1':
                    elem.attrib.pop('opacity')
                    
            all_elements.append(elem)
            root.remove(elem)
        
        # Add elements back (with or without group)
        if add_groups and rect_count > 5:  # Only add groups for complex SVGs
            group = ET.Element('g', {'id': LAYER_IDS.get(category, 'g')})
            for elem in all_elements:
                group.append(elem)
            root.append(group)
        else:
            # Add elements directly to root for simple SVGs
            for elem in all_elements:
                root.append(elem)
        
        # Convert to string and minify
        svg_str = ET.tostring(root, encoding='unicode')
        svg_str = minify_svg_string(svg_str)
        
        return svg_str
        
    except Exception as e:
        print(f"Error processing {file_path}: {e}")
        return None

def process_category_minimal(category_path, category_name):
    """Process all SVG files with minimal size focus"""
    optimized_count = 0
    
    for svg_file in Path(category_path).glob('*.svg'):
        print(f"Processing: {svg_file.name}")
        
        # Check if it's a simple pattern (backgrounds typically)
        is_simple = category_name == 'back'
        
        optimized_svg = optimize_svg_minimal(svg_file, category_name, add_groups=not is_simple)
        
        if optimized_svg:
            # Save optimized version
            with open(svg_file, 'w', encoding='utf-8') as f:
                f.write(optimized_svg)
            optimized_count += 1
            
    return optimized_count

def main():
    """Main optimization function"""
    base_path = Path(__file__).parent / 'material'
    
    # First restore from backup
    print("Restoring from backup...")
    os.system('cp -r material_backup/* material/')
    
    categories = ['back', 'front', 'item', 'main']
    total_optimized = 0
    
    print("\nStarting minimal SVG optimization...\n")
    
    for category in categories:
        category_path = base_path / category
        if category_path.exists():
            print(f"\n--- Processing {category.upper()} category ---")
            count = process_category_minimal(category_path, category)
            total_optimized += count
            print(f"Optimized {count} files in {category} category")
    
    print(f"\n✅ Total files optimized: {total_optimized}")

if __name__ == '__main__':
    main()