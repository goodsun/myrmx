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
    
    # Generate the main getter function
    getter_conditions = []
    for i, (idx, name) in enumerate(zip(range(start_idx, end_idx + 1), svg_names)):
        escaped_content = escape_solidity_string(svg_contents[i])
        getter_conditions.append(f'        if ({category}Id == {idx}) return "{escaped_content}";')
    
    getter_function = f'''
    function get{category.capitalize()}SVG(uint8 {category}Id) public pure returns (string memory) {{
{chr(10).join(getter_conditions)}
        revert("{category.capitalize()} ID not in this bank");
    }}'''
    
    # Generate the name getter function
    name_conditions = []
    for i, (idx, name) in enumerate(zip(range(start_idx, end_idx + 1), svg_names)):
        display_name = ' '.join(word.capitalize() for word in name.split('_'))
        name_conditions.append(f'        if ({category}Id == {idx}) return "{display_name}";')
    
    name_function = f'''
    function get{category.capitalize()}Name(uint8 {category}Id) public pure returns (string memory) {{
{chr(10).join(name_conditions)}
        revert("{category.capitalize()} ID not in this bank");
    }}'''
    
    # Combine everything
    contract_content = f'''// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract {contract_name} {{
    constructor() {{}}

{chr(10).join(function_bodies)}
{getter_function}
{name_function}
}}
'''
    
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
        
        # Read all SVG files and get their sizes
        svg_data = []
        for i, name in enumerate(names):
            svg_file = material_path / category / f"{name}.svg"
            if svg_file.exists():
                with open(svg_file, 'r') as f:
                    content = f.read()
                    svg_data.append({
                        'index': i,
                        'name': name,
                        'content': content,
                        'size': len(content)
                    })
            else:
                print(f"Warning: {svg_file} not found")
        
        # Special handling for 'back' category - split into 3 banks due to large files
        if category == 'back':
            # Sort by size to find the large files
            svg_data_sorted = sorted(svg_data, key=lambda x: x['size'], reverse=True)
            
            # Print sizes for debugging
            print("  Back SVG sizes:")
            for item in svg_data_sorted:
                print(f"    {item['name']}: {item['size']} bytes")
            
            # Distribute evenly by size
            # Bank1: indices 0-3 (4 items)
            # Bank2: indices 4-6 (3 items)  
            # Bank3: indices 7-9 (3 items)
            
            # Keep original order for each bank
            bank1_data = [item for item in svg_data if item['index'] >= 0 and item['index'] <= 3]
            bank2_data = [item for item in svg_data if item['index'] >= 4 and item['index'] <= 6]
            bank3_data = [item for item in svg_data if item['index'] >= 7 and item['index'] <= 9]
            
            # Generate Bank 1 contract (0-3)
            bank1_contract = generate_bank_contract(
                category, 1, 0, 3, 
                [item['name'] for item in bank1_data],
                [item['content'] for item in bank1_data]
            )
            
            # Generate Bank 2 contract (4-6)
            bank2_contract = generate_bank_contract(
                category, 2, 4, 6,
                [item['name'] for item in bank2_data],
                [item['content'] for item in bank2_data]
            )
            
            # Generate Bank 3 contract (7-9)
            bank3_contract = generate_bank_contract(
                category, 3, 7, 9,
                [item['name'] for item in bank3_data],
                [item['content'] for item in bank3_data]
            )
            
            # Write contracts
            for i, contract in enumerate([bank1_contract, bank2_contract, bank3_contract], 1):
                bank_file = output_path / f"{category.capitalize()}Bank{i}.sol"
                with open(bank_file, 'w') as f:
                    f.write(contract)
                print(f"  Created {bank_file}")
        
        else:
            # Other categories remain split into 2 banks (5 each)
            bank1_data = svg_data[0:5]
            bank2_data = svg_data[5:10]
            
            # Generate Bank 1 contract
            bank1_contract = generate_bank_contract(
                category, 1, 0, 4, 
                [item['name'] for item in bank1_data],
                [item['content'] for item in bank1_data]
            )
            
            bank1_file = output_path / f"{category.capitalize()}Bank1.sol"
            with open(bank1_file, 'w') as f:
                f.write(bank1_contract)
            print(f"  Created {bank1_file}")
            
            # Generate Bank 2 contract
            bank2_contract = generate_bank_contract(
                category, 2, 5, 9,
                [item['name'] for item in bank2_data],
                [item['content'] for item in bank2_data]
            )
            
            bank2_file = output_path / f"{category.capitalize()}Bank2.sol"
            with open(bank2_file, 'w') as f:
                f.write(bank2_contract)
            print(f"  Created {bank2_file}")
    
    print("\nAll bank contracts generated successfully!")
    print(f"Output directory: {output_path}")

if __name__ == "__main__":
    main()