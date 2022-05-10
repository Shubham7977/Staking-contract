//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract liquidity is Ownable {
    address private mindpayAddress;
    event received(address indexed _address, uint256 _amount);

    function setTokenAddress(address _mindpayAddress) public onlyOwner {
        mindpayAddress = _mindpayAddress;
    }

    function getTokenAddress() public view returns (address) {
        return mindpayAddress;
    }

    receive() external payable {
        emit received(msg.sender, msg.value);
    }

    function contractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function withdrawAllFund() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
        uint256 tokenBalance = IERC20(mindpayAddress).balanceOf(address(this));
        IERC20(mindpayAddress).transfer(address(this), tokenBalance);
    }
}
