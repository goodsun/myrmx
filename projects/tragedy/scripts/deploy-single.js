const hre = require("hardhat");

async function main() {
  const contractName = process.argv[2];
  if (!contractName) {
    console.error("Please provide contract name as argument");
    console.error("Usage: npx hardhat run scripts/deploy-single.js <ContractName>");
    process.exit(1);
  }

  console.log(`Deploying ${contractName}...`);
  
  const Contract = await hre.ethers.getContractFactory(contractName);
  
  // 大きなコントラクト用のガス設定（完全オンチェーン化対応）
  const gasLimits = {
    "EffectBank3": 80000000,
    "EffectBank2": 90000000,
    "EffectBank1": 80000000,
    "TragedyMetadata": 100000000,
    "BackgroundBank1": 70000000,
    "BackgroundBank2": 70000000,
    "MonsterBank1": 60000000,
    "MonsterBank2": 60000000,
    "ItemBank1": 60000000,
    "ItemBank2": 60000000,
    "EffectBank": 50000000,
    "BackgroundBank": 50000000
  };
  
  const gasLimit = gasLimits[contractName] || 30000000;
  
  const contract = await Contract.deploy({ gasLimit });
  await contract.deployed();
  
  console.log(`${contractName} deployed to:`, contract.address);
  
  // Get network ID
  const network = await hre.ethers.provider.getNetwork();
  const networkId = network.chainId;
  
  // アドレスをファイルに保存
  const fs = require("fs");
  const deployedAddresses = {};
  
  const filename = `deployed-addresses-${networkId}.json`;
  
  try {
    const existing = fs.readFileSync(filename, "utf8");
    Object.assign(deployedAddresses, JSON.parse(existing));
  } catch (e) {
    // File doesn't exist yet
  }
  
  deployedAddresses[contractName] = contract.address;
  fs.writeFileSync(filename, JSON.stringify(deployedAddresses, null, 2));
  
  console.log(`Address saved to ${filename}`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });