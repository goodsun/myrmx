const hre = require("hardhat");
const fs = require("fs");
const path = require("path");

async function deployComposer() {
  console.log("Starting composer contracts deployment...");
  
  // Load addresses
  const addressesPath = path.join(__dirname, "../deployments/addresses.json");
  const addresses = JSON.parse(fs.readFileSync(addressesPath, "utf8"));
  
  // Deploy CatComposer
  const CatComposer = await hre.ethers.getContractFactory("CatComposer");
  const catComposer = await CatComposer.deploy(
    addresses.BackBank,
    addresses.MainBank,
    addresses.ItemBank,
    addresses.FrontBank
  );
  await catComposer.waitForDeployment();
  const catComposerAddress = await catComposer.getAddress();
  
  console.log("CatComposer deployed to:", catComposerAddress);
  
  // Deploy CatMetadata
  const CatMetadata = await hre.ethers.getContractFactory("CatMetadata");
  const catMetadata = await CatMetadata.deploy(catComposerAddress);
  await catMetadata.waitForDeployment();
  const catMetadataAddress = await catMetadata.getAddress();
  
  console.log("CatMetadata deployed to:", catMetadataAddress);
  
  // Update addresses
  addresses.CatComposer = catComposerAddress;
  addresses.CatMetadata = catMetadataAddress;
  
  // Save updated addresses
  fs.writeFileSync(addressesPath, JSON.stringify(addresses, null, 2));
  
  console.log("Composer contracts deployed successfully!");
  
  return addresses;
}

async function main() {
  try {
    await deployComposer();
  } catch (error) {
    console.error(error);
    process.exit(1);
  }
}

// Execute if called directly
if (require.main === module) {
  main();
}

module.exports = { deployComposer };