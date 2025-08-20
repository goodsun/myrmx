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
  
  // 大きなコントラクト用のガス設定
  const gasLimits = {
    "EffectBank3": 50000000,
    "EffectBank2": 60000000,
    "TragedyMetadata": 70000000,
    "BackgroundBank1": 40000000,
    "BackgroundBank2": 40000000,
    "MonsterBank1": 40000000,
    "MonsterBank2": 40000000,
    "ItemBank1": 40000000,
    "ItemBank2": 40000000
  };
  
  const gasLimit = gasLimits[contractName] || 30000000;
  
  const contract = await Contract.deploy({ gasLimit });
  await contract.deployed();
  
  console.log(`${contractName} deployed to:`, contract.address);
  
  // アドレスをファイルに保存
  const fs = require("fs");
  const deployedAddresses = {};
  
  try {
    const existing = fs.readFileSync("deployed-addresses.json", "utf8");
    Object.assign(deployedAddresses, JSON.parse(existing));
  } catch (e) {
    // File doesn't exist yet
  }
  
  deployedAddresses[contractName] = contract.address;
  fs.writeFileSync("deployed-addresses.json", JSON.stringify(deployedAddresses, null, 2));
  
  console.log("Address saved to deployed-addresses.json");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });