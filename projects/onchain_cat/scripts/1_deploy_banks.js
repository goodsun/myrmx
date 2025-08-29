const hre = require("hardhat");
const fs = require("fs");
const path = require("path");

async function deployBankContracts() {
  console.log("Starting bank contracts deployment...");
  
  // Deploy all bank contracts in parallel
  const deployments = await Promise.all([
    // Back banks
    deployContract("BackBank1"),
    deployContract("BackBank2"),
    deployContract("BackBank3"),
    // Main banks
    deployContract("MainBank1"),
    deployContract("MainBank2"),
    // Item banks
    deployContract("ItemBank1"),
    deployContract("ItemBank2"),
    // Front banks
    deployContract("FrontBank1"),
    deployContract("FrontBank2"),
  ]);

  // Create addresses object
  const addresses = {};
  deployments.forEach(({ name, address }) => {
    addresses[name] = address;
  });

  // Save addresses to file
  const addressesPath = path.join(__dirname, "../deployments/addresses.json");
  fs.mkdirSync(path.dirname(addressesPath), { recursive: true });
  fs.writeFileSync(addressesPath, JSON.stringify(addresses, null, 2));

  console.log("Bank contracts deployed successfully!");
  console.log("Addresses saved to:", addressesPath);
  
  return addresses;
}

async function deployContract(contractName) {
  const Contract = await hre.ethers.getContractFactory(contractName);
  const contract = await Contract.deploy();
  await contract.waitForDeployment();
  const address = await contract.getAddress();
  
  console.log(`${contractName} deployed to:`, address);
  return { name: contractName, address };
}

async function main() {
  try {
    await deployBankContracts();
  } catch (error) {
    console.error(error);
    process.exit(1);
  }
}

// Execute if called directly
if (require.main === module) {
  main();
}

module.exports = { deployBankContracts };