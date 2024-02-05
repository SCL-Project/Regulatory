// ***************************************************************************************************************
// SPDX-License-Identifier: MIT
// @title ReceiptTokenContract
// @authors Samuel Clauss
// Smart Contracts Lab, University of Zurich
// Created: December 18, 2023
// ***************************************************************************************************************
// Read the Whitepaper https://github.com/SCL-Project/Regulatory
// ***************************************************************************************************************
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ReceiptToken is ERC721, ERC721Burnable, Ownable {

    //--------------------------Global_Variables-------------------------

    // counter for the NFT tokenId's
    uint256 private _nextTokenId;

    // string for the different CompanyTypes (check constructor for the different Types)
    string[3] public CompanyTypes;

    

    //----------------------------Constructor----------------------------


    constructor(address initialOwner) 
        ERC721("ReceiptToken", "RCT") 
        Ownable(initialOwner)
        {
            // CompanyTypes only addable in the constructor
            CompanyTypes[0] = "Transportation";
            CompanyTypes[1] = "Food";
            CompanyTypes[2] = "Accommondation";
        }

    //------------------------------Structs------------------------------

    /**
    @notice stores the Data of the corresponding ReceiptNFT
    @param The Type of the NFT, for Types see constructor
    @param The date when the transaction of the receipt took place
    @param The price of the transaction.
    @param other, is either the class / number of persons / number of nights
    */
    struct NFTData {
        uint8 tokenType;
        uint32 date;
        uint40 price;
        uint8 other;
        string companyName;
        string location;
    }


    /**
    @notice stores the information of the companies that registered for the ReceiptTokenContract
    @param initialized, helper variable. Is later used in the onlyAuthorized Modifier.
    @param Name of the company.
    @param Location of the company.
    @param The Type of the company (check constructor for the types).
    */
    struct Company {
        bool initialized;
        string name;
        string location;
        string companyType;
    }

    /**
    @notice stores the information of all the existing RefundingContracts.
    @param locked, helper variable to check whether this Refunding Contract has been blocked or not.
    @param initialized, helper variable to check whether an entry in this struct with a given address exists or not
    @param company, name of the Refunding Company
    */
    struct RefundingContract {
        bool locked;
        bool initialized;
        string company;
    }


    //----------------------------Mappings-------------------------------



    // mapping the NFTData to the corresponding TokenId
    mapping(uint256 => NFTData) private tokenInformation;

    // mapping each TokenId to all the addresses that have owned the token at one point in history (mapping will be important in a second SC)
    mapping(uint256 => address[]) private addressMap;

    // mapping the address of the registered companies to its corresponding information
    mapping(address => Company) private companies;

    // mapping the addresses of the Refunding Contracts to its corresponding Information
    mapping(address => RefundingContract) private refundingContracts;


    //----------------------------Modifier----------------------------


    // making sure that only registered Companies can mint a NFT with this contract
    modifier onlyCompanies() {

        // checking that the struct is initialized (not the default value)
        // Either the caller is a registered company or the owner himself.
        require(companies[msg.sender].initialized || msg.sender == Ownable.owner(), "Only registered Companies can call this Function!");
        _;
    }

    modifier onlyRefundingContracts() {
        require((refundingContracts[msg.sender].initialized && refundingContracts[msg.sender].locked == false) || msg.sender == Ownable.owner(), "Either non Refunding Contract or locked refunding contract!");
        _;
    }

    //----------------------------Functions----------------------------

    /**
    * @dev Gets the information of a registered company
    * @param _address, The address of the company
    * @return name, The name of the company
    * @return location, The location of the company
    * @return companyType, The type of the company
    */
    function getCompany(address _address) external view onlyRefundingContracts returns(string memory, string memory, string memory) {
        string memory name = companies[_address].name;
        string memory location = companies[_address].location;
        string memory companyType = companies[_address].companyType; 
        return (name, location, companyType);
    }

    /**
    * @dev Retrieves information about a specific token by its ID.
    * @param _id The ID of the token to retrieve information about.
    * @return tokenType The type of the token.
    * @return date The date associated with the token.
    * @return price The price of the token.
    * @return other Additional information about the token.
    * @return companyName The name of the company associated with the token.
    * @return location The location related to the token.
    */
    function getTokenInformation(uint256 _id) external view onlyRefundingContracts returns(uint8, uint32, uint40, uint8, string memory, string memory) {
        return(
            tokenInformation[_id].tokenType,
            tokenInformation[_id].date,
            tokenInformation[_id].price,
            tokenInformation[_id].other,
            tokenInformation[_id].companyName,
            tokenInformation[_id].location
        );
    } 
    
    /**
    * @dev Locks a specific refunding contract preventing further modifications.
    * @param _address The address of the refunding contract to be locked.
    */
    function lockRefundingContract(address _address) external onlyOwner {
        refundingContracts[_address].locked = true;
    }


    /**
    * @dev Unlocks a previously locked refunding contract, allowing modifications.
    * @param _address The address of the refunding contract to be unlocked.
    */
    function unlockRefundingContract(address _address) external onlyOwner {
        refundingContracts[_address].locked = false;
    }

    /**
    * @dev Gets all the addresses that once owned the specific token
    * @param _tokenId of the NFT
    * @return the array of all the addresses
    */
    function getAddresses(uint _tokenId) external onlyRefundingContracts view returns(address[] memory) {
        return addressMap[_tokenId];
    }

    /**
    * @dev Registers a new company with specified details.
    * @param _company The address of the company being registered.
    * @param _name The name of the company.
    * @param _location The location of the company.
    * @param _type The type of the company (as an index referencing the CompanyTypes array).
    */
    function registerCompany(address _company, string memory _name, string memory _location, uint8 _type) external onlyOwner {
        Company memory newCompany = Company(true, _name, _location, CompanyTypes[_type]);
        companies[_company] = newCompany;
    }

    /**
    * @dev Removes a company from the registered companies list.
    * @param _company The address of the company to be removed.
    */
    function removeCompany(address _company) external onlyOwner {
        delete companies[_company];
    }

    /**
    * @dev Registers a new refunding contract with specified details.
    * @param _contractAddress The address of the refunding contract being registered.
    * @param _name The name of the refunding contract.
    */
    function registerRefundingContract(address _contractAddress, string memory _name) external onlyOwner {
        RefundingContract memory newRefundingContract = RefundingContract(false, true, _name);
        refundingContracts[_contractAddress] = newRefundingContract;
    }

    /**
    * @dev Removes a refunding contract from the registered contracts list.
    * @param _contractAddress The address of the refunding contract to be removed.
    */
    function removeContract(address _contractAddress) external onlyOwner {
        delete refundingContracts[_contractAddress];
    }

    /**
    * @dev Helper Function. Mints a NFT, increases the NFT counter by one and returns the actual tokenId. 
    * @param _to, Address to whom the token should be minted 
    * @return The current TokenId
    */
    function safeMint(address _to) private returns(uint256) {
        uint256 tokenId = _nextTokenId++;
        _safeMint(_to, tokenId);
        return tokenId;
    } 

    /**
    * @dev Mints an NFT. (safeMint() )  , maps the corresponding data to the newly minted NFT and sends the NFT to the customer.
    * @param _to, address of the customer.
    * @param _date, date when the transaction took place
    * @param _price, price of the transaction.
    * @param _other, Any other information that might be of importance.
    */
    function createReceiptToken(address _to, uint32 _date, uint40 _price, uint8 _other) public onlyCompanies {
        uint8 Type;
        string memory companyType = companies[msg.sender].companyType;

        if (keccak256(abi.encodePacked(companyType)) == keccak256(abi.encodePacked("Transportation"))) {
            Type = 0;
        } else if (keccak256(abi.encodePacked(companyType)) == keccak256(abi.encodePacked("Food"))) {
            Type = 1;
        } else {
            Type = 2;
        }

        uint256 tokenId = safeMint(msg.sender);
        NFTData memory newNFTData = NFTData(
            Type, 
            _date, 
            _price, 
            _other, 
            companies[msg.sender].name, 
            companies[msg.sender].location
        );
        tokenInformation[tokenId] = newNFTData;
        addressMap[tokenId].push(msg.sender);
        _safeTransfer(msg.sender, _to, tokenId);
        addressMap[tokenId].push(_to);
    }

    /**
    * @dev Transfers an NFT from one address to another (used by refunding contracts).
    * @param _from The address from which the NFT is transferred.
    * @param _tokenId The ID of the token being transferred.
    */
    function transferNFT(address _from, uint256 _tokenId) external onlyRefundingContracts {
        _approve(msg.sender, _tokenId, _from);
        safeTransferFrom(_from, msg.sender, _tokenId);
        addressMap[_tokenId].push(msg.sender);
    }
}

