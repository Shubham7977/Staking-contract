// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface Iliquidity {
    function withdrawStakedEther(address payable _user, uint256 _stakedEtherAmount) external;
}