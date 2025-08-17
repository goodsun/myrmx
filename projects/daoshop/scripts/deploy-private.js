const hre = require("hardhat");

async function main() {
  console.log("Deploying DAOShop to private network...");

  // プライベートキーから直接signerを作成
  const provider = new hre.ethers.providers.JsonRpcProvider("YOUR_RPC_URL");
  const signer = new hre.ethers.Wallet("YOUR_PRIVATE_KEY", provider);

  const DAOShop = await hre.ethers.getContractFactory("DAOShop", signer);
  
  // 明示的にガスリミットを設定
  const daoShop = await DAOShop.deploy({
    gasLimit: 3000000,
    gasPrice: hre.ethers.utils.parseUnits("20", "gwei")
  });

  await daoShop.deployed();

  console.log("DAOShop deployed to:", daoShop.address);
  console.log("Transaction hash:", daoShop.deployTransaction.hash);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });