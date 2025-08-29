const hre = require("hardhat");
const fs = require("fs");
const path = require("path");

async function testDeployment() {
  console.log("Testing deployment...\n");
  
  // Load addresses
  const addressesPath = path.join(__dirname, "../deployments/addresses.json");
  const addresses = JSON.parse(fs.readFileSync(addressesPath, "utf8"));
  
  // Get contracts
  const catComposer = await hre.ethers.getContractAt("CatComposer", addresses.CatComposer);
  const catMetadata = await hre.ethers.getContractAt("CatMetadata", addresses.CatMetadata);
  
  // Test token IDs
  const testTokenIds = [1, 100, 1000, 5000, 9999, 10000];
  
  console.log("Testing token compositions...\n");
  
  for (const tokenId of testTokenIds) {
    console.log(`=== Token #${tokenId} ===`);
    
    // Get attributes
    const attrs = await catComposer.getCatAttributes(tokenId);
    console.log(`Attributes: Back=${attrs.backId}, Main=${attrs.mainId}, Item=${attrs.itemId}, Front=${attrs.frontId}`);
    
    // Get names
    const [backName, mainName, itemName, frontName] = await catComposer.getAttributeNames(tokenId);
    console.log(`Names: ${backName}, ${mainName}, ${itemName}, ${frontName}`);
    
    // Get SVG (just check it doesn't revert)
    try {
      const svg = await catComposer.composeSVG(tokenId);
      console.log(`SVG length: ${svg.length} characters`);
    } catch (error) {
      console.log(`SVG Error: ${error.message}`);
    }
    
    // Get metadata URI
    try {
      const uri = await catMetadata.tokenURI(tokenId);
      console.log(`Metadata URI length: ${uri.length} characters`);
      
      // Decode and display metadata
      const base64Data = uri.split(',')[1];
      const jsonStr = Buffer.from(base64Data, 'base64').toString();
      const metadata = JSON.parse(jsonStr);
      console.log(`Name: ${metadata.name}`);
      console.log(`Description: ${metadata.description.substring(0, 100)}...`);
    } catch (error) {
      console.log(`Metadata Error: ${error.message}`);
    }
    
    console.log("");
  }
  
  // Test shuffle distribution
  console.log("Testing shuffle distribution...");
  const attributeCounts = {
    back: new Array(10).fill(0),
    main: new Array(10).fill(0),
    item: new Array(10).fill(0),
    front: new Array(10).fill(0)
  };
  
  for (let i = 1; i <= 100; i++) {
    const attrs = await catComposer.getCatAttributes(i);
    attributeCounts.back[attrs.backId]++;
    attributeCounts.main[attrs.mainId]++;
    attributeCounts.item[attrs.itemId]++;
    attributeCounts.front[attrs.frontId]++;
  }
  
  console.log("\nDistribution for first 100 tokens:");
  console.log("Back:", attributeCounts.back.join(", "));
  console.log("Main:", attributeCounts.main.join(", "));
  console.log("Item:", attributeCounts.item.join(", "));
  console.log("Front:", attributeCounts.front.join(", "));
}

async function main() {
  try {
    await testDeployment();
  } catch (error) {
    console.error(error);
    process.exit(1);
  }
}

// Execute if called directly
if (require.main === module) {
  main();
}

module.exports = { testDeployment };