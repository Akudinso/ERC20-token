const hre = require("hardhat");

async function main() {
    const [deployer] = await hre.ethers.getSigners();
    console.log("Deploying ClustToken with address:", deployer.address);

    const treasuryWallet = deployer.address; // Change to a multisig wallet if needed
    const ClustToken = await hre.ethers.getContractFactory("ClustToken");
    const token = await ClustToken.deploy(treasuryWallet);
    await token.waitForDeployment();

    console.log("ClustToken deployed to:", await token.getAddress());
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
