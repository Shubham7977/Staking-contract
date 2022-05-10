//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MINDPAY is ERC20, Ownable {
    address stakingContract;

    constructor(
        address _stakingContract
    ) ERC20("MINDDEFT", "MDT") {
        stakingContract = _stakingContract;
    }

    function mintFrom(address _account, uint256 _amount) public  {
        require(msg.sender == stakingContract);
        
        _mint(_account, _amount);
    }

    function burn(uint256 _amount) public {
        require(msg.sender == stakingContract, "can be invoked by only staking contract");
        _burn(msg.sender, _amount);
    }

    function setStakingAddress(address _stakingContract) public onlyOwner {
        stakingContract = _stakingContract;
    }

    function getStakingAddress() public view returns (address) {
        return stakingContract;
    }
}
