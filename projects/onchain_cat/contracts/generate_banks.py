#!/usr/bin/env python3

import os
from pathlib import Path

# Define the categories and their corresponding SVG files
CATEGORIES = {
    'back': [
        'baby_blue_gingham', 'checkerboard', 'checkered', 'cloud_pattern', 'gingham',
        'houndstooth', 'polka_dots', 'stars', 'stripes', 'tartan'
    ],
    'front': [
        'apple', 'mouse', 'dry_food', 'fish', 'flower',
        'herb', 'liquor', 'meat', 'onigiri', 'rice'
    ],
    'item': [
        'bell', 'box', 'cap', 'flower', 'gasmask',
        'hat', 'ribbon', 'stoll', 'suit', 'sunglass'
    ],
    'main': [
        'blue', 'buchi', 'hachiware', 'kuro', 'mike',
        'robo', 'scottish_fold', 'siamese', 'sphinx', 'tabby'
    ]
}

def camel_case(name):
    """Convert snake_case to CamelCase."""
    return ''.join(word.capitalize() for word in name.split('_'))

def escape_solidity_string(svg_content):
    """Escape SVG content for Solidity string literal."""
    # Remove newlines and extra spaces
    svg_content = svg_content.strip()
    # Escape quotes
    svg_content = svg_content.replace('"', '\\"')
    return svg_content

def generate_bank_contract(category, bank_number, start_idx, end_idx, svg_names, svg_contents):
    """Generate a Solidity contract for a bank."""
    contract_name = f"{category.capitalize()}Bank{bank_number}"
    
    # Build the function body with if statements
    function_bodies = []
    
    # Generate individual getter functions for each SVG
    for i, (name, content) in enumerate(zip(svg_names, svg_contents)):
        function_name = f"get{camel_case(name)}"
        escaped_content = escape_solidity_string(content)
        function_bodies.append(
            f'    function {function_name}() external pure returns (string memory) {{\n'
            f'        return "{escaped_content}";\n'
            f'    }}'
        )
    
    # Generate the main getter function with ID parameter
    id_function_lines = [
        f'    function get{category.capitalize()}SVG(uint8 {category}Id) public pure returns (string memory) {{'
    ]
    
    for i, (name, content) in enumerate(zip(svg_names, svg_contents)):
        actual_id = start_idx + i
        escaped_content = escape_solidity_string(content)
        id_function_lines.append(
            f'        if ({category}Id == {actual_id}) return "{escaped_content}";'
        )
    
    id_function_lines.append(f'        revert("{category.capitalize()} ID not in this bank");')
    id_function_lines.append('    }')
    
    # Generate the getName function
    name_function_lines = [
        f'    function get{category.capitalize()}Name(uint8 {category}Id) public pure returns (string memory) {{'
    ]
    
    for i, name in enumerate(svg_names):
        actual_id = start_idx + i
        display_name = ' '.join(word.capitalize() for word in name.split('_'))
        name_function_lines.append(
            f'        if ({category}Id == {actual_id}) return "{display_name}";'
        )
    
    name_function_lines.append(f'        revert("{category.capitalize()} ID not in this bank");')
    name_function_lines.append('    }')
    
    # Combine all parts
    contract_content = f"""// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract {contract_name} {{
    constructor() {{}}

{chr(10).join(function_bodies)}

{chr(10).join(id_function_lines)}

{chr(10).join(name_function_lines)}
}}
"""
    
    return contract_content

def main():
    # Base paths
    material_path = Path("/Users/goodsun/develop/goodsun/siegeNgin/projects/onchain_cat/contracts/material")
    output_path = Path("/Users/goodsun/develop/goodsun/siegeNgin/projects/onchain_cat/contracts/banks")
    
    # Create output directory if it doesn't exist
    output_path.mkdir(exist_ok=True)
    
    # Process each category
    for category, names in CATEGORIES.items():
        print(f"Processing {category} category...")
        
        # Read all SVG files for this category
        svg_contents = []
        for name in names:
            svg_file = material_path / category / f"{name}.svg"
            if svg_file.exists():
                with open(svg_file, 'r') as f:
                    svg_contents.append(f.read())
            else:
                print(f"Warning: {svg_file} not found")
                svg_contents.append("")  # Add empty string to maintain indexing
        
        # Split into two banks (5 SVGs each)
        bank1_names = names[0:5]
        bank1_contents = svg_contents[0:5]
        
        bank2_names = names[5:10]
        bank2_contents = svg_contents[5:10]
        
        # Generate Bank 1 contract
        bank1_contract = generate_bank_contract(
            category, 1, 0, 4, bank1_names, bank1_contents
        )
        
        bank1_file = output_path / f"{category.capitalize()}Bank1.sol"
        with open(bank1_file, 'w') as f:
            f.write(bank1_contract)
        print(f"  Created {bank1_file}")
        
        # Generate Bank 2 contract
        bank2_contract = generate_bank_contract(
            category, 2, 5, 9, bank2_names, bank2_contents
        )
        
        bank2_file = output_path / f"{category.capitalize()}Bank2.sol"
        with open(bank2_file, 'w') as f:
            f.write(bank2_contract)
        print(f"  Created {bank2_file}")
    
    print("\nAll bank contracts generated successfully!")
    print(f"Output directory: {output_path}")

if __name__ == "__main__":
    main()