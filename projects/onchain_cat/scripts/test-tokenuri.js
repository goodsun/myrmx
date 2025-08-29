const hre = require("hardhat");
const fs = require("fs");
const path = require("path");

async function main() {
    // Get network ID
    const network = await hre.ethers.provider.getNetwork();
    const networkId = network.chainId;
    
    const addressPath = path.join(__dirname, `../deployed-addresses-${networkId}.json`);
    const addresses = JSON.parse(fs.readFileSync(addressPath, "utf8"));
    
    const catMetadata = await hre.ethers.getContractAt("CatMetadata", addresses.CatMetadata);
    
    // Test token ID 1
    console.log("Testing token ID 1...");
    const uri = await catMetadata.tokenURI(1);
    console.log("Full URI:", uri);
    
    // Extract Base64 JSON
    const base64Json = uri.replace("data:application/json;base64,", "");
    const jsonString = Buffer.from(base64Json, "base64").toString();
    const metadata = JSON.parse(jsonString);
    
    console.log("\nMetadata:");
    console.log("Name:", metadata.name);
    console.log("Description:", metadata.description);
    console.log("Attributes:", metadata.attributes);
    
    // Extract and decode SVG
    const svgBase64 = metadata.image.replace("data:image/svg+xml;base64,", "");
    const svg = Buffer.from(svgBase64, "base64").toString();
    
    console.log("\nSVG (first 200 chars):");
    console.log(svg.substring(0, 200));
    
    // Save full SVG for inspection
    fs.writeFileSync(path.join(__dirname, "../test-output.svg"), svg);
    console.log("\nFull SVG saved to test-output.svg");
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });