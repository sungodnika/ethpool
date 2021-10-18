const { expect } = require("chai");
const { ethers } = require("hardhat");
const { BigNumber } = ethers;

describe("ETH pool tests", function () {

    let host;
    let guest1;
    let guest2;

    let deposit1;
    let deposit2;
    let reward1;
    let pool; 
    let deployedPool;


    
    beforeEach(async function() {
        [host, guest1, guest2] = await ethers.getSigners();
        pool = await ethers.getContractFactory("ETHPool");
        
        deployedPool = await pool.connect(host).deploy(host.getAddress());
        await deployedPool.deployed();
        
        deposit1 = ethers.utils.parseEther("100");
        deposit2 = ethers.utils.parseEther("300");
        reward1 = ethers.utils.parseEther("200");
    });

    // Happy cases
    it("test case 1", async function () {
        // check contribution from a single user.
        await deployedPool.connect(guest1).deposit_stake({ value: deposit1 });
        await deployedPool.connect(host).deposit_reward({value : reward1});
        await deployedPool.connect(guest2).deposit_stake({ value: deposit2 });
        await expect(deployedPool.connect(guest1).withdraw_rewards()).to.emit(deployedPool, 'Withdraw').withArgs(guest1.address, reward1);
        await expect(deployedPool.connect(guest2).withdraw_rewards()).to.emit(deployedPool, 'Withdraw').withArgs(guest2.address, 0);

    });

    it("test case 2", async function () {
        // check contribution from a single user.
        await deployedPool.connect(guest1).deposit_stake({ value: deposit1 });
        await deployedPool.connect(guest2).deposit_stake({ value: deposit2 });
        await deployedPool.connect(host).deposit_reward({value : reward1});
        await expect(deployedPool.connect(guest2).withdraw_rewards()).to.emit(deployedPool, 'Withdraw').withArgs(guest2.address, ethers.utils.parseEther("150"));
        await expect(deployedPool.connect(guest1).withdraw_rewards()).to.emit(deployedPool, 'Withdraw').withArgs(guest1.address, ethers.utils.parseEther("50"));

    });



});