// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

contract ETHPool {

  address public owner;
  uint public total_stake;
  uint public reward_per_unit;
  mapping(address => uint) public stake;
  // snapshot of stakes
  mapping(address => uint) public reward_tally;

  //sets the owner to sender
  constructor(address _owner) {
    owner = _owner;
  }


  // events
  event Withdraw(address withdrawer, uint amount);
  event Deposited(address contributor, uint amount, uint mapValue, uint depositedFunds);
  event Rewards(uint rewards);
  
  modifier onlyOwner() {
    require(msg.sender == owner, 'Not the Owner');
    _;
  }

  // used by the owner of the contract to deposit rewards
  function deposit_reward() external payable onlyOwner {
    require(total_stake > 0 , "No stakes to distribute rewards");
    reward_per_unit = reward_per_unit + msg.value * 100 / total_stake;
    emit Rewards(msg.value);
  }

  // used by users to deposit stakes
  function deposit_stake() external payable {
    stake[msg.sender] += msg.value;
    reward_tally[msg.sender] += reward_per_unit * msg.value / 100;
    total_stake += msg.value;
    emit Deposited(msg.sender, msg.value, stake[msg.sender], total_stake);
  }

  // used by users to withdraw stakes
  function withdraw_stake(uint amount) external returns (bool) {
    require(stake[msg.sender] > amount, "Not enough amount to withdraw");
    stake[msg.sender] -= amount;
    reward_tally[msg.sender] = reward_tally[msg.sender] - reward_per_unit * amount / 100;
    total_stake = total_stake - amount;
    (bool success, ) = msg.sender.call{value:amount}("");
    if(success) {
      emit Withdraw(msg.sender, amount);
    }
    require(success, 'fund transfer failed');
    return success;
  }

  // used by users to withdraw rewards
  function withdraw_rewards() external returns (bool) {
    uint reward = stake[msg.sender] * reward_per_unit / 100 - reward_tally[msg.sender];
    reward_tally[msg.sender] = stake[msg.sender] * reward_per_unit / 100;
    (bool success, ) = msg.sender.call{value:reward}("");
    if(success) {
      emit Withdraw(msg.sender, reward);
    }
    require(success, 'fund transfer failed');
    return success;
  }
}