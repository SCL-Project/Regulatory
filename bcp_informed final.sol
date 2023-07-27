//Jasmin
/* BCP Parent Contract "BCP_informed.sol"
   Copyright (c) 2019-2020 Blockchain Presence
   To order data from Blockchain Presence: 
   
     (1) Import this file into your Solidity file.
     
     (2) Let your contract inherit the abstract contract "BCP_informed".
        
     (3) Use the view function GetTransactionCosts to determine the accurate ETH value for the function call. 
     
     (4) Let one of your functions call the Order function. 
       
     (5) Implement the Mailbox function in your smart contract.
     
     (6) Doublecheck that the modifier "onlyBCP" is added to your implementation of the Mailbox function.
    
   Example: 
      
     pragma solidity ^0.8.0; 
     
     import "https://github.com/BlockchainPresence/Blockchain-Project/blob/master/Version%201.1.10%20(active)/Use%20Cases/BCP_informed.sol"

     contract yourContract is BCP_informed {
        
         function Mailbox(uint _orderID, int88 _data, bool _statusFlag) override external payable onlyBCP {
         ...
         }
         
         uint32 orderID = BCP.ORDER.value(BCP.GetTransactionCosts(_commitmentID,_gasForMailbox)) (_commitmentID,_gasForMailbox,_location,_orderDate);
      }
    
*/    
//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0; 

interface BCP_interface {
    function GetTransactionCosts(int64 _commitmentID, uint40 _gasForMailbox, uint gasPriceInGwei) external view returns(uint transactionCost);
    function Order(int64 commitmentID,  string calldata _query, uint32 _orderDate,uint40 _gasForMailbox, uint64 _gasPriceInGwei) external payable returns(uint32 orderID);
    function cancelOrder(uint32 _orderID) external payable;      
}

abstract contract BCP_informed {
    BCP_interface BCP;
    address payable public BCP_Address;    
    modifier onlyBCP {
        require(msg.sender==BCP_Address);
        _;
    }
 
    event ReceiverConnection(address Rec, address indexed SC);

    constructor(address payable addr) {
        emit ReceiverConnection(msg.sender,address(this));
        BCP_Address = addr;
        BCP = BCP_interface(addr);
    }
    
    function getBCPAddr() external view returns (address payable) {
        return BCP_Address;
    }
    
    function Mailbox(uint32 _orderID, int88 _data, bool _statusFlag) virtual external payable;
    
    fallback() virtual payable external;

    receive() virtual payable external {}

}
