const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Greeter", function () {
  it("Should return the new greeting once it's changed", async function () {
    const Greeter = await ethers.getContractFactory("MeloScoutNFT");
    const greeter = await Greeter.deploy("123","1","2","3","4");
    await greeter.deployed();

    expect(await greeter.baseTokenURI()).to.equal("123");

    const setGreetingTx = await greeter.setGreeting("Hola, mundo!");

    // // wait until the transaction is mined
    // await setGreetingTx.wait();

    // expect(await greeter.greet()).to.equal("Hola, mundo!");
  });
});
