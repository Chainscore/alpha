const Client = artifacts.require("ChainScoreClient");
const Token = artifacts.require("TestToken");

require("dotenv").config({path: "../.env"});

module.exports = async function (deployer, network, accounts) {
  // let token, oracle;
  // let jobSpec = process.env.JOB_SPEC;

  // switch(network){
  //   case "development": {
  //     await deployer.deploy(Token);
  //     token = await Token.deployed();
  //     oracle = web3.utils.randomHex(20);
  //     break;
  //   }
  //   default: {
  //     token = await Token.at(process.env["SCORE_TOKEN_"+network.toUpperCase()]);
  //     oracle = process.env["OPERATOR_"+network.toUpperCase()];
  //     break;
  //   }
  // }

  // await deployer.deploy(Client, token.address, oracle, jobSpec);
  // let client = await Client.deployed();

  // await token.transfer(client.address, web3.utils.toWei("5"));
};