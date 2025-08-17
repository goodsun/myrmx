const hre = require("hardhat");

async function main() {
  console.log("Deploying DAOShop contract...");

  const DAOShop = await hre.ethers.getContractFactory("DAOShop");
  const daoShop = await DAOShop.deploy();

  await daoShop.deployed();

  console.log("DAOShop deployed to:", daoShop.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });