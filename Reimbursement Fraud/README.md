# Regulation (Current Research)

## Prototype to mitigate Reimbursement Fraud when handing in expenses
- **Scope:** Companies primarily in Switzerland

The objective of this prototype is to prevent or mitigate Reimbursement Fraud and to enhance the security and transparency for the reimbursement of expenses by using NFT's as Receipt tokens. 
## Overview
### Smart Contracts
#### [ReceiptTokenContract](ReceiptTokenContract.sol): Creates ReceiptTokens for the clients / employees of the refunding company
#### [ReceiptTokenRefundingContract](ReceiptTokenRefundingContract.sol): Contract of the refunding company to refund the Receipt Tokens
#### [RCTContractInterface](RCTContractInterface.sol): Interface of the ReceiptTokenContract
#### [ETHOracle](ETHOracle.sol): Contract to similate an oracle for the exchange rate of CHF / ETH

### NatSpec Format
- **[Solidity Documention](https://docs.soliditylang.org/en/latest/natspec-format.html)**
- **@title:** Title of the contract
- **@authors:** Authors of the contract
- **@dev:** Explains to the end user all extra details (inlcudes @notice to safe space)
- **@param:** documents a parameter
- **@return:** documents the retunr variables of a contract's function

### Audience
- **Companies** (especially companies with high reimbursement Fraud)
- **Students & Researchers**

### Assumptions
- Deployment on polygon blockchain (because of the lower fees compared to ethereum): Assumption of integrity of the blockchain data
- a large number of companies participating in this system
- No collaboration between the Receipt Issuing Company and the Customer (otherwise the company could hand fraudulent Receipts to the Customer)

### Open Issues
- To create a real Oracle for the exchange rate of CHF / ETH
- Creating an Application with a frontend so that users can easely interact with the Smart Contracts.
- Integration of different Company types

## Installation to Compile, Deploy & Interact with the Contracts

To interact with the `ReceiptTokenContract`, `ReceiptTokenRefundingContract`, `RCTContractInterface` and `ETHOracle` in Remix, follow these steps:
### 1. Open Remix IDE
   - Go to [Remix Ethereum IDE](https://remix.ethereum.org/).

### 2. Create the Contract Files
   - In the File Explorer pane of Remix, create new files for each contract.
   - Copy and paste the Solidity code of each respective contract into these files.

### 3. Compile the Contracts
   - Go to the Solidity Compiler tab and select the appropriate compiler version (e.g., `0.8.20`).
   - Click the 'Compile' button for each contract file.

### 4. Deploy the Contracts
   - Switch to the 'Deploy & Run Transactions' tab.
   - Connect to your chosen Ethereum environment use the 'Injected Environment' dropdown. (Your metamask wallet must be connected to the Sepolia Network)
   - Select the contract you wish to deploy from the 'Contract' dropdown.
   - Enter any necessary constructor parameters
   - Click 'Deploy' to deploy each contract. 
   - After deployment, the contracts will appear in the 'Deployed Contracts' section at the bottom of the panel.

#### 5 Order of Deployment
Follow this sequence for deploying your contracts:
  1. `ReceiptToken`
  2. `ReceiptTokenRefunding` (with the Contract Address of the ReceiptTokenContract)
  
#### 6 Further Steps
Complete the setup with the following actions:
  1. Call the `registerCompany` function in the `ReceiptToken` contract to register a company that participates in the system
  1. Call the `registerRefundingContract` function in the `ReceiptToken` contract to register a refunding contract that participates in the system
  3. To create ReceiptTokens, the registered company has to call the `createReceiptToken` function in the `ReceiptToken` contract. This will create the Receipt Token and send the NFT to the customer/employee
  4. Call the `registerEmployee` function in the `ReceiptTokenRefunding` contract to register the employee
  5. OPTIONAL: call the set...Restriction function in the in the `ReceiptTokenRefunding` contract to set restrictions for the registered employee
  6. To do the refunding, the employee has to call the `refundToken` function in the `ReceiptTokenRefunding` contract with its token ID.

### 7. Interact with the Contracts
   - In the 'Deployed Contracts' section, you can interact with each contract's functions.
   - Use the provided fields and buttons to call functions of the contract, such as creating or refunding tokens.

### Contributions
🌟 Your Contributions are valued in the Reimbursement Fraud Repository! 🌟  
If you have any ideas, suggestions, or bug reports, please open an issue or submit a pull request.

### Contributors
- <a href="https://github.com/SamuelClauss" style="text-decoration: none; color: black;">Samuel Clauss</a>
