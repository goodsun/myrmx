#!/usr/bin/env python3
"""
Analyze SVG structures and optimization opportunities
"""

import os
from pathlib import Path
from xml.etree import ElementTree as ET
import re

def analyze_svg(file_path):
    """Analyze a single SVG file"""
    with open(file_path, 'r') as f:
        content = f.read()
    
    # Basic stats
    file_size = os.path.getsize(file_path)
    rect_count = content.count('<rect')
    
    # Check for optimization opportunities
    issues = []
    
    # Check for width/height on root
    if 'width="384"' in content or 'height="384"' in content:
        issues.append("Has explicit width/height (can use viewBox only)")
    
    # Check for long color codes
    long_colors = re.findall(r'#([0-9a-fA-F])\1([0-9a-fA-F])\2([0-9a-fA-F])\3', content)
    if long_colors:
        issues.append(f"Has {len(long_colors)} colors that can be shortened")
    
    # Check for xmlns on non-root
    xmlns_count = content.count('xmlns=') - 1  # -1 for root
    if xmlns_count > 0:
        issues.append(f"Has {xmlns_count} extra xmlns attributes")
    
    # Check for unnecessary decimals
    decimal_coords = re.findall(r'[xy]="(\d+\.0+)"', content)
    if decimal_coords:
        issues.append(f"Has {len(decimal_coords)} decimal coordinates")
    
    # Check whitespace
    extra_whitespace = len(re.findall(r'>\s+<', content))
    if extra_whitespace > rect_count:
        issues.append("Has excessive whitespace")
    
    return {
        'size': file_size,
        'rects': rect_count,
        'issues': issues
    }

def main():
    base_path = Path(__file__).parent / 'material'
    categories = ['back', 'front', 'item', 'main']
    
    print("SVG Analysis Report")
    print("=" * 60)
    
    for category in categories:
        category_path = base_path / category
        if not category_path.exists():
            continue
            
        print(f"\n{category.upper()} CATEGORY:")
        print("-" * 40)
        
        total_issues = 0
        files_with_issues = []
        
        for svg_file in sorted(category_path.glob('*.svg')):
            analysis = analyze_svg(svg_file)
            
            if analysis['issues']:
                total_issues += len(analysis['issues'])
                files_with_issues.append(svg_file.name)
                print(f"\n  {svg_file.name} ({analysis['size']} bytes, {analysis['rects']} rects)")
                for issue in analysis['issues']:
                    print(f"    - {issue}")
        
        if not files_with_issues:
            print("  ✅ All files are well optimized!")
        else:
            print(f"\n  Total: {len(files_with_issues)} files with {total_issues} optimization opportunities")
    
    # Show sample optimized structures
    print("\n\nSAMPLE OPTIMIZED STRUCTURES:")
    print("=" * 60)
    
    print("\n1. Simple Background Pattern (no group needed):")
    print("""<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><rect width="24" height="24" fill="#87CEEB"/><rect y="2" width="24" height="2" fill="#FFF"/></svg>""")
    
    print("\n2. Character with Group:")
    print("""<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><g id="mn"><rect x="6" y="3" width="3" height="3" fill="#778"/><rect x="8" y="8" width="2" height="2" fill="#0"/></g></svg>""")
    
    print("\n3. Item with shape-rendering:")
    print("""<svg viewBox="0 0 24 24" shape-rendering="crispEdges" xmlns="http://www.w3.org/2000/svg"><g id="it"><rect x="9" y="14" width="6" height="1" fill="#F00"/></g></svg>""")

if __name__ == '__main__':
    main()