const Client = artifacts.require("ChainScoreClient");
const Token = artifacts.require("TestToken");

require("dotenv").config({path: "../.env"});

module.exports = async function (deployer, network, accounts) {
  let token, oracle;
  let jobSpec = process.env.JOB_SPEC;

  switch(network){
    case "hm": {
      token = await Token.at(process.env.SCORE_TOKEN_HM);
      oracle = process.env.OPERATOR_HM;
      break;
    }
    case "ht": {
      token = await Token.at(process.env.SCORE_TOKEN_HT);
      oracle = process.env.OPERATOR_HT;
      break;
    }
    case "rinkeby": {
      token = await Token.at(process.env.SCORE_TOKEN_RINKEBY);
      oracle = process.env.OPERATOR_RINKEBY;
      break;
    }
    case "am": {
      token = await Token.at(process.env.SCORE_TOKEN_AM);
      oracle = process.env.OPERATOR_AM;
      break;
    }
    case "at": {
      token = await Token.at(process.env.SCORE_TOKEN_AT);
      oracle = process.env.OPERATOR_AT;
      break;
    }
    default: {
      await deployer.deploy(Token);
      token = await Token.deployed();
      oracle = web3.utils.randomHex(20);
      break
    }
  }

  await deployer.deploy(Client, token.address, oracle, jobSpec);
  let client = await Client.deployed();

  await token.transfer(client.address, web3.utils.toWei("5"));
};