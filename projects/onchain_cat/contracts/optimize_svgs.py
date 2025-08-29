#!/usr/bin/env python3
"""
SVG Optimization Script for Onchain Cat Material Assets
Optimizes SVG files by:
- Removing unnecessary attributes
- Ensuring consistent viewBox
- Adding semantic group tags with layer IDs
- Minimizing file size
- Standardizing structure across categories
"""

import os
import re
from pathlib import Path
from xml.etree import ElementTree as ET

# Define layer IDs for each category
LAYER_IDS = {
    'back': 'background-pattern',
    'front': 'front-item',
    'item': 'accessory-item',
    'main': 'main-character'
}

def optimize_svg(file_path, category):
    """Optimize a single SVG file"""
    try:
        # Parse the SVG
        tree = ET.parse(file_path)
        root = tree.getroot()
        
        # Clean namespaces
        for elem in root.iter():
            # Remove namespace prefixes
            if '}' in elem.tag:
                elem.tag = elem.tag.split('}')[1]
            # Remove namespace attributes
            attribs = list(elem.attrib.items())
            elem.attrib.clear()
            for key, value in attribs:
                if '}' in key:
                    key = key.split('}')[1]
                if not key.startswith('xmlns'):
                    elem.attrib[key] = value
        
        # Ensure consistent viewBox (24x24 for all)
        root.attrib['viewBox'] = '0 0 24 24'
        
        # Remove width/height attributes from root if they exist
        root.attrib.pop('width', None)
        root.attrib.pop('height', None)
        
        # Only keep xmlns for root element
        root.attrib['xmlns'] = 'http://www.w3.org/2000/svg'
        
        # Remove shape-rendering if not needed (keep for pixel art style)
        # Keep shape-rendering="crispEdges" for pixel-perfect rendering
        
        # Collect all rect elements
        rects = list(root.findall('.//rect'))
        
        # Create a group with semantic ID
        layer_id = LAYER_IDS.get(category, 'layer')
        group = ET.Element('g', {'id': layer_id})
        
        # Move all rects to the group
        for rect in rects:
            root.remove(rect)
            group.append(rect)
        
        # Add the group to root
        root.append(group)
        
        # Optimize attributes
        for elem in root.iter():
            # Convert numeric attributes to integers where possible
            for attr in ['x', 'y', 'width', 'height']:
                if attr in elem.attrib:
                    try:
                        val = float(elem.attrib[attr])
                        if val.is_integer():
                            elem.attrib[attr] = str(int(val))
                    except:
                        pass
            
            # Remove default opacity="1"
            if elem.attrib.get('opacity') == '1':
                elem.attrib.pop('opacity')
            
            # Shorten color codes where possible
            if 'fill' in elem.attrib:
                fill = elem.attrib['fill']
                # Convert 6-digit hex to 3-digit where possible
                if re.match(r'^#([0-9a-fA-F])\1([0-9a-fA-F])\2([0-9a-fA-F])\3$', fill):
                    elem.attrib['fill'] = f'#{fill[1]}{fill[3]}{fill[5]}'
        
        # Convert to string and minimize
        svg_str = ET.tostring(root, encoding='unicode')
        
        # Remove unnecessary whitespace between tags
        svg_str = re.sub(r'>\s+<', '><', svg_str)
        
        # Remove trailing spaces
        svg_str = re.sub(r'\s+/>', '/>', svg_str)
        
        # Ensure proper formatting
        svg_str = svg_str.replace('><', '>\n<')
        
        return svg_str
        
    except Exception as e:
        print(f"Error processing {file_path}: {e}")
        return None

def process_category(category_path, category_name):
    """Process all SVG files in a category"""
    optimized_count = 0
    
    for svg_file in Path(category_path).glob('*.svg'):
        print(f"Processing: {svg_file.name}")
        
        optimized_svg = optimize_svg(svg_file, category_name)
        
        if optimized_svg:
            # Save optimized version
            with open(svg_file, 'w', encoding='utf-8') as f:
                f.write(optimized_svg)
            optimized_count += 1
            
    return optimized_count

def main():
    """Main optimization function"""
    base_path = Path(__file__).parent / 'material'
    
    categories = ['back', 'front', 'item', 'main']
    total_optimized = 0
    
    print("Starting SVG optimization...\n")
    
    for category in categories:
        category_path = base_path / category
        if category_path.exists():
            print(f"\n--- Processing {category.upper()} category ---")
            count = process_category(category_path, category)
            total_optimized += count
            print(f"Optimized {count} files in {category} category")
    
    print(f"\n✅ Total files optimized: {total_optimized}")
    
    # Show sample structures
    print("\n--- Sample Optimized Structures ---")
    samples = {
        'back': base_path / 'back' / 'stripes.svg',
        'front': base_path / 'front' / 'apple.svg', 
        'item': base_path / 'item' / 'bell.svg',
        'main': base_path / 'main' / 'blue.svg'
    }
    
    for category, sample_path in samples.items():
        if sample_path.exists():
            print(f"\n{category.upper()} sample ({sample_path.name}):")
            with open(sample_path, 'r') as f:
                content = f.read()
                # Show first few lines
                lines = content.split('\n')
                for line in lines[:5]:
                    print(f"  {line}")
                if len(lines) > 5:
                    print("  ...")

if __name__ == '__main__':
    main()