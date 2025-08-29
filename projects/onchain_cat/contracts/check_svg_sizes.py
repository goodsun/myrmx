#!/usr/bin/env python3
"""
Check SVG file sizes before and after optimization
"""

import os
from pathlib import Path

def get_directory_size(path):
    """Calculate total size of SVG files in directory"""
    total_size = 0
    file_count = 0
    
    for svg_file in Path(path).glob('*.svg'):
        size = os.path.getsize(svg_file)
        total_size += size
        file_count += 1
        
    return total_size, file_count

def format_size(bytes):
    """Format bytes to human readable"""
    for unit in ['B', 'KB', 'MB']:
        if bytes < 1024.0:
            return f"{bytes:.2f} {unit}"
        bytes /= 1024.0
    return f"{bytes:.2f} GB"

def main():
    base_path = Path(__file__).parent / 'material'
    categories = ['back', 'front', 'item', 'main']
    
    print("SVG File Size Report")
    print("=" * 50)
    
    total_size = 0
    total_files = 0
    
    for category in categories:
        category_path = base_path / category
        if category_path.exists():
            size, count = get_directory_size(category_path)
            total_size += size
            total_files += count
            
            print(f"\n{category.upper()}:")
            print(f"  Files: {count}")
            print(f"  Total size: {format_size(size)}")
            print(f"  Average size: {format_size(size/count if count > 0 else 0)}")
    
    print(f"\nTOTAL:")
    print(f"  Files: {total_files}")
    print(f"  Total size: {format_size(total_size)}")
    print(f"  Average size: {format_size(total_size/total_files if total_files > 0 else 0)}")

if __name__ == '__main__':
    main()