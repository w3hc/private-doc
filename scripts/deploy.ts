import { ethers } from "hardhat";
// const hre = require("hardhat");

async function main() {

  console.log("\nPrivate Doc deployment in progress...") 
  
  const PrivateDoc = await ethers.getContractFactory("PrivateDoc")
  const privateDoc = await PrivateDoc.deploy("0xf1d5A4481F44fe0818b6E7Ef4A60c0c9b29E3118")
  await privateDoc.deployed();
  console.log("\nPrivateDoc deployed at", privateDoc.address, "✅")  

  // try {
  //   console.log("\nEtherscan verification in progress...")
  //   await gov.deployTransaction.wait(6)
  //   await hre.run("verify:verify", { network: "goerli", address: gov.address, constructorArguments: [store.nft], });
  //   console.log("Etherscan verification done. ✅")
  // } catch (error) {
  //   console.error(error);
  // }

}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
