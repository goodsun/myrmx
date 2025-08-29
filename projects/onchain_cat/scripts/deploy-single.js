const hre = require("hardhat");
const fs = require("fs");
const path = require("path");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);

  // Get contract name from command line arguments
  const contractName = process.argv[2];
  
  if (!contractName) {
    console.error("Please specify a contract name to deploy");
    process.exit(1);
  }

  console.log(`Deploying ${contractName}...`);

  try {
    // Load existing addresses if available
    const addressesPath = path.join(__dirname, "../deployments/addresses.json");
    let addresses = {};
    if (fs.existsSync(addressesPath)) {
      addresses = JSON.parse(fs.readFileSync(addressesPath, "utf8"));
    } else {
      fs.mkdirSync(path.dirname(addressesPath), { recursive: true });
    }

    // Get constructor arguments based on contract type
    let constructorArgs = [];
    
    // Aggregator contracts need bank addresses
    if (contractName === "BackBank") {
      constructorArgs = [addresses.BackBank1, addresses.BackBank2, addresses.BackBank3];
    } else if (contractName === "MainBank") {
      constructorArgs = [addresses.MainBank1, addresses.MainBank2];
    } else if (contractName === "ItemBank") {
      constructorArgs = [addresses.ItemBank1, addresses.ItemBank2];
    } else if (contractName === "FrontBank") {
      constructorArgs = [addresses.FrontBank1, addresses.FrontBank2];
    } else if (contractName === "CatComposer") {
      constructorArgs = [addresses.BackBank, addresses.MainBank, addresses.ItemBank, addresses.FrontBank];
    } else if (contractName === "CatMetadata") {
      constructorArgs = [addresses.CatComposer];
    }

    // Deploy the contract
    const Contract = await hre.ethers.getContractFactory(contractName);
    const contract = await Contract.deploy(...constructorArgs);
    await contract.waitForDeployment();
    const address = await contract.getAddress();

    console.log(`${contractName} deployed to:`, address);

    // Save address
    addresses[contractName] = address;
    fs.writeFileSync(addressesPath, JSON.stringify(addresses, null, 2));
    console.log("Address saved to:", addressesPath);

    return address;
  } catch (error) {
    console.error(`Failed to deploy ${contractName}:`, error);
    process.exit(1);
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });