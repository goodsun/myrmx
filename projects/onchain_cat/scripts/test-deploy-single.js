const hre = require("hardhat");

async function testDeployBackBank2() {
  console.log("Testing BackBank2 deployment...");
  
  try {
    // Get signer
    const [deployer] = await hre.ethers.getSigners();
    console.log("Deployer address:", deployer.address);
    
    // Check balance
    const balance = await deployer.getBalance();
    console.log("Deployer balance:", hre.ethers.utils.formatEther(balance), "ETH");
    
    // Get contract factory
    console.log("\nGetting BackBank2 contract factory...");
    const BackBank2 = await hre.ethers.getContractFactory("BackBank2");
    
    // Estimate gas
    console.log("\nEstimating deployment gas...");
    const deployTransaction = BackBank2.getDeployTransaction();
    const estimatedGas = await deployer.estimateGas(deployTransaction);
    console.log("Estimated gas:", estimatedGas.toString());
    
    // Get gas price
    const gasPrice = await deployer.getGasPrice();
    console.log("Gas price:", hre.ethers.utils.formatUnits(gasPrice, "gwei"), "gwei");
    
    // Calculate cost
    const estimatedCost = estimatedGas.mul(gasPrice);
    console.log("Estimated cost:", hre.ethers.utils.formatEther(estimatedCost), "ETH");
    
    // Deploy with explicit gas settings
    console.log("\nDeploying BackBank2...");
    const contract = await BackBank2.deploy({
      gasLimit: 30000000, // 30M gas
      gasPrice: gasPrice.mul(120).div(100) // 20% higher than estimated
    });
    
    console.log("Transaction hash:", contract.deployTransaction.hash);
    console.log("Waiting for deployment...");
    
    await contract.deployed();
    console.log("✅ BackBank2 deployed to:", contract.address);
    
  } catch (error) {
    console.error("\n❌ Deployment failed!");
    console.error("Error type:", error.code);
    console.error("Error message:", error.message);
    
    if (error.error && error.error.message) {
      console.error("Inner error:", error.error.message);
    }
    
    if (error.transaction) {
      console.error("\nTransaction details:");
      console.error("- To:", error.transaction.to);
      console.error("- Data length:", error.transaction.data.length);
      console.error("- Gas limit:", error.transaction.gasLimit?.toString());
    }
  }
}

// Run test
testDeployBackBank2()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });