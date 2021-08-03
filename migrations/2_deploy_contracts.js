const EquityContract = artifacts.require("EquityContract");


module.exports = async (deployer, network, accounts) => {
  
  try {
      await deployer.deploy(EquityContract);
      await EquityContract.deployed();
  } catch (err) {
    console.log('err', err);
  }
  
};
