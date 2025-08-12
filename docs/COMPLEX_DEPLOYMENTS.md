# Complex Contract Deployments in siegeNgin

siegeNgin supports complex multi-layer contract deployments through deployment configuration files.

## Overview

Some projects, like the Tragedy NFT project, require deploying multiple contracts in a specific order with dependencies between them. siegeNgin handles this automatically using a `deploy-config.json` file.

## How It Works

### 1. Deployment Configuration File

Create a `deploy-config.json` file in your project root:

```json
{
  "deploymentOrder": [
    {
      "step": 1,
      "contracts": [
        {
          "name": "ContractA",
          "contract": "ContractA",
          "constructorArgs": [],
          "parallel": true
        },
        {
          "name": "ContractB",
          "contract": "ContractB",
          "constructorArgs": [],
          "parallel": true
        }
      ]
    },
    {
      "step": 2,
      "contracts": [
        {
          "name": "ContractC",
          "contract": "ContractC",
          "constructorArgs": [
            {"ref": "ContractA.address"},
            {"ref": "ContractB.address"}
          ]
        }
      ]
    }
  ]
}
```

### 2. Configuration Schema

- **step**: Deployment order (1, 2, 3, etc.)
- **contracts**: Array of contracts to deploy in this step
  - **name**: Display name for the contract instance
  - **contract**: Actual contract name in your Solidity files
  - **constructorArgs**: Arguments for the constructor
    - Use `{"ref": "ContractName.address"}` to reference deployed addresses
  - **parallel**: (optional) Deploy contracts in this step simultaneously
  - **postDeploy**: (optional) Functions to call after deployment

### 3. Using References

Reference previously deployed contracts using the `ref` syntax:

```json
"constructorArgs": [
  {"ref": "TokenBank.address"},
  {"ref": "MetadataBank.address"},
  "0x1234...",  // Regular address
  100          // Regular number
]
```

### 4. Post-Deployment Actions

Execute functions after deployment:

```json
"postDeploy": [
  {
    "method": "setMetadataBank",
    "args": [{"ref": "MetadataBank.address"}]
  }
]
```

## Example: Tragedy Project

The Tragedy project demonstrates a complex 6-layer deployment:

1. **Base Banks** (7 contracts, deployed in parallel)
   - ArweaveMonsterBank1/2
   - ArweaveItemBank1/2
   - ArweaveBackgroundBank
   - ArweaveEffectBank
   - LegendaryBank

2. **Aggregator Banks** (2 contracts)
   - ArweaveMonsterBank (requires MonsterBank1/2)
   - ArweaveItemBank (requires ItemBank1/2)

3. **Composer** (1 contract)
   - ArweaveTragedyComposer (requires all banks)

4. **Metadata Generator** (1 contract)
   - TragedyMetadata (requires Composer and LegendaryBank)

5. **Metadata Proxy** (1 contract)
   - MetadataBank (requires TragedyMetadata)

6. **NFT Contract** (1 contract)
   - BankedNFT (requires post-deployment setup)

## Using the UI

1. Select a project with `deploy-config.json`
2. The UI automatically detects complex deployment configuration
3. Click "Start Deployment Process" to begin
4. Monitor progress as each step completes
5. View deployed addresses in the summary

## Benefits

- **Automated Dependency Management**: Contracts are deployed in the correct order
- **Parallel Deployment**: Save time by deploying independent contracts simultaneously
- **Reference Resolution**: Automatically passes deployed addresses to dependent contracts
- **Post-Deployment Setup**: Execute initialization functions after deployment
- **Visual Progress Tracking**: See deployment status for each step
- **Error Recovery**: Resume from failed steps without redeploying everything

## Best Practices

1. **Test Locally First**: Always test your deployment configuration on a local network
2. **Gas Optimization**: Group contracts that can be deployed in parallel
3. **Clear Naming**: Use descriptive names for contract instances
4. **Documentation**: Comment your configuration file to explain dependencies
5. **Version Control**: Commit your `deploy-config.json` with your project

## Troubleshooting

- **Missing References**: Ensure referenced contracts are deployed in earlier steps
- **Constructor Mismatches**: Verify constructor arguments match your Solidity code
- **Gas Issues**: For complex contracts, ensure sufficient gas limits
- **Compilation Errors**: All contracts must compile successfully before deployment