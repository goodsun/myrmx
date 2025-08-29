#!/usr/bin/env python3
"""
Final SVG Optimization Script - Balanced approach for Onchain Cat
Provides optimal balance between structure, semantics, and file size
"""

import os
import re
from pathlib import Path

def optimize_svg_content(content, category, filename):
    """Optimize SVG content with balanced approach"""
    
    # Extract viewBox and shape-rendering
    viewbox_match = re.search(r'viewBox="([^"]+)"', content)
    has_shape_rendering = 'shape-rendering="crispEdges"' in content
    
    # Extract all rect elements
    rects = re.findall(r'<rect[^>]+/>', content)
    
    # Optimize each rect
    optimized_rects = []
    for rect in rects:
        # Optimize coordinates - remove .0 decimals and 0 values
        rect = re.sub(r'="(\d+)\.0+"', r'="\1"', rect)
        rect = re.sub(r'\sx="0"', '', rect)
        rect = re.sub(r'\sy="0"', '', rect)
        
        # Optimize colors
        # Shorten 6-digit hex to 3-digit where possible
        rect = re.sub(r'#([0-9a-fA-F])\1([0-9a-fA-F])\2([0-9a-fA-F])\3', 
                     lambda m: f'#{m.group(1)}{m.group(2)}{m.group(3)}', rect)
        
        # Special shortcuts
        rect = rect.replace('#000000', '#0')
        rect = rect.replace('#000', '#0')
        rect = rect.replace('#FFFFFF', '#FFF')
        rect = rect.replace('#ffffff', '#FFF')
        
        optimized_rects.append(rect)
    
    # Determine if we need groups (for semantic purposes on complex SVGs)
    use_group = len(rects) > 10 or category in ['main', 'item']
    
    # Build optimized SVG
    svg_parts = ['<svg viewBox="0 0 24 24"']
    
    if has_shape_rendering:
        svg_parts.append(' shape-rendering="crispEdges"')
    
    svg_parts.append(' xmlns="http://www.w3.org/2000/svg">')
    
    if use_group:
        # Short but meaningful IDs
        group_ids = {
            'back': 'bg',
            'front': 'fg', 
            'item': 'acc',
            'main': 'cat'
        }
        svg_parts.append(f'<g id="{group_ids.get(category, "g")}">')
    
    # Add all rects
    svg_parts.extend(optimized_rects)
    
    if use_group:
        svg_parts.append('</g>')
    
    svg_parts.append('</svg>')
    
    # Join without any extra whitespace
    return ''.join(svg_parts)

def main():
    """Main optimization function"""
    base_path = Path(__file__).parent / 'material'
    
    print("Starting final SVG optimization...")
    
    # Process categories in order of complexity
    categories = ['back', 'front', 'item', 'main']
    
    total_before = 0
    total_after = 0
    
    for category in categories:
        category_path = base_path / category
        if not category_path.exists():
            continue
        
        print(f"\n--- {category.upper()} ---")
        category_before = 0
        category_after = 0
        
        for svg_file in sorted(category_path.glob('*.svg')):
            # Get original size
            before_size = os.path.getsize(svg_file)
            category_before += before_size
            
            # Read and optimize
            with open(svg_file, 'r') as f:
                content = f.read()
            
            optimized = optimize_svg_content(content, category, svg_file.name)
            
            # Write optimized version
            with open(svg_file, 'w') as f:
                f.write(optimized)
            
            # Get new size
            after_size = os.path.getsize(svg_file)
            category_after += after_size
            
            # Calculate savings
            savings = before_size - after_size
            percent = (savings / before_size) * 100 if before_size > 0 else 0
            
            print(f"  {svg_file.name}: {before_size} → {after_size} bytes (-{savings} bytes, -{percent:.1f}%)")
        
        total_before += category_before
        total_after += category_after
        
        cat_savings = category_before - category_after
        cat_percent = (cat_savings / category_before) * 100 if category_before > 0 else 0
        print(f"  Category total: {category_before} → {category_after} bytes (-{cat_savings} bytes, -{cat_percent:.1f}%)")
    
    # Total summary
    total_savings = total_before - total_after
    total_percent = (total_savings / total_before) * 100 if total_before > 0 else 0
    
    print(f"\n✅ TOTAL OPTIMIZATION:")
    print(f"   Before: {total_before:,} bytes")
    print(f"   After:  {total_after:,} bytes")
    print(f"   Saved:  {total_savings:,} bytes ({total_percent:.1f}% reduction)")

if __name__ == '__main__':
    main()