require('dotenv').config();

const contract_0 = artifacts.require(process.env.CONTRACT_0_NAME);

module.exports = function (deployer) {
  deployer.deploy(contract_0);
};
