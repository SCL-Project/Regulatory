// Copyright (c) 2019-2023 Smart Contracts Lab

//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;  

// KYCrypto contracts inherits BCP_informed contract to order data through BCP
import "./bcp_informed.sol";

contract KYCrypto is BCP_informed { 


//--------------------------Global_Variables-------------------------
   
    // set to msg.sender within the constructor
    address public owner; 

    // total Supply of KYCrypto (ERC20 Token)
    uint256 private _totalSupply;   
    

//----------------------------Constructor----------------------------
    
    // Initializes contract and connect to the BCP Contract
    constructor (address payable addr, uint256 Supply) BCP_informed(addr) {
        owner = msg.sender;
        _totalSupply = Supply;
    }
    

//------------------------------Structs------------------------------
    
    /**
    @notice stores a deposition.
    @param address (addr) is the Externally Owned Account (EOA) address of the sender or receiver of KYCrypto.
    @param amount of cryptocurrency you want to convert into KYCrypto.
    */
    struct Deposit{
        address payable addr;
        uint amount;
    }


    /**
    @notice stores information of a whitelisted Account holder.
    @param balance is the amount of KYCrypto of a user.
    @param status signifies if user is whitelisted.
    */
    enum Status  {NONE, BLOCKED, APPROVED, DECLINED}

    struct User{
        uint balance;
        Status status;
    }
   

//----------------------------Mappings-------------------------------

    // maps uint to Deposit struct
    mapping(uint => Deposit) public deposits;
    
    // maps address to User struct
    mapping(address => User) public users;
    
    // maps address to uint
    mapping(address => uint) public declinedusers;

    // maps the token owners address to the address of the spender and the token amount allowed
    mapping(address => mapping(address => uint256)) private _allowed;
 

 //------------------------------Events------------------------------ 
    
        event regist(
        address payable adr,
        uint _value,
        uint _id
    );
    
        event transf(
        address from,
        address to,
        uint amount
    );
    
        event pullKYCrypto(
        address from,
        uint amount
    );

        event pulldeclineKYCrypto(
        address from
    );
    
        event blockedAcount(
        address from
    );

        event unblockedAcount(
        address from
    );

        event unusedKYCrypto(
        address from,
        uint amount
    );

        event Approval(
        address from,
        address to,
        uint256 amount
    );


//----------------------------modifier----------------------------
    modifier onlyOwner() {
        require(msg.sender==owner, "Sender not authorized.");
        _;  
    }


    function initialofall() public onlyOwner{
        users[owner].status = Status.APPROVED;
    }
    

//----------------------------Helper_function----------------------------

    /**
    @dev this function is needed for the inquire function. The function converts a ledger address to an ASCII string. 
    */
    function addresstoAsciiString(address x) internal pure returns (string memory) {
        bytes memory s = new bytes(42);
        bytes memory name = abi.encodePacked("0x");
    
        for (uint i = 0; i < 20; i++) {
             bytes1 b = bytes1(uint8(uint(uint160(x)) / (2**(8*(19 - i)))));
             bytes1 hi = bytes1(uint8(b) / 16);
             bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
             s[2*i] = char(hi);
             s[2*i+1] = char(lo);            
        }
        name = abi.encodePacked(name, s);
        return string (name);
        }

    /**
    @dev this function is needed for the addresstoAsciiString function.
    */
    function char(bytes1 b) internal pure returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
        }
    
    
//----------------------------Functions----------------------------

    // provides the total token supply information
    function totalSupply() view public returns (uint256) {
        return _totalSupply;
    }


    // provides balance of an account
    function balanceOf(address _addr) public view returns (uint256) {
        return users[_addr].balance;
    }


    // enables the contract owner to increase token supply
    function Token_mint(uint256 amount) public onlyOwner returns (bool success) { 
    _totalSupply += amount;
    return true;
    }


    // enables the contract owner to decrease token supply
    function Token_burn(uint256 amount) public onlyOwner returns (bool success) {
    _totalSupply -= amount;
    return true;
    }


    // returns the approved number of coins that can be spent from a certain account to another
    function allowance(address _from, address _to) view public returns(uint256) {
        return _allowed[_from][_to];
    }


    // enables a spender to withdraw a set number of tokens from a specified account
    function approve(address _to, uint256 _amount) public returns (bool) {
        require(_to != address(0));

        User storage from = users[msg.sender];
        User storage to = users[_to];
        require(from.status == Status.APPROVED, "To approve the spending of KYCrypto you need to have a whitelisted account");
        require(to.status == Status.APPROVED, "To get approved to spend KYCrypto you need to have a whitelisted account");

        _allowed[msg.sender][_to] = _amount;
        emit Approval(msg.sender, _to, _amount);
        return true;
    }


    // enables a spender to increase the token approval from a specified account
    function increaseApproval(address _to, uint256 addedApproval) public returns (bool) {
        require(_to != address(0));

        User storage from = users[msg.sender];
        User storage to = users[_to];
        require(from.status == Status.APPROVED, "To approve KYCrypto you need to have a whitelisted account");
        require(to.status == Status.APPROVED, "To get approved to spend KYCrypto you need to have a whitelisted account");

        _allowed[msg.sender][_to] += addedApproval;
        emit Approval(msg.sender, _to, _allowed[msg.sender][_to]);
        return true;
    } 


    // enables a spender to decrease the token approval from a specified account
    function decreaseApproval(address _to, uint256 subtractedApproval) public returns (bool) {
        require(_to != address(0));

        User storage from = users[msg.sender];
        User storage to = users[_to];
        require(from.status == Status.APPROVED, "To approve KYCrypto you need to have a whitelisted account");
        require(to.status == Status.APPROVED, "To get approved to spend KYCrypto you need to have a whitelisted account");

        _allowed[msg.sender][_to] -= subtractedApproval;
        emit Approval(msg.sender, _to, _allowed[msg.sender][_to]);
        return true;
    } 


    // executes transfers of a specified number of tokens from a specified address
    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool success) {
        User storage from = users[_from];
        User storage to = users[_to];
        User storage beneficiary = users[msg.sender];

        require(from.balance >= _amount, "Insufficient KYCrypto balance.");
        require(_allowed[_from][msg.sender] >= _amount, "Transfer value exceeds Allowance.");
        require(from.status == Status.APPROVED, "The sender of KYCrypto has to have a whitelisted account");
        require(to.status == Status.APPROVED, "The receiver of KYCrypto has to have a whitelisted account");
        require(beneficiary.status == Status.APPROVED, "You need a whitelisted Account to spend KYCrypto");
        from.balance -= _amount;
        to.balance += _amount;
        _allowed[_from][msg.sender] -= _amount;

        emit transf(_from, _to, _amount);
        return true;
    }


    /**
    @dev function transfer transfers KYCrypto to another whitelisted Account
    @param _to address to which KYCrypto is sent
    @param _amount amount of KYCrypto sent
    */
    function transfer(address _to, uint _amount) public returns (bool success){ 
        User storage from = users[msg.sender];
        User storage to = users[_to];
        require (from.status == Status.APPROVED, "To send KYCrypto you need to have a whitelisted Account");
        require(from.balance >= _amount, "Insufficient KYCrypto balance.");
        require (to.status == Status.APPROVED, "The receiver must be a whitelisted Account");
        from.balance -= _amount;
        to.balance += _amount;
        emit transf(msg.sender, _to, _amount);
        return true;
        }     
    

    /**
    @dev function _Account_Registration is used to if a person wants to exchange cryptocurrency into KYCrypto
    @param _bankid the commitmentID of the bank where the user has his money
    */
    function _Account_Registration(uint32 _bankid) external payable returns (bool success) {
        require(users[msg.sender].status == Status.NONE, "Account is frozen or already registered");
        require(msg.value > 0, "A value must be sent with the function call!");
        address payable addresstoRegsiter = payable(msg.sender);
        uint32 _commitmentID = _bankid;
        uint32 _gasForMailbox = 200000;    //Our Mailbox function uses at most 200'000 gas
        uint gasPriceInGwei = 30;
        uint transactionCost = BCP.GetTransactionCosts(int64(uint64(_commitmentID)), _gasForMailbox,gasPriceInGwei);        
        require(msg.value >= transactionCost, "Value of the Transaction too low.");
        uint orderID = BCP.Order{value:transactionCost}(int64(uint64(_commitmentID)),addresstoAsciiString (addresstoRegsiter),uint32(block.timestamp),20000,uint64(gasPriceInGwei));
        uint amount_sent = msg.value - transactionCost;
        _totalSupply -= amount_sent;
        deposits[orderID] = Deposit(addresstoRegsiter, amount_sent);
        emit regist(payable(msg.sender), msg.value, _bankid);
        return true;
        }     

    function _depositKYCrypto() public payable returns (bool success) {
        require(users[msg.sender].status == Status.APPROVED, "Account is blocked or not yet registered");
        require(msg.value > 0, "A value must be sent with the function call!");
        uint put_amount = (99 * msg.value)/100;
        uint put_fee = (1 * msg.value)/100;
        users[owner].balance += put_fee;
        _totalSupply -= msg.value;
        users[msg.sender].balance += put_amount;
        return true;

    }


    /**
    @dev function Mailbox is used to reiceive data from BCP
    @param _orderID uint that identifies a specific order (is constant)
    @param _data is the finally requested information behind the order
    @param _statusFlag is a control variable that shows if the incoming transaction contains the datapoint
    */
    function Mailbox(uint32 _orderID, int88 _data, bool _statusFlag) external payable override onlyBCP {
        
        Deposit memory t = deposits[_orderID];
        uint amount = t.amount;
        uint cryptodeposit = (99* amount)/100;
        uint fee_for_registering = (1 * amount)/100;
        if(_statusFlag && _data == 1) {
            users[t.addr].balance += cryptodeposit;
            users[owner].balance += fee_for_registering;
            users[t.addr].status=Status.APPROVED;
        }
        else {
            declinedusers[t.addr] = amount;
            users[t.addr].status = Status.DECLINED;
        }
        delete deposits[_orderID];
        
        }  
    

    /**
    @dev function _withdrawthedeclinedCrypto will be called by persons whose cryptocurrency is declined to get it back.
    */    
    function _withdrawthedeclinedCrypto() public payable returns (bool success) {
        uint moneyback = declinedusers[msg.sender];
        delete declinedusers[msg.sender];
        payable(msg.sender).transfer(moneyback);
        emit pulldeclineKYCrypto(msg.sender);
        
        if(users[msg.sender].status == Status.DECLINED) {
            users[msg.sender].status = Status.NONE;
        }
        return true;
    }   


    /**
    @dev function _withdrawKYCrypto with this function KYCrypto can be exchanged to Ether
    @param _pull_amount the amount of White Ether which should be exchanged back
    **/
    function _withdrawKYCrypto(uint _pull_amount) public payable returns (bool success) {
        require(users[msg.sender].status == Status.APPROVED);
        require(_pull_amount <= users[msg.sender].balance);
        uint pull_amount = (99 * _pull_amount)/100;
        uint pull_fee = (1 * _pull_amount)/100;
        users[msg.sender].balance -= _pull_amount;
        users[owner].balance += pull_fee;
        payable(msg.sender).transfer(pull_amount);
        _totalSupply += pull_amount;
        emit pullKYCrypto(msg.sender, _pull_amount);
   
        return true;      
      }    
        

    /**
    @dev function the function Account_Blocking enables to block accounts
    @param _unlist the address to be blocked 
    **/
    function Account_Blocking(address payable _unlist) public payable onlyOwner returns (bool success) {
        users[_unlist].status=Status.BLOCKED;
        emit blockedAcount(_unlist);
        return true;     
      }       
      

    /**
    @dev function the function Account_Unblocking enables to unblocked accounts
    @param _relist the address to be unblocked
    **/
    function Account_Unblocking(address payable _relist) public payable onlyOwner returns (bool success) {
        users[_relist].status=Status.APPROVED;
        emit unblockedAcount(_relist);
        return true;
      }      


    /**
    @dev function SmartContractBalance get the balance of the smart contract back
    **/
    function SmartContractBalance() external view returns(uint){ 
        return address(this).balance;
    } 
    

    //You can withdraw your cryptocurrency from the _withdrawKYCrypto function
    fallback () override external payable  {
        declinedusers[msg.sender] = msg.value - 10_000_000;
        emit unusedKYCrypto(msg.sender, msg.value);
    }


    receive() payable external override {}

 }
