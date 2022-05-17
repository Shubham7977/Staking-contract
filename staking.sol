//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IMINDPAY.sol";
import "./Iliquidity.sol";

contract Staking is Ownable {
    uint256 private tokensPerEth = 1000;
    uint256 public lockingPeriod = 30;
    address private mindpayAddress;
    address payable private liquidityAddress;
    uint256 public stakeInvestmentPeriod = 40; //added
    uint256 public stakeInvestmentInterest = 42; //added
    bool internal locked;

    struct ledger {
        uint256 investment;
        uint256 tokens;
        uint256 bonus;
        uint256 maturity;
    }

    struct StakeInvestment{  //added
        uint256 stakedInvestment;
        uint256 stakedtoken;
        uint256 startTime;
        uint256 endTime;
    }

    event logCount(uint256 count);
    event investmentByUser(address indexed invester, uint256 investmentOfEther, uint256 token,uint256 count, uint256 bonus, uint256 endOfLockingperiod);
    event stakeInvestmentByUser(address indexed invester, uint256 investmentOfEther, uint256 token,uint256 count, uint256 endOfLockingperiod);
    event cancelInvestmentByUser(address indexed invester, uint256 count, uint256 returnedEther);
    event WithdrawStake(address caller, uint256 count, uint256 EtherAmount, uint256 token);

    // mapping(address => ledger) private investments;
        mapping(address => mapping(uint256 =>ledger)) public investments;
        mapping(address => mapping(uint256 =>StakeInvestment)) public StakedInvestment;
        mapping(address => uint256) public counts;

    constructor(address _liquidity) {
        liquidityAddress = payable(_liquidity);
    }

    modifier noReentrant(){
        require(!locked,"no reentrancy");
        locked = true;
        _;
        locked = false;
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
        require(msg.value > 0, "MINDPAY: Need to pay minimum 1 ETH");
        counts[msg.sender] += 1;
        unchecked {
            if (msg.value <= 1 ether) {
                assert(msg.value <= 1 ether);
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

                emit investmentByUser(
                    msg.sender,
                    investments[msg.sender][counts[msg.sender]].investment,
                    investments[msg.sender][counts[msg.sender]].tokens,
                    counts[msg.sender],
                    investments[msg.sender][counts[msg.sender]].bonus,
                    investments[msg.sender][counts[msg.sender]].maturity                
                );

                //tranfer ether to liquidity
                        // (bool sent, ) = liquidityAddress.call{value:((msg.value * 10) / 100)}('');
                        // require(sent,"failed by call function");
                sendTOLiquidity(10);

            } else if (msg.value > 1 ether && msg.value <= 5 ether) {
                assert(msg.value > 1 ether && msg.value <= 5 ether);
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
                emit investmentByUser(
                    msg.sender,
                    investments[msg.sender][counts[msg.sender]].investment,
                    investments[msg.sender][counts[msg.sender]].tokens,
                    counts[msg.sender],
                    investments[msg.sender][counts[msg.sender]].bonus,
                    investments[msg.sender][counts[msg.sender]].maturity                
                );


            } else {
                assert(msg.value > 5 ether);
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

                emit investmentByUser(
                    msg.sender,
                    investments[msg.sender][counts[msg.sender]].investment,
                    investments[msg.sender][counts[msg.sender]].tokens,
                    counts[msg.sender],
                    investments[msg.sender][counts[msg.sender]].bonus,
                    investments[msg.sender][counts[msg.sender]].maturity                
                );
            }
        }
        emit logCount(counts[msg.sender]);
    }



    function cancelInvestment(uint256 _count) public noReentrant{
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

        emit cancelInvestmentByUser(msg.sender, _count, (investments[msg.sender][_count].investment * 90 / 100));

        investments[msg.sender][_count].investment = 0;
        investments[msg.sender][_count].tokens = 0;
        investments[msg.sender][_count].bonus = 0;
        investments[msg.sender][_count].maturity = 0;

    }

    function stakeInvestment(uint256 _count) public noReentrant{
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

        // stakedInvestmentCount[msg.sender] += 1;




        StakedInvestment[msg.sender][_count].stakedInvestment = investments[msg.sender][_count].investment;//added
        StakedInvestment[msg.sender][_count].stakedtoken = investments[msg.sender][_count].tokens;
        StakedInvestment[msg.sender][_count].startTime = block.timestamp;
        StakedInvestment[msg.sender][_count].endTime = block.timestamp + stakeInvestmentPeriod;

        IERC20(mindpayAddress).transfer(liquidityAddress,StakedInvestment[msg.sender][_count].stakedtoken);//token transfer to liquidity

        emit stakeInvestmentByUser(
                    msg.sender,
                    StakedInvestment[msg.sender][_count].stakedInvestment,
                    StakedInvestment[msg.sender][_count].stakedtoken,
                    _count,
                    StakedInvestment[msg.sender][_count].endTime                
                );


       

        investments[msg.sender][_count].investment = 0;
        investments[msg.sender][_count].tokens = 0;
        investments[msg.sender][_count].bonus = 0;
        investments[msg.sender][_count].maturity = 0;

    }

    function WithdrawStakedAmount(uint256 _count) external noReentrant {
        require (StakedInvestment[msg.sender][_count].stakedInvestment > 0 && StakedInvestment[msg.sender][_count].stakedtoken > 0,"you haven't staked");
        require (block.timestamp >= StakedInvestment[msg.sender][_count].endTime,"maturity isn't reached");

        Iliquidity(liquidityAddress).withdrawStakedEther(payable(msg.sender),(StakedInvestment[msg.sender][_count].stakedInvestment * 90)/100);

        IMINDPAY(mindpayAddress).mintFrom(
                    msg.sender,
                    (StakedInvestment[msg.sender][_count].stakedtoken * stakeInvestmentInterest) / 100
                );

        IERC20(mindpayAddress).transferFrom(liquidityAddress,msg.sender,StakedInvestment[msg.sender][_count].stakedtoken);

        emit WithdrawStake(
            msg.sender,
            _count,
            ((StakedInvestment[msg.sender][_count].stakedInvestment * 90)/100),
            (((StakedInvestment[msg.sender][_count].stakedtoken * stakeInvestmentInterest) / 100) + (StakedInvestment[msg.sender][_count].stakedtoken))
            );
        
        StakedInvestment[msg.sender][_count].stakedInvestment = 0;
        StakedInvestment[msg.sender][_count].stakedtoken = 0;
        StakedInvestment[msg.sender][_count].startTime = 0;
        StakedInvestment[msg.sender][_count].endTime = 0;

    }

    function contractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function lockingTimeLeft(uint256 _count) public view returns(uint256){ 
        return investments[msg.sender][_count].maturity;
    }

    function stakingTimeLeft(uint256 _count) public view returns(uint256){ 
        return StakedInvestment[msg.sender][_count].endTime;
    }


}
