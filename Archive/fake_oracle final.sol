pragma solidity >=0.7.0 <0.9.0;  
//SPDX-License-Identifier: UNLICENSED

interface Contract_interface {
        function Mailbox(uint32 _orderID, int88 _data, bool _statusFlag) external payable; 
}
contract FakeOracle {

    uint orderId = 0;
    struct order {
        int64 commitmentID;
        string query;
        uint32 orderDate;
        uint40 _gasForMailbox;
        uint64 _gasPriceInGwei;
        address payable _addr;
    }

    mapping(uint => order) public orders;

    function GetTransactionCosts(int64 _commitmentID, uint40 _gasForMailbox, uint gasPriceInGwei) external view returns(uint transactionCost) {
        return 0;
    }
    function Order(int64 commitmentID,  string calldata _query, uint32 _orderDate,uint40 _gasForMailbox, uint64 _gasPriceInGwei) external payable returns(uint32 orderID) {
        order memory o = order(commitmentID, _query, _orderDate, _gasForMailbox, _gasPriceInGwei, payable(msg.sender));
        orders[orderId] = o;
        orderId++;
        return uint32(orderId -1);
    }

    function relay(uint32 _orderId, int88 _data, bool _statusFlag) external  {
        order memory o = orders[_orderId];
        Contract_interface c = Contract_interface(o._addr);
        c.Mailbox{value:0}(_orderId, _data, _statusFlag);
        
    }
    
    function returncurrentOrder() view public returns (uint256) {
        return uint(orderId-1);
    }


}
