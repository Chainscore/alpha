const Client = artifacts.require("ChainScoreClient");

module.exports = function (deployer) {
  deployer.deploy(Client);
};