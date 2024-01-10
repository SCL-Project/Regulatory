// ***************************************************************************************************************
// SPDX-License-Identifier: MIT
// @title ReceiptTokenRefundingContract
// @authors Samuel Clauss
// Smart Contracts Lab, University of Zurich
// Created: December 18, 2023
// ***************************************************************************************************************
// Read the Whitepaper https://github.com/SCL-Project/Regulatory/blob/main/Whitepaper.md
// ***************************************************************************************************************
pragma solidity ^0.8.20;

import "./RCTContractInterface.sol";
import "./ETHOracle.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract ReceiptTokenRefunding is IERC721Receiver, Ownable {
    uint256 private percentageFee;
    RCTContractInterface public RCTContract;
    address payable private SCL = payable(0xFC4426A6B6b8BF052668145085eF364a2f30A34b);
    address payable RefundingCompany;
    ExchangeRate_ETH_CHF public ETHOracle = ExchangeRate_ETH_CHF(0x3673f7F2bEbDF7D0543Fe1E7bb8B0a7661bCC7FF);

    constructor (address initialOwner, address RCTAddress) payable 
        Ownable(initialOwner)
        {
            RCTContract = RCTContractInterface(RCTAddress);
            RefundingCompany = payable(initialOwner);
        }

    /**
    * @dev This function is needed that the contract can receive NFT's that have been sent by the safeTransfer function.
    */
    function onERC721Received(address, address, uint256, bytes calldata) external pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    //------------------------------Events------------------------------

    /**
    * @dev Event emitted when a refund operation succeeds.
    * @param _address, The address associated with the refund.
    * @param price, The refunded price.
    * @param date, The date of the successful refund.
    * @param companyType, The type of company involved in the refund.
    */
    event RefundSucceeded(address _address, uint40 price, uint32 date, string companyType);

    /**
    * @dev Event emitted when a refund operation fails.
    * @param _address, The address associated with the failed refund.
    * @param price, The refunded price (if any).
    * @param date, The date of the failed refund.
    * @param reason, The reason for the refund failure.
    */
    event RefundFailed(address _address, uint40 price, uint32 date, string reason);

    /**
    * @dev Event emitted when an address experiences five consecutive failed refundings.
    * @param _address The address where five consecutive failed refundings occurred.
    */
    event FiveFailedRefundings(address _address);

    /**
    * @dev Event emitted when contract balance is too low
    * @param _balance Balance of the contract.
    */
    event LoadContract(uint256 _balance);

    //------------------------------Structs------------------------------

    /**
    * @dev Employee struct representing an individual within the system.
    * @param initialized, Indicates if the employee has been initialized.
    * @param name, The name of the employee.
    * @param surname, The surname of the employee.
    * @param employeeId, The unique identifier for the employee.
    */
    struct Employee {
        bool initialized;
        string name;
        string surname;
        uint32 employeeId;
    }

    /**
    * @dev EmployeeRefunding struct containing refunding-related data for employees.
    * @param currentExpenses, The current total expenses.
    * @param currentNumberOfSucceededRefundings, The current count of successful refundings.
    * @param currentNumberOfFailedRefundings, The current count of failed refundings.
    */
    struct EmployeeRefunding {
        uint40 currentExpenses;
        uint24 currentNumberOfSucceededRefundings;
        uint24 currentNumberOfFailedRefundings;
    }

    /**
    * @dev TransportationRestriction struct defining restrictions related to transportation.
    * @param initialized, Indicates if the transportation restriction has been initialized.
    * @param isAllowed, Indicates if transportation is allowed.
    * @param price, The price associated with transportation.
    * @param firstClass, The indicator for first-class transportation.
    */
    struct TransportationRestriction {
        bool initialized;
        bool locked;
        uint40 price;
        uint8 firstClass;
    }

    /**
    * @dev FoodRestriction struct defining restrictions related to food expenses.
    * @param initialized, Indicates if the food restriction has been initialized.
    * @param isAllowed, Indicates if food expenses are allowed.
    * @param price, The total price for food expenses.
    * @param pricePerPerson, The price per person for food expenses.
    */
    struct FoodRestriction {
        bool initialized;
        bool locked;
        uint40 price;
        uint40 pricePerPerson;
    }

    /**
    * @dev AccommodationRestriction struct defining restrictions related to accommodation.
    * @param initialized, Indicates if the accommodation restriction has been initialized.
    * @param isAllowed, Indicates if accommodation is allowed.
    * @param price, The total price for accommodation.
    * @param pricePerNight, The price per night for accommodation.
    */
    struct AccommodationRestriction {
        bool initialized;
        bool locked;
        uint40 price;
        uint8 pricePerNight;
    }


    //----------------------------Mappings-------------------------------


    // mapping the address of an employee to its corresponding Data
    mapping (address => Employee) private employees;

    // mapping the address of an employee to the Refundings of this employee
    mapping (address => EmployeeRefunding) private employeeRefundings; 

    // mapping the address of an employee to the TransportationRestrictions of this employee
    mapping (address => TransportationRestriction) private transportationRestrictions;

    // mapping the address of an employee to the AccommondationRestrictions of this employee
    mapping (address => AccommodationRestriction) private accommodationRestrictions;

    // mapping the address of an employee to the FoodRestrictions of this employee
    mapping (address => FoodRestriction) private foodRestrictions;


    //----------------------------Modifier----------------------------
    modifier onlyEmployees() {

        // checking that the struct is initialized (not the default value)
        // Either the caller is a registered company or the owner himself.
        require(employees[msg.sender].initialized, "Only Employees of this company can call this Function!");
        _;
    }

    modifier onlySCL() {
        require(msg.sender == SCL, "You are not SCL!");
        _; 
    }

    
    //----------------------------HelperFunctions----------------------

    /**
    * @dev Allows SCL to set the Fee per transaction 
    * @param Fee, the Fee per transaction. The fee is mulitplied by 1000. Fee 50 => 5 % 
    */
    function setPercentageFee(uint256 Fee) external onlySCL {
        percentageFee = Fee;
    }

    // this function has to be there, so that this contract can receive ether
    receive() external payable 
    {}

   /**
    * @dev Adds new Employee to the Employees mapping 
    * @param _address, address of the Employee
    * @param _name, name of the employee  
    * @param _surname, surname of the employee 
    * @param _employeeId, employee Id of the Employee
    */
    function registerEmployee(
        address _address, 
        string memory _name, 
        string memory _surname, 
        uint32 _employeeId
        ) public onlyOwner {
        Employee memory newEmployee = Employee(true, _name, _surname, _employeeId);
        employees[_address] = newEmployee;
    }

    /**
    * @dev Returns the full name and ID of an employee 
    * @param _address, address of the Employee
    */
    function getEmployee(address _address) public view onlyOwner returns(string memory, string memory, uint32) {
        require(employees[_address].initialized == true, "This employee is not registered!");
        string memory name = employees[_address].name;
        string memory surname = employees[_address].surname;
        uint32 employeeId = employees[_address].employeeId;
        return (name, surname, employeeId);
    }

    /**
    * @dev Removes Employee from the Employees mapping
    * @param _address, the address of the employee that will be removed
    */
    function removeEmployee(address _address) public onlyOwner {
        delete employees[_address];
    }

    /**
    * @dev Getter function for the current expenses of an employee
    * @param _address, the id of the employee (Id is stored under Employees mapping)
    */
    function getExpenses(address _address) public view onlyOwner returns (uint40) {
        return employeeRefundings[_address].currentExpenses;
    }

    /**
    * @dev Getter function for the Number of the not successful refundings of an employee 
    * @param _address, the id of the employee (Id is stored under Employees mapping)
    */
    function getNumberOfSucceededRefundings(address _address) public view onlyOwner returns (uint24) {
        return employeeRefundings[_address].currentNumberOfFailedRefundings;
    }

    /**
    * @dev Setter function for the Transportation Restriction Mapping
    * @param _address, the address of the employee
    */
    function setTransportationRestriction(address _address, bool _locked, uint40 _price, uint8 _firstClass) public onlyOwner {
        TransportationRestriction memory newTransportationRestriction = TransportationRestriction(true, _locked, _price, _firstClass);
        transportationRestrictions[_address] = newTransportationRestriction;
    }

    /**
    * @dev Delete function for the Transportation Restriction Mapping
    * @param _address, the address of the employee
    */
    function deleteTransportationRestriction(address _address) public onlyOwner {
        delete transportationRestrictions[_address];
    }


    /**
    * @dev Setter function for the Food Restriction Mapping
    * @param _address, the address of the employee
    */
    function setFoodRestriction(address _address, bool _locked, uint40 _price, uint40 _pricePerPerson) public onlyOwner {
        FoodRestriction memory newFoodRestriction = FoodRestriction(true, _locked, _price, _pricePerPerson);
        foodRestrictions[_address] = newFoodRestriction;
    }

    /**
    * @dev Delete function for the Food Restriction Mapping
    * @param _address, the address of the employee
    */
    function deleteFoodRestriction(address _address) public onlyOwner {
        delete foodRestrictions[_address];
    }

    /**
    * @dev Setter function for the Accomodation Restriction Mapping
    * @param _address, the address of the employee
    */
    function setAccommodationRestriction(address _address, bool _locked, uint40 _price, uint8 _pricePerNight) public onlyOwner {
        AccommodationRestriction memory newAccommodationRestriction = AccommodationRestriction(true, _locked, _price, _pricePerNight);
        accommodationRestrictions[_address] = newAccommodationRestriction;
    }


    /**
    * @dev Delete function for the Accomodation Restriction Mapping
    * @param _address, the address of the employee
    */
    function deleteAccommodationRestriction(address _address) public onlyOwner {
        delete accommodationRestrictions[_address];
    }

    /**
    * @dev Helper function to pay the Fees to the initial companies and SCL
    * @param fees, the amount of fees
    * @param initialCompany, the address of the initial Company
    */
    function payFees(uint256 fees, address payable initialCompany) private {
        bool SCLPayed = SCL.send(fees);
        bool initialCompanyPayed = initialCompany.send(fees);
        require(SCLPayed && initialCompanyPayed, "Failed to pay the fees!");
    }

    /**
    * @dev Helper function return the balance of the contract
    */
    function returnBalance() public view returns(uint256) {
        return address(this).balance;
    }

    //----------------------------Functions----------------------------


    /**
    * @dev Initiates a refund process for a specific token (NFT) owned by an employee.
    *   The function verifies ownership of the NFT, checks the contract's balance against a minimum requirement,
    *   and handles refunding procedures based on the token's type (Transportation, Food, or Accommodation).
    *   If the refund succeeds, the employee's refunding statistics are updated accordingly.
    * @param _tokenId The ID of the token (NFT) for which a refund is initiated.
    */
    function refundToken(uint256 _tokenId) external onlyEmployees {
        require(msg.sender == RCTContract.ownerOf(_tokenId), "You are not the owner of this NFT!");
        uint256 x = uint256(1000 * 1000 * 10**18) % uint256(ETHOracle.getExchangeRate());
        uint256 requiredContractBalance = uint256(1000 * 1000 * 10**18 - x) / uint256(ETHOracle.getExchangeRate());
        if (address(this).balance < requiredContractBalance) {
            emit LoadContract(address(this).balance);
            revert("The Contract balance is too low and needs to be loaded with more ETH!");
        }

        bool refundingStatus;

        uint8 Type;
        uint32 date;
        uint40 price;
        uint8 other;

        address payable initialCompany = payable(RCTContract.getAddresses(_tokenId)[0]);
        string memory companyType; 
        (,,companyType) = RCTContract.getCompany(initialCompany);

        (Type, date, price, other,,) = RCTContract.getTokenInformation(_tokenId);

        // * 5 because first we have to get 0.05 % of the original price ( * 0.005) and then we need to multiply by 1000 because of the ETH price
        // uint256 because the fee is given in WEI. 
        uint256 mod = uint256(uint256(price) * percentageFee * 10**18) % uint256(ETHOracle.getExchangeRate());
        uint256 fees = uint256(uint256(price) * percentageFee * 10**18 - mod) / uint256(ETHOracle.getExchangeRate());


        if (Type == 0) {
            if (transportationRestrictions[msg.sender].initialized) {
                if (transportationRestrictions[msg.sender].locked) {
                    emit RefundFailed(msg.sender, price, date, "You are not allowed to hand in Transportation Refunds!");
                } else if (transportationRestrictions[msg.sender].price < price) {
                    emit RefundFailed(msg.sender, price, date, "Price of the Transportation Ticket was too high!");
                } else if (transportationRestrictions[msg.sender].firstClass < other) {
                    emit RefundFailed(msg.sender, price, date, "You are not allowed to travel first class!");
                } else {
                    refundingStatus = true;
                }
            } else {
                refundingStatus = true;
            }

        } else if (Type == 1) {
            if (foodRestrictions[msg.sender].initialized) {
                if (foodRestrictions[msg.sender].locked) {
                    emit RefundFailed(msg.sender, price, date, "You are not allowed to hand in Food Refunds!");
                } else if (foodRestrictions[msg.sender].price < price) {
                    emit RefundFailed(msg.sender, price, date, "You are not allowed to spend this much on food!");
                } else if (foodRestrictions[msg.sender].pricePerPerson < (price/other)) {
                    emit RefundFailed(msg.sender, price, date, "You are not allowed to spend this much on food per person!");
                } else {
                    refundingStatus = true;
                }
            } else {
                refundingStatus = true;
            }

        } else if (Type == 2) {
            if (accommodationRestrictions[msg.sender].initialized) {
                if (accommodationRestrictions[msg.sender].locked) {
                    emit RefundFailed(msg.sender, price, date, "You are not allowed to hand in Accomodation Refunds!");
                } else if (accommodationRestrictions[msg.sender].price < price) {
                    emit RefundFailed(msg.sender, price, date, "You are not allowed to spend this much on a Accomodation!");
                } else if (accommodationRestrictions[msg.sender].pricePerNight < (price/other)) {
                    emit RefundFailed(msg.sender, price, date, "You are not allowed to spend this much per night!");
                } else {
                    refundingStatus = true;
                }
            } else {
                refundingStatus = true;
            }
        }

        if (refundingStatus) {
            employeeRefundings[msg.sender].currentNumberOfSucceededRefundings++;
            employeeRefundings[msg.sender].currentExpenses += price;
            RCTContract.transferNFT(msg.sender, _tokenId);
            payFees(fees, initialCompany);
            emit RefundSucceeded(msg.sender, price, date, "Accomodation");
        } else {
            employeeRefundings[msg.sender].currentNumberOfFailedRefundings++;
            if (employeeRefundings[msg.sender].currentNumberOfFailedRefundings >= 5) {
            emit FiveFailedRefundings(msg.sender);
            }
        }
    }
}
