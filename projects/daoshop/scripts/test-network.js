const hre = require("hardhat");

async function main() {
  try {
    // プロバイダーから直接接続テスト
    const provider = new hre.ethers.providers.JsonRpcProvider("YOUR_RPC_URL");
    
    // ネットワーク情報取得
    const network = await provider.getNetwork();
    console.log("Network:", network);
    
    // ブロック番号取得
    const blockNumber = await provider.getBlockNumber();
    console.log("Current block:", blockNumber);
    
    // ガス価格取得
    const gasPrice = await provider.getGasPrice();
    console.log("Gas price:", hre.ethers.utils.formatUnits(gasPrice, "gwei"), "gwei");
    
    // アカウント残高確認（アドレスを設定）
    const address = "YOUR_ADDRESS";
    const balance = await provider.getBalance(address);
    console.log("Balance:", hre.ethers.utils.formatEther(balance), "ETH");
    
  } catch (error) {
    console.error("Error:", error.message);
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });