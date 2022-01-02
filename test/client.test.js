const Client = artifacts.require("ChainScoreClient");
require("dotenv").config();

contract("ChainScore Alpha", async (accounts) => {
    let client;
    let owner = accounts[0];
    let user1 = accounts[1];

    let address = "0xcc9a0b7c43dc2a5f023bb9b738e45b0ef6b06e04"

    before(async () => {
        client = await Client.deployed();
    })

    it("should request for score", async () => {
        await client.requestScore(address);
    })

    it("should receieve score < 1min", async () => {
        await new Promise(r => setTimeout(r, 60*1000));
        let score = await client.scores(address);
        expect(parseInt(score.score)).to.not.equal(0);
    })
})