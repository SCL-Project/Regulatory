// ***************************************************************************************************************
// SPDX-License-Identifier: MIT
// @title ETHOracle
// @authors Samuel Clauss
// Smart Contracts Lab, University of Zurich
// Created: December 18, 2023
// ***************************************************************************************************************
// Read the Whitepaper https://github.com/SCL-Project/Regulatory/blob/main/Whitepaper.md
// ***************************************************************************************************************
pragma solidity ^0.8.20;


import "@openzeppelin/contracts/access/Ownable.sol";

contract ExchangeRate_ETH_CHF is Ownable {
    uint80 private exchangeRate = 1927330;

    
    constructor(address initialOwner) 
            Ownable(initialOwner)
        {}
    

    /*
     * @dev Function simulates an Oracle for the ExchangeRate between ETH and CHF. The rate given is ETH/CHF and it is multiplied by factor 1000. The initial exchangeRate - 19273300 - represents the rate of 1927.33.
     * @param The ExchangeRate of ETH to CHF
     */
    function setExchangeRate(uint80 _exchangeRate) external onlyOwner {
        exchangeRate = _exchangeRate;
    }


    /*
     * @dev Function returns the ExchangeRate of this Oracle
    */
    function getExchangeRate() external view returns(uint80) {
        return exchangeRate;
    }
}
