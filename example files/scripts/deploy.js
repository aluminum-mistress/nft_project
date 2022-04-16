const main = async () => {

  
  const nftContractFactory = await hre.ethers.getContractFactory('PublicMinter');
  const nftContract = await nftContractFactory.deploy();
  await nftContract.deployed();
  console.log("Contract deployed to:", nftContract.address);



  

  let addpayee = await nftContract.addPayee("0x85bec784ff48f4361f506E06d2e3aEaD6369631E",50)
  await addpayee.wait()
  console.log("add payee")

  let setmintfees = await nftContract.enableMinting()
  await setmintfees.wait()
  console.log("enable mint")
  
  let setmintsize = await nftContract.setMintFees(200)
  await setmintsize.wait()
  console.log("set mint size")


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