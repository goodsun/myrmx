# Cross-Project Import Strategies for siegeNgin

## Problem
When you have contracts in one project (e.g., `twin-contracts/SVGGenerator.sol`) that need to be imported by another project (e.g., `campaign`), Hardhat's isolated project structure makes this challenging.

## Solutions

### 1. NPM Package Approach (Recommended)

Create a shared contracts package:

```bash
# Create a new package for shared contracts
mkdir projects/shared-contracts
cd projects/shared-contracts

# Initialize as npm package
npm init -y

# Update package.json
{
  "name": "@yourorg/shared-contracts",
  "version": "1.0.0",
  "main": "index.js",
  "files": ["contracts/"]
}
```

Then in your project:
```bash
cd projects/campaign
npm install ../shared-contracts
```

Import in Solidity:
```solidity
import "@yourorg/shared-contracts/contracts/SVGGenerator.sol";
```

### 2. Hardhat Path Remapping

Add to `hardhat.config.js`:

```javascript
module.exports = {
  solidity: "0.8.19",
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  },
  // Add path remapping
  networks: {
    // ... your networks
  }
};
```

### 3. Symlink Approach

Create symbolic links to shared contracts:

```bash
cd projects/campaign/contracts
ln -s ../../twin-contracts/contracts/SVGGenerator.sol SVGGenerator.sol
```

### 4. Copy During Build

Add a pre-compile script to `package.json`:

```json
{
  "scripts": {
    "precompile": "cp ../twin-contracts/contracts/SVGGenerator.sol contracts/",
    "compile": "hardhat compile"
  }
}
```

### 5. Monorepo with Workspaces

Convert to a monorepo structure using npm workspaces:

```json
// Root package.json
{
  "name": "siegengin-monorepo",
  "workspaces": [
    "projects/*"
  ]
}
```

## Recommended Approach for siegeNgin

Given the browser-based deployment nature of siegeNgin, the **copy during build** approach is most practical:

1. It maintains project independence
2. No complex dependency management
3. Works with the existing compilation flow
4. Clear and explicit dependencies

## Implementation Example

For the `SVGGenerator.sol` case:

1. **Option A**: Pre-compile both projects
   - First compile `twin-contracts` 
   - Then compile `campaign` which imports the artifacts

2. **Option B**: Copy shared contracts
   ```javascript
   // In campaign's hardhat.config.js
   task("compile", "Compiles with shared contracts")
     .setAction(async (args, hre, runSuper) => {
       // Copy shared contracts
       const fs = require('fs');
       const path = require('path');
       
       const sharedContracts = [
         '../twin-contracts/contracts/SVGGenerator.sol'
       ];
       
       for (const contract of sharedContracts) {
         const src = path.join(__dirname, contract);
         const dest = path.join(__dirname, 'contracts', path.basename(contract));
         fs.copyFileSync(src, dest);
       }
       
       // Run normal compile
       await runSuper(args);
     });
   ```

3. **Option C**: Interface-only approach
   - Define interfaces in the importing project
   - Deploy shared contracts separately
   - Pass addresses to dependent contracts

## Best Practices

1. **Avoid circular dependencies**: Project A should not import from B while B imports from A
2. **Version control**: Track which version of shared contracts each project uses
3. **Documentation**: Clearly document cross-project dependencies
4. **Testing**: Test shared contracts independently and with dependents