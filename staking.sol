//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IMINDPAY.sol";

contract Staking is Ownable {
    uint256 private tokensPerEth = 1000;
    uint256 public lockingPeriod = 900;
    address private mindpayAddress;
    address payable private liquidityAddress;

    struct ledger {
        uint256 investment;
        uint256 tokens;
        uint256 bonus;
        uint256 maturity;
    }

    mapping(address => ledger) private investments;

    constructor(address _liquidity) {
        liquidityAddress = payable(_liquidity);
    }

    function setTokenAddress(address _mindpayAddress) public onlyOwner {
        mindpayAddress = _mindpayAddress;
    }

    function getTokenAddress() public view returns (address) {
        return mindpayAddress;
    }

    function setLiquidityAddress(address _liquidityAddress) public onlyOwner {
        liquidityAddress = payable(_liquidityAddress);
    }

    function getLiquidityAddress() public view returns (address) {
        return liquidityAddress;
    }

    function getInvestments()
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        uint256 investment = investments[msg.sender].investment;
        uint256 tokens = investments[msg.sender].tokens;
        uint256 bonus = investments[msg.sender].bonus;
        uint256 maturity = investments[msg.sender].maturity;

        return (investment, tokens, bonus, maturity);
    }

    function invest() public payable {
        require(msg.value > 0, "MINDPAY: Need to pay ETH");
        unchecked {
            if (msg.value < 1 ether) {
                investments[msg.sender].investment += msg.value;
                investments[msg.sender].tokens = msg.value * tokensPerEth;
                investments[msg.sender].bonus = 0;
                investments[msg.sender].maturity =
                    block.timestamp +
                    lockingPeriod;

                IMINDPAY(mindpayAddress).mintFrom(
                    address(this),
                    msg.value * tokensPerEth
                );
                // liquidityAddress.transfer((msg.value * 10) / 100);
                (bool sent, ) = liquidityAddress.call{value:((msg.value * 10) / 100)}('');
                require(sent,"failed by call function");
            } else if (msg.value >= 1 ether && msg.value <= 5 ether) {
                investments[msg.sender].investment = msg.value;
                investments[msg.sender].tokens = msg.value * tokensPerEth;
                investments[msg.sender].bonus =
                    ((msg.value * tokensPerEth) * 10) /
                    100;
                investments[msg.sender].maturity =
                    block.timestamp +
                    lockingPeriod;

                // liquidityAddress.transfer((msg.value * 10) / 100);
                (bool sent, ) = liquidityAddress.call{value:((msg.value * 10) / 100)}('');
                require(sent,"failed by call function");

                IMINDPAY(mindpayAddress).mintFrom(
                    address(this),
                    investments[msg.sender].tokens
                );

                // bonus token transfer
                IMINDPAY(mindpayAddress).mintFrom(
                    msg.sender,
                    investments[msg.sender].bonus
                );
            } else {
                investments[msg.sender].investment += msg.value;
                investments[msg.sender].tokens = msg.value * tokensPerEth;
                investments[msg.sender].bonus =
                    ((msg.value * tokensPerEth) * 20) /
                    100;
                investments[msg.sender].maturity =
                    block.timestamp +
                    lockingPeriod;

                // liquidityAddress.transfer((msg.value * 10) / 100);
                (bool sent, ) = liquidityAddress.call{value:((msg.value * 10) / 100)}('');
                require(sent,"failed by call function");

                IMINDPAY(mindpayAddress).mintFrom(
                    address(this),
                    investments[msg.sender].tokens
                );

                // bonus token transfer
                IMINDPAY(mindpayAddress).mintFrom(
                    msg.sender,
                    investments[msg.sender].bonus
                );
            }
        }
    }

    function cancelInvestment() public {
        require(
            investments[msg.sender].investment != 0,
            "No investment founnd"
        );
        require(
            investments[msg.sender].maturity < block.timestamp,
            "you can cancel after locking period"
        );

        // payable(msg.sender).transfer(
        //     (investments[msg.sender].investment * 90) / 100
        // );

        (bool sent, ) = payable(msg.sender).call{value:(
            (investments[msg.sender].investment * 90) / 100
        )}('');
        require(sent,"failed by call function");


        IMINDPAY(mindpayAddress).burn(investments[msg.sender].tokens);
    }

    function stakeInvestment() public {
        require(
            investments[msg.sender].investment != 0,
            "No investment founnd"
        );
        require(
            investments[msg.sender].maturity < block.timestamp,
            "you can cancel after locking period"
        );

        // liquidityAddress.transfer(
        //     (investments[msg.sender].investment * 90) / 100
        // );

        (bool sent, ) = liquidityAddress.call{value:(
            (investments[msg.sender].investment * 90) / 100
        )}('');
        require(sent,"failed by call function");
    }

    function contractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function timeLeft() public view returns(uint256){ // added
        return investments[msg.sender].maturity;
    }
}
