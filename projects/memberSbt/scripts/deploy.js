// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // Get the contract factories
  const MemberCardRenderer = await hre.ethers.getContractFactory("MemberCardRenderer");
  const MembersSBT = await hre.ethers.getContractFactory("MembersSBT");

  // Deploy MemberCardRenderer first
  console.log("Deploying MemberCardRenderer...");
  const renderer = await MemberCardRenderer.deploy();
  await renderer.deployed();
  console.log("MemberCardRenderer deployed to:", renderer.address);

  // Deploy MembersSBT with the renderer address
  console.log("Deploying MembersSBT...");
  const membersSBT = await MembersSBT.deploy(
    "Members Card",  // name
    "MEMBER",        // symbol
    renderer.address // renderer contract address
  );
  await membersSBT.deployed();
  console.log("MembersSBT deployed to:", membersSBT.address);

  // Log deployment info
  console.log("\n=== Deployment Complete ===");
  console.log("MemberCardRenderer:", renderer.address);
  console.log("MembersSBT:", membersSBT.address);
  console.log("\nTo verify contracts on Etherscan:");
  console.log(`npx hardhat verify --network [network] ${renderer.address}`);
  console.log(`npx hardhat verify --network [network] ${membersSBT.address} "Members Card" "MEMBER" "${renderer.address}"`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });