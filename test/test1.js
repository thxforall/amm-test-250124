const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Test1CPMM", function () {
  let test1, tokenA, tokenB;
  let owner, user1, user2, user3, user4;

  beforeEach(async function () {
    [owner, user1, user2, user3, user4] = await ethers.getSigners();

    const Token = await ethers.getContractFactory("ERC20Mock");
    tokenA = await Token.deploy("Token A", "A");
    tokenB = await Token.deploy("Token B", "B");
    await tokenA.deployed();
    await tokenB.deployed();

    const Test1CPMM = await ethers.getContractFactory("Test1CPMM");
    test1 = await Test1CPMM.deploy(tokenA.address, tokenB.address);
    await test1.deployed();

    await tokenA.mint(owner.address, ethers.utils.parseUnits("3000", 18));
    await tokenB.mint(owner.address, ethers.utils.parseUnits("1000", 18));
    await tokenA.connect(owner).approve(test1.address, ethers.constants.MaxUint256);
    await tokenB.connect(owner).approve(test1.address, ethers.constants.MaxUint256);
    await test1.initialize(ethers.utils.parseUnits("3000", 18), ethers.utils.parseUnits("1000", 18), 10);
  });

  it("Scenario 1: User 1 adds liquidity", async function () {
    await tokenA.mint(user1.address, ethers.utils.parseUnits("30000", 18));
    await tokenA.connect(user1).approve(test1.address, ethers.constants.MaxUint256);
    const tx = await test1.connect(user1).addLiquidity(tokenA.address, ethers.utils.parseUnits("30000", 18));
    await expect(tx).to.emit(test1, "Transfer"); // LP token issuance
  });

});