//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract liquidity is Ownable {
    address private mindpayAddress;
    address public stakingContract; ////////added for stakeInvestment
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

    function mindpayBalance() public view returns(uint256){
        return IERC20(mindpayAddress).balanceOf(address(this));
    }

    function contractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function setStakingContract(address _stakingContract) external onlyOwner{  ////////added for stakeInvestment
        stakingContract = _stakingContract;
    }

    function withdrawStakedEther(address payable _user, uint256 _stakedEtherAmount) external { ////added for stakeInvestment
        require(msg.sender == stakingContract,"you are not authorised");
        (bool sent, ) = _user.call{value:_stakedEtherAmount}('');
        require(sent,"failed by call function");
    }

    function withdrawAllFund() public onlyOwner {

        payable(msg.sender).transfer(address(this).balance);
        uint256 tokenBalance = IERC20(mindpayAddress).balanceOf(address(this));
        IERC20(mindpayAddress).approve(msg.sender,tokenBalance);
        IERC20(mindpayAddress).transfer(msg.sender, tokenBalance);
    }

    function approveStakingContract() external onlyOwner{
        uint bal = IERC20(mindpayAddress).balanceOf(address(this));
        IERC20(mindpayAddress).approve(stakingContract,bal);
    }
}
