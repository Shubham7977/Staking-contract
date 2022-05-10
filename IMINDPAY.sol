// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IMINDPAY {
    function caller() external view returns (address);
    function mintFrom(address _account, uint256 _amount) external;  
    function burn(uint256 _amount) external;
}
