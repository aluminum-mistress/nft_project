const main = async () => {
  const nftContractFactory = await hre.ethers.getContractFactory('polarbear');

  let mint = await nftContract.mint(2)
  await mint.wait()
  console.log("Minted 2 NFTs")



};
  
const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.log(error);
    process.exit(1);
  }
};
  
runMain();

//npx hardhat run scripts/deploy.js --network rinkeby