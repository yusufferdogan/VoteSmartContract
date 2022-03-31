require('dotenv').config();

const contract_1 = artifacts.require(process.env.CONTRACT_1_NAME);

module.exports = function (deployer) {
  deployer.deploy(contract_1, process.env.CONTRACT_1_TOKEN_SUPPLY);
};
