# Contract Verification Data

This directory contains all the necessary data for verifying contracts on Etherscan or similar block explorers.

## Directory Structure

- `compiler-settings.json` - Compiler configuration for verification
- Each contract has its own directory containing:
  - `abi.json` - The contract's ABI
  - `bytecode.json` - The contract's bytecode and deployed bytecode
  - `metadata.json` - The contract's metadata (if available)
  - `verification.json` - Combined data for verification
  - `constructor-args-template.json` - Template for constructor arguments (if applicable)

## Verification Settings

Check `compiler-settings.json` for:
- Compiler Type: "Solidity (Standard-Json-Input)"
- Compiler Version: See compiler-settings.json
- Optimization: Enabled (200 runs)
- License: MIT

## How to Use

1. Deploy your contracts and save the deployment addresses
2. For each contract you want to verify:
   - Use the settings from `compiler-settings.json`
   - Use the ABI and bytecode from the contract's directory
   - Fill in the constructor arguments if needed
   - Submit to Etherscan's verification page

## Polygon Verification

When deploying to Polygon, you'll need:
1. The deployed contract address
2. The compiler settings from `compiler-settings.json`
3. The contract source code
4. Constructor arguments (if any)

## Manual Verification Steps

1. Go to Polygonscan.com (or testnet version)
2. Navigate to your contract address
3. Click "Verify and Publish"
4. Select:
   - Compiler Type: "Solidity (Standard-Json-Input)"
   - Compiler Version: As specified in `compiler-settings.json`
   - Open Source License Type: MIT
5. Upload the Standard JSON Input (from metadata)
6. Enter constructor arguments if needed

## Automated Verification

To automate verification after deployment, you can use the hardhat-etherscan plugin:
```bash
npx hardhat verify --network polygon <CONTRACT_ADDRESS> <CONSTRUCTOR_ARGS>
```
