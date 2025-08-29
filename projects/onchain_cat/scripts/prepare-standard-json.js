const fs = require('fs');
const path = require('path');

/**
 * Generate Standard JSON Input for Etherscan verification
 * Usage: node scripts/prepare-standard-json.js <contractName>
 */

const contractName = process.argv[2];

if (!contractName) {
    console.log('Usage: node scripts/prepare-standard-json.js <contractName>');
    console.log('Example: node scripts/prepare-standard-json.js OnchainCats');
    process.exit(1);
}

function generateStandardJson(contractName) {
    const contractsDir = path.join(__dirname, '..', 'contracts');
    const verificationDir = path.join(__dirname, '..', 'verification', contractName);
    
    if (!fs.existsSync(verificationDir)) {
        console.error(`Verification directory not found for ${contractName}`);
        console.error(`Please run 'node scripts/extract-verification-data.js' first`);
        process.exit(1);
    }
    
    // Read the source files
    const sources = {};
    
    // Function to add source file
    function addSource(filePath, contractPath) {
        if (!fs.existsSync(filePath)) return;
        
        const content = fs.readFileSync(filePath, 'utf8');
        sources[contractPath] = { content };
        
        // Extract imports and add them recursively
        const importRegex = /import\s+.*?\s+from\s+["'](.+?)["'];/g;
        const imports = content.matchAll(importRegex);
        
        for (const match of imports) {
            const importPath = match[1];
            if (importPath.startsWith('.')) {
                // Relative import
                const absolutePath = path.resolve(path.dirname(filePath), importPath);
                const relativePath = path.relative(contractsDir, absolutePath).replace(/\\/g, '/');
                
                if (!sources[`contracts/${relativePath}`]) {
                    addSource(absolutePath, `contracts/${relativePath}`);
                }
            }
        }
    }
    
    // Find the contract file
    const possiblePaths = [
        path.join(contractsDir, `${contractName}.sol`),
        path.join(contractsDir, 'banks', `${contractName}.sol`),
    ];
    
    let contractFile = null;
    for (const possiblePath of possiblePaths) {
        if (fs.existsSync(possiblePath)) {
            contractFile = possiblePath;
            break;
        }
    }
    
    if (!contractFile) {
        console.error(`Contract file not found for ${contractName}`);
        process.exit(1);
    }
    
    // Add the main contract and its dependencies
    const mainContractPath = `contracts/${path.relative(contractsDir, contractFile).replace(/\\/g, '/')}`;
    addSource(contractFile, mainContractPath);
    
    // Read compiler settings
    const compilerSettingsPath = path.join(__dirname, '..', 'verification', 'compiler-settings.json');
    const compilerSettings = JSON.parse(fs.readFileSync(compilerSettingsPath, 'utf8'));
    
    // Create Standard JSON Input
    const standardJson = {
        language: "Solidity",
        sources: sources,
        settings: {
            optimizer: {
                enabled: compilerSettings.optimization.enabled,
                runs: compilerSettings.optimization.runs
            },
            evmVersion: compilerSettings.evmVersion,
            outputSelection: {
                "*": {
                    "*": [
                        "abi",
                        "evm.bytecode",
                        "evm.deployedBytecode",
                        "evm.methodIdentifiers",
                        "metadata"
                    ],
                    "": [
                        "ast"
                    ]
                }
            }
        }
    };
    
    // Save the Standard JSON Input
    const outputPath = path.join(verificationDir, 'standard-input.json');
    fs.writeFileSync(outputPath, JSON.stringify(standardJson, null, 2));
    
    console.log(`✅ Standard JSON Input generated for ${contractName}`);
    console.log(`📄 Saved to: ${outputPath}`);
    console.log(`\nTo verify on Etherscan/Polygonscan:`);
    console.log(`1. Select "Solidity (Standard-Json-Input)" as Compiler Type`);
    console.log(`2. Use compiler version: ${compilerSettings.compilerVersion || 'v0.8.20+commit.a1b79de6'}`);
    console.log(`3. Upload the generated standard-input.json file`);
    console.log(`4. Select "MIT" as the open source license`);
}

generateStandardJson(contractName);