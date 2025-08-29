const fs = require('fs');
const path = require('path');

const CONTRACTS_TO_VERIFY = [
    'OnchainCats',
    'CatMetadata',
    'CatComposer',
    'BackBank',
    'MainBank',
    'ItemBank',
    'FrontBank',
    'BackBank1',
    'BackBank2',
    'BackBank3',
    'MainBank1',
    'MainBank2',
    'ItemBank1',
    'ItemBank2',
    'FrontBank1',
    'FrontBank2'
];

function extractVerificationData() {
    const outputDir = path.join(__dirname, '..', 'verification');
    
    // Create verification directory if it doesn't exist
    if (!fs.existsSync(outputDir)) {
        fs.mkdirSync(outputDir);
    }

    // Process each contract
    CONTRACTS_TO_VERIFY.forEach(contractName => {
        console.log(`Processing ${contractName}...`);
        
        // Find the artifact file
        const artifactsDir = path.join(__dirname, '..', 'artifacts', 'contracts');
        let artifactPath = null;
        
        // Search for the contract in different possible locations
        const possiblePaths = [
            path.join(artifactsDir, `${contractName}.sol`, `${contractName}.json`),
            path.join(artifactsDir, 'banks', `${contractName}.sol`, `${contractName}.json`),
            // Search recursively if needed
        ];
        
        for (const possiblePath of possiblePaths) {
            if (fs.existsSync(possiblePath)) {
                artifactPath = possiblePath;
                break;
            }
        }
        
        if (!artifactPath) {
            // Try to find it recursively
            artifactPath = findArtifactRecursively(artifactsDir, `${contractName}.json`);
        }
        
        if (!artifactPath) {
            console.log(`  Warning: Could not find artifact for ${contractName}`);
            return;
        }
        
        // Read the artifact
        const artifact = JSON.parse(fs.readFileSync(artifactPath, 'utf8'));
        
        // Create contract-specific directory
        const contractDir = path.join(outputDir, contractName);
        if (!fs.existsSync(contractDir)) {
            fs.mkdirSync(contractDir);
        }
        
        // Extract and save ABI
        const abiPath = path.join(contractDir, 'abi.json');
        fs.writeFileSync(abiPath, JSON.stringify(artifact.abi, null, 2));
        console.log(`  ✓ ABI saved to ${abiPath}`);
        
        // Extract and save bytecode
        const bytecodePath = path.join(contractDir, 'bytecode.json');
        fs.writeFileSync(bytecodePath, JSON.stringify({
            bytecode: artifact.bytecode,
            deployedBytecode: artifact.deployedBytecode
        }, null, 2));
        console.log(`  ✓ Bytecode saved to ${bytecodePath}`);
        
        // Extract metadata if available
        if (artifact.metadata) {
            const metadataPath = path.join(contractDir, 'metadata.json');
            
            // Parse the metadata string
            let metadata;
            try {
                metadata = JSON.parse(artifact.metadata);
            } catch (e) {
                // If it's not valid JSON, save as is
                metadata = artifact.metadata;
            }
            
            fs.writeFileSync(metadataPath, JSON.stringify(metadata, null, 2));
            console.log(`  ✓ Metadata saved to ${metadataPath}`);
        }
        
        // Create a combined verification file
        const verificationData = {
            contractName: artifact.contractName,
            sourceName: artifact.sourceName,
            abi: artifact.abi,
            bytecode: artifact.bytecode,
            deployedBytecode: artifact.deployedBytecode,
            linkReferences: artifact.linkReferences,
            deployedLinkReferences: artifact.deployedLinkReferences,
        };
        
        const verificationPath = path.join(contractDir, 'verification.json');
        fs.writeFileSync(verificationPath, JSON.stringify(verificationData, null, 2));
        console.log(`  ✓ Verification data saved to ${verificationPath}`);
        
        // Extract constructor arguments template (if constructor exists)
        const constructor = artifact.abi.find(item => item.type === 'constructor');
        if (constructor && constructor.inputs.length > 0) {
            const constructorArgsTemplate = {
                description: "Constructor arguments for contract deployment",
                arguments: constructor.inputs.map(input => ({
                    name: input.name,
                    type: input.type,
                    value: `<${input.type} value>`
                }))
            };
            
            const constructorArgsPath = path.join(contractDir, 'constructor-args-template.json');
            fs.writeFileSync(constructorArgsPath, JSON.stringify(constructorArgsTemplate, null, 2));
            console.log(`  ✓ Constructor args template saved to ${constructorArgsPath}`);
        }
    });
    
    // Extract compiler version from artifacts
    let compilerVersion = null;
    try {
        // Find any artifact to get compiler version
        const sampleArtifactPath = path.join(__dirname, '..', 'artifacts', 'contracts', 'OnchainCats.sol', 'OnchainCats.json');
        if (fs.existsSync(sampleArtifactPath)) {
            const sampleArtifact = JSON.parse(fs.readFileSync(sampleArtifactPath, 'utf8'));
            if (sampleArtifact.metadata) {
                const metadata = JSON.parse(sampleArtifact.metadata);
                if (metadata.compiler && metadata.compiler.version) {
                    compilerVersion = metadata.compiler.version;
                }
            }
        }
    } catch (e) {
        console.log('Could not extract compiler version from artifacts');
    }

    // Update compiler settings with actual version
    const compilerSettingsPath = path.join(outputDir, 'compiler-settings.json');
    if (compilerVersion && fs.existsSync(compilerSettingsPath)) {
        const compilerSettings = JSON.parse(fs.readFileSync(compilerSettingsPath, 'utf8'));
        compilerSettings.compilerVersion = `v${compilerVersion}`;
        compilerSettings.actualCompilerVersion = compilerVersion;
        fs.writeFileSync(compilerSettingsPath, JSON.stringify(compilerSettings, null, 2));
        console.log(`\n📝 Updated compiler version: v${compilerVersion}`);
    }

    // Create a README for the verification directory
    const readmePath = path.join(outputDir, 'README.md');
    const readmeContent = `# Contract Verification Data

This directory contains all the necessary data for verifying contracts on Etherscan or similar block explorers.

## Directory Structure

- \`compiler-settings.json\` - Compiler configuration for verification
- Each contract has its own directory containing:
  - \`abi.json\` - The contract's ABI
  - \`bytecode.json\` - The contract's bytecode and deployed bytecode
  - \`metadata.json\` - The contract's metadata (if available)
  - \`verification.json\` - Combined data for verification
  - \`constructor-args-template.json\` - Template for constructor arguments (if applicable)

## Verification Settings

Check \`compiler-settings.json\` for:
- Compiler Type: "Solidity (Standard-Json-Input)"
- Compiler Version: ${compilerVersion ? `v${compilerVersion}` : 'See compiler-settings.json'}
- Optimization: Enabled (200 runs)
- License: MIT

## How to Use

1. Deploy your contracts and save the deployment addresses
2. For each contract you want to verify:
   - Use the settings from \`compiler-settings.json\`
   - Use the ABI and bytecode from the contract's directory
   - Fill in the constructor arguments if needed
   - Submit to Etherscan's verification page

## Polygon Verification

When deploying to Polygon, you'll need:
1. The deployed contract address
2. The compiler settings from \`compiler-settings.json\`
3. The contract source code
4. Constructor arguments (if any)

## Manual Verification Steps

1. Go to Polygonscan.com (or testnet version)
2. Navigate to your contract address
3. Click "Verify and Publish"
4. Select:
   - Compiler Type: "Solidity (Standard-Json-Input)"
   - Compiler Version: As specified in \`compiler-settings.json\`
   - Open Source License Type: MIT
5. Upload the Standard JSON Input (from metadata)
6. Enter constructor arguments if needed

## Automated Verification

To automate verification after deployment, you can use the hardhat-etherscan plugin:
\`\`\`bash
npx hardhat verify --network polygon <CONTRACT_ADDRESS> <CONSTRUCTOR_ARGS>
\`\`\`
`;
    
    fs.writeFileSync(readmePath, readmeContent);
    console.log(`\n✅ Verification data extraction complete!`);
    console.log(`📁 Output directory: ${outputDir}`);
}

function findArtifactRecursively(dir, filename) {
    const files = fs.readdirSync(dir);
    
    for (const file of files) {
        const filePath = path.join(dir, file);
        const stat = fs.statSync(filePath);
        
        if (stat.isDirectory()) {
            const found = findArtifactRecursively(filePath, filename);
            if (found) return found;
        } else if (file === filename) {
            return filePath;
        }
    }
    
    return null;
}

// Run the extraction
extractVerificationData();