import { ethers, network } from "hardhat";
const hre = require("hardhat");
const fs = require('fs');
const path = require('path');

async function main() {

  fs.rmdir("./cache", (err:any) => {

    if (err) {
    return console.log("error occurred in deleting directory", err);
    }

    console.log("Directory deleted successfully");
  });

  fs.rmdir("./artifacts", (err:any) => {

    if (err) {
    return console.log("error occurred in deleting directory", err);
    }

    console.log("Directory deleted successfully");
  });

  fs.rmdir("./typechain-types", (err:any) => {

    if (err) {
    return console.log("error occurred in deleting directory", err);
    }

    console.log("Directory deleted successfully");
  });

  console.log("\nPrivate Doc deployment in progress...") 

  const medusaOracleContractAddress = "0xf1d5A4481F44fe0818b6E7Ef4A60c0c9b29E3118"
  const nftContractAdddress = "0x5d47d641026d4585b40573410cb5d93e839ca96e"
  
  const PrivateDoc = await ethers.getContractFactory("PrivateDoc")
  const privateDoc = await PrivateDoc.deploy(
    medusaOracleContractAddress,
    nftContractAdddress
  )
  await privateDoc.deployed();
  console.log("\nPrivateDoc deployed at", privateDoc.address, "✅")  

  try {
    console.log("\nEtherscan verification in progress...")
    await privateDoc.deployTransaction.wait(6)
    await hre.run("verify:verify", { network: network.name, address: privateDoc.address, constructorArguments: 
      [
        medusaOracleContractAddress, 
        nftContractAdddress, 
      ], 
    });
    console.log("Etherscan verification done. ✅")
  } catch (error) {
    console.error(error);
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
