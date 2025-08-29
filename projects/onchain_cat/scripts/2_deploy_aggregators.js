const hre = require("hardhat");
const fs = require("fs");
const path = require("path");

async function deployAggregators() {
  console.log("Starting aggregator contracts deployment...");
  
  // Load bank addresses
  const addressesPath = path.join(__dirname, "../deployments/addresses.json");
  const addresses = JSON.parse(fs.readFileSync(addressesPath, "utf8"));
  
  // Deploy aggregator contracts
  const [BackBank, MainBank, ItemBank, FrontBank] = await Promise.all([
    deployAggregator("BackBank", [addresses.BackBank1, addresses.BackBank2, addresses.BackBank3]),
    deployAggregator("MainBank", [addresses.MainBank1, addresses.MainBank2]),
    deployAggregator("ItemBank", [addresses.ItemBank1, addresses.ItemBank2]),
    deployAggregator("FrontBank", [addresses.FrontBank1, addresses.FrontBank2]),
  ]);

  // Update addresses
  addresses.BackBank = BackBank;
  addresses.MainBank = MainBank;
  addresses.ItemBank = ItemBank;
  addresses.FrontBank = FrontBank;

  // Save updated addresses
  fs.writeFileSync(addressesPath, JSON.stringify(addresses, null, 2));

  console.log("Aggregator contracts deployed successfully!");
  
  return addresses;
}

async function deployAggregator(contractName, constructorArgs) {
  const Contract = await hre.ethers.getContractFactory(contractName);
  const contract = await Contract.deploy(...constructorArgs);
  await contract.waitForDeployment();
  const address = await contract.getAddress();
  
  console.log(`${contractName} deployed to:`, address);
  return address;
}

async function main() {
  try {
    await deployAggregators();
  } catch (error) {
    console.error(error);
    process.exit(1);
  }
}

// Execute if called directly
if (require.main === module) {
  main();
}

module.exports = { deployAggregators };