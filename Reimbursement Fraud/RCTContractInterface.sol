// ***************************************************************************************************************
// SPDX-License-Identifier: MIT
// @title RCTContractInterface
// @authors Samuel Clauss
// Smart Contracts Lab, University of Zurich
// Created: December 18, 2023
// ***************************************************************************************************************
// Read the Whitepaper https://github.com/SCL-Project/Regulatory
// ***************************************************************************************************************
pragma solidity ^0.8.20;

interface RCTContractInterface {
    function getCompany(address) external view returns(string memory, string memory, string memory);
    function transferNFT(address, uint256) external;
    function getTokenInformation(uint256) external view returns(uint8, uint32, uint40, uint8, string memory, string memory);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function getAddresses(uint _tokenId) external  view returns(address[] memory);
}
