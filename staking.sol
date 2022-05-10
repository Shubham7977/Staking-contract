//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IMINDPAY.sol";

contract Staking is Ownable {
    uint256 private tokensPerEth = 1000;
    uint256 public lockingPeriod = 30;
    address private mindpayAddress;
    address payable private liquidityAddress;

    struct ledger {
        uint256 investment;
        uint256 tokens;
        uint256 bonus;
        uint256 maturity;
    }

    // mapping(address => ledger) private investments;
        mapping(address => mapping(uint256 =>ledger)) public investments;
        mapping(address => uint256) public counts;

    constructor(address _liquidity) {
        liquidityAddress = payable(_liquidity);
    }

    function setTokenAddress(address _mindpayAddress) public onlyOwner {
        mindpayAddress = _mindpayAddress;
    }

    function getTokenAddress() public view returns (address) {
        return mindpayAddress;
    }

    function getLiquidityAddress() public view returns (address) {
        return liquidityAddress;
    }

    function getInvestments(uint256 _count)
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        uint256 investment = investments[msg.sender][_count].investment;
        uint256 tokens = investments[msg.sender][_count].tokens;
        uint256 bonus = investments[msg.sender][_count].bonus;
        uint256 maturity = investments[msg.sender][_count].maturity;

        return (investment, tokens, bonus, maturity);
    }

    function sendTOLiquidity(uint256 _percent) private {
        (bool sent, ) = liquidityAddress.call{value:((msg.value * _percent) / 100)}('');
        require(sent,"failed by call function");
    }

    function invest() public payable {
        require(msg.value > 0, "MINDPAY: Need to pay ETH");
        counts[msg.sender] += 1;
        unchecked {
            if (msg.value <= 1 ether) {
                investments[msg.sender][counts[msg.sender]].investment = msg.value;
                investments[msg.sender][counts[msg.sender]].tokens = msg.value * tokensPerEth;
                investments[msg.sender][counts[msg.sender]].bonus = 0;
                investments[msg.sender][counts[msg.sender]].maturity =
                    block.timestamp +
                    lockingPeriod;


                //minting tokens to the contract    
                IMINDPAY(mindpayAddress).mintFrom(
                    address(this),
                    investments[msg.sender][counts[msg.sender]].tokens
                );

                //tranfer ether to liquidity
                        // (bool sent, ) = liquidityAddress.call{value:((msg.value * 10) / 100)}('');
                        // require(sent,"failed by call function");
                sendTOLiquidity(10);

            } else if (msg.value > 1 ether && msg.value <= 5 ether) {
                investments[msg.sender][counts[msg.sender]].investment = msg.value;
                investments[msg.sender][counts[msg.sender]].tokens = (msg.value * tokensPerEth);
                investments[msg.sender][counts[msg.sender]].bonus =
                    (investments[msg.sender][counts[msg.sender]].tokens * 10) /
                    100;

                investments[msg.sender][counts[msg.sender]].maturity =
                    block.timestamp +
                    lockingPeriod;

                //tranfer ether to liquidity
                        // (bool sent, ) = liquidityAddress.call{value:((msg.value * 10) / 100)}('');
                        // require(sent,"failed by call function");
                sendTOLiquidity(10);                

                //minting tokens to the contract
                IMINDPAY(mindpayAddress).mintFrom(
                    address(this),
                    investments[msg.sender][counts[msg.sender]].tokens
                );

                // bonus token transfer
                IMINDPAY(mindpayAddress).mintFrom(
                    msg.sender,
                    investments[msg.sender][counts[msg.sender]].bonus
                );
            } else {
                console.log("hi");
                investments[msg.sender][counts[msg.sender]].investment = msg.value;
                investments[msg.sender][counts[msg.sender]].tokens = (msg.value * tokensPerEth);
                investments[msg.sender][counts[msg.sender]].bonus =
                    (investments[msg.sender][counts[msg.sender]].tokens * 20) /
                    100;

                investments[msg.sender][counts[msg.sender]].maturity =
                    block.timestamp +
                    lockingPeriod;

                //tranfer ether to liquidity
                        // (bool sent, ) = liquidityAddress.call{value:((msg.value * 10) / 100)}('');
                        // require(sent,"failed by call function");
                sendTOLiquidity(10);

                //minting tokens to the contract
                IMINDPAY(mindpayAddress).mintFrom(
                    address(this),
                    investments[msg.sender][counts[msg.sender]].tokens 
                );

                // bonus token transfer
                IMINDPAY(mindpayAddress).mintFrom(
                    msg.sender,
                    investments[msg.sender][counts[msg.sender]].bonus
                );
            }
        }
    }





    function cancelInvestment(uint256 _count) public {
        require(
            investments[msg.sender][_count].investment != 0,
            "No investment founnd"
        );
        require(
            investments[msg.sender][_count].maturity < block.timestamp,
            "you can cancel after locking period"
        );

        //tranfer ether to user
        (bool sent, ) = payable(msg.sender).call{value:(
            (investments[msg.sender][_count].investment * 90) / 100
        )}('');
        require(sent,"failed by call function");

        //burning token 100%
        IMINDPAY(mindpayAddress).burn(investments[msg.sender][_count].tokens);
        IMINDPAY(mindpayAddress).burnFrom(msg.sender, investments[msg.sender][_count].bonus);

        investments[msg.sender][_count].investment = 0;
        investments[msg.sender][_count].tokens = 0;
        investments[msg.sender][_count].bonus = 0;
        investments[msg.sender][_count].maturity = 0;

    }

    function stakeInvestment(uint256 _count) public {
        require(
            investments[msg.sender][_count].investment != 0,
            "No investment founnd"
        );
        require(
            investments[msg.sender][_count].maturity < block.timestamp,
            "you can cancel after locking period"
        );

        ////tranfer ether to liquidity
        (bool sent, ) = liquidityAddress.call{value:(
            (investments[msg.sender][_count].investment * 90) / 100
        )}('');
        require(sent,"failed by call function");
    }

    function contractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function timeLeft(uint256 _count) public view returns(uint256){ // added
        return investments[msg.sender][_count].maturity;
    }
}
