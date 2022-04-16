const main = async () => {

  
  const nftContractFactory = await hre.ethers.getContractFactory('PublicMinter');
  

  
  //let setmintsize = await nftContract.setMintSize(2)
  //await setmintsize.wait()
  //console.log("set mint size")


  let mint1 = await nftContract.publicMint("hi",10)
  await mint1.wait()
  console.log("Minted NFT1")
  


  //let claim = await nftContract.claim()
  //await claim.wait()
  //console.log("claim")


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