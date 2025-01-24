const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('Test2CPMM', function () {
  let test2, tokenA, tokenB;
  let owner, user1, user2, user3;

  beforeEach(async function () {
    [owner, user1, user2, user3] = await ethers.getSigners();

    // Deploy tokens and Test2CPMM
    const Token = await ethers.getContractFactory('ERC20Mock');
    tokenA = await Token.deploy('Token A', 'A');
    tokenB = await Token.deploy('Token B', 'B');
    await tokenA.deployed();
    await tokenB.deployed();

    const Test2CPMM = await ethers.getContractFactory('Test2CPMM');
    test2 = await Test2CPMM.deploy(tokenA.address, tokenB.address);
    await test2.deployed();

    // Approve and initialize
    await tokenA.mint(owner.address, ethers.utils.parseUnits('500000', 18));
    await tokenB.mint(owner.address, ethers.utils.parseUnits('100000', 18));
    await tokenA
      .connect(owner)
      .approve(test2.address, ethers.constants.MaxUint256);
    await tokenB
      .connect(owner)
      .approve(test2.address, ethers.constants.MaxUint256);
    await test2.initialize(
      ethers.utils.parseUnits('500000', 18),
      ethers.utils.parseUnits('100000', 18),
      5
    );
  });

  it('User 1 provides liquidity', async function () {
    await tokenA.mint(user1.address, ethers.utils.parseUnits('50000', 18));
    await tokenA
      .connect(user1)
      .approve(test2.address, ethers.constants.MaxUint256);

    await expect(
      test2
        .connect(user1)
        .addLiquidity(tokenA.address, ethers.utils.parseUnits('50000', 18))
    ).to.emit(test2, 'Transfer');
  });

  it('User 2 provides liquidity', async function () {
    await tokenB.mint(user2.address, ethers.utils.parseUnits('100000', 18));
    await tokenB
      .connect(user2)
      .approve(test2.address, ethers.constants.MaxUint256);

    await expect(
      test2
        .connect(user2)
        .addLiquidity(tokenB.address, ethers.utils.parseUnits('100000', 18))
    ).to.emit(test2, 'Transfer');
  });

  it('User 3 sells A tokens repeatedly', async function () {
    await tokenA.mint(user3.address, ethers.utils.parseUnits('7500', 18));
    await tokenA
      .connect(user3)
      .approve(test2.address, ethers.constants.MaxUint256);

    for (let i = 0; i < 3; i++) {
      const tx = await test2
        .connect(user3)
        .swap(tokenA.address, ethers.utils.parseUnits('2500', 18));
      await expect(tx).to.emit(test2, 'PriceWarning');
    }
  });
});
