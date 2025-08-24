// Script to update the renderer contract address in MembersSBT
const hre = require("hardhat");

async function main() {
  // Configuration
  const MEMBERS_SBT_ADDRESS = process.env.MEMBERS_SBT_ADDRESS || "";
  const NEW_RENDERER_ADDRESS = process.env.NEW_RENDERER_ADDRESS || "";

  if (!MEMBERS_SBT_ADDRESS || !NEW_RENDERER_ADDRESS) {
    console.error("Please set MEMBERS_SBT_ADDRESS and NEW_RENDERER_ADDRESS environment variables");
    process.exit(1);
  }

  // Get the contract instance
  const membersSBT = await hre.ethers.getContractAt("MembersSBT", MEMBERS_SBT_ADDRESS);

  // Get current renderer
  const currentRenderer = await membersSBT.renderer();
  console.log("Current renderer:", currentRenderer);

  // Update renderer
  console.log("Updating renderer to:", NEW_RENDERER_ADDRESS);
  const tx = await membersSBT.setRenderer(NEW_RENDERER_ADDRESS);
  await tx.wait();

  // Verify update
  const newRenderer = await membersSBT.renderer();
  console.log("New renderer:", newRenderer);
  console.log("Renderer updated successfully!");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });