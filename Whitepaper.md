# Mitigating Expense Reimbursement Fraud: A Smart Contract Approach leveraging NFTs as Receipts

## Description
The Regulation Team is developing a prototype for a smart contract solution for a Receipt Reimbursement System between customers and companies. The objective of this prototype is to mitigate Reimbursement Fraud when employees hand in their receipts of business transactions to their employer. This is done by generating a digital version of a Receipt of a transaction - a ReceiptTokens (ERC721) - to ensure that each ReceiptToken can only be handed in once.


<img src="Reimbursement Fraud/Graphics/Prototype.png" width="1050"/> 

### Step 1  
The customer/employee makes a normal transaction. E.g. the customer buys a train ticket for a business trip. Additionally the customer/employee provides his wallet ID to receive the NFT afterwards.

### Step 2   
The company takes the data from the transaction (date, price, other information) and creates an NFT, a ReceiptToken with it. 

### Step 3
The ReceiptToken is being sent to the Customer/Employee. This will be done automatically in the process of creating the ReceiptToken.

### Step 4
The customer/employee sends the ReceiptToken to the refunding contract of his employer. 

### Step 5 
The refunding contract of the employer checks the ReceiptToken of the employee whether if it is valid or not. When the token is valid, it continues with Step 6. Otherwise an error message is being triggered and the refunding payment is not being released.

### Step 6   
Finally, when the token has been accepted, the employee is being refunded. Additionally the initial company, the one that created the ReceiptToken and SCL as the solution provider are getting payed a small percentage of the ReceiptTokens price as a fee.

## Smart Contracts
### [ReceiptTokenContract](Reimbursement%20Fraud/ReceiptTokenContract.sol)
- **Purpose**:
    The ReceiptTokenContract is an ERC721 contract, designed to tokenize real world transactions. Each Token represents the receipt of such an transaction that can at some later point in time be sent to a refunding contract. Furthermore, each Token is unique and carries all the important data concerning the transaction such as e.g. the price or the date of the transaction.
- **Features**:
  - **Ownership and Permissions**: Uses Ownable and custom modifiers, ensuring operations are conducted only by authorized entities
  - **Refunding and Company Structs**: Defines structured data for refunding contracts and registered companies.
  - **ERC721 Compliance**: Inherits from ERC721, providing standard functionality for creating and managing non-fungible tokens (NFTs).
  - **Tokenization of Receipts**: Creates a digital representation of receipts in the form of ERC721 tokens.
    Tokens represent different types of transactions (e.g., transportation, food, accommodation).
  - **Company Registration**: Allows registration of companies with specific details, such as name, location, and type.
  - **Refunding Contract Registration**: Enables the registration of refunding contracts with specific details, including whether a contract is locked.
  - **Transfer of Receipt Tokens**:  Supports the transfer of receipt tokens between addresses, including from companies to refunding contracts. Maintains a record of addresses that have owned the token at different points in history.
  - **Locking/Unlocking Refunding Contracts**: Allows the contract owner to lock and unlock refunding contracts, controlling their ability to modify data. Enhances security and prevents unauthorized modifications during specific periods.
  - **Event Logging**: Logs important events within the contract, ensuring transparency and traceability for auditing purposes. Events include the registration of companies, removal of companies, registration of refunding contracts, and removal of refunding contracts.




### [ReceiptTokenRefundingContract](Reimbursement%20Fraud/ReceiptTokenRefundingContract.sol)
- **Purpose**:
This Solidity smart contract is named "ReceiptTokenRefunding" and serves as a mechanism for refunding expenses associated with specific NFTs representing receipts. It is designed to be used by a company or organization to manage and automate the refunding process for various types of expenses such as transportation, food, and accommodation.
- **Features**:
  - **Ownership and Permissions**: Utilizes Ownable and custom modifiers to ensure that only authorized entities (Swiss tax authority) can perform critical operations.
  - **Employee Management**: The contract provides functions to register, remove, and retrieve information about employees, including their name, surname, and employee ID.
  - **Refunding Statistics**: Tracks and updates refunding statistics for each employee, including the total expenses, the number of successful refundings, and the number of failed refundings.
  - **Expense Restrictions**: Allows the company to set and manage restrictions on expenses, such as maximum amounts allowed for each category and additional conditions for first-class travel, per-person food expenses, and per-night accommodation expenses.
  - **Fee Calculation**: Automatically calculates and deducts fees (0.05% of the original expense) from the refund amount. These fees are distributed to the initial company and SCL.
  - **Oracle Integration**: Utilizes an Ethereum to Swiss Franc exchange rate oracle (ExchangeRate_ETH_CHF) to calculate fees based on the current exchange rate.
  - **Withdrawal of Funds**: Provides a function for the refunding company to withdraw funds from the contract.
  - **Event Logging**: Emits events for successful and failed refund operations, as well as events for cases where an employee experiences five consecutive failed refund attempts.

### [ETHOracle](Reimbursement%20Fraud/ETHOracle.sol)
- **Purpose**: The ETHOracle contract serves as a crucial component in the blockchain-based Reimbursement system providing the ETH/CHF exchange rate to other contracts. This exchange rate is needed when other contracts calculate a precentage of a price in CHF which they intend to pay on chain in ETH. The default rate is 1927.33 where it can be updates at any time. 
- **Features**:
  - **Ownership and Permissions**: Uses Ownable and custom modifiers, ensuring operations are conducted only by authorized entities
  - **Exchange Rate Provision**: Manages and stores the exchange rate between CHF and ETH, vital for on chain transactions. This feature is critical for paying the fees in the Reimbursement system.
  - **Owner-Controlled Updates**: Designed to allow only the contract owner (a trusted third party) to update the exchange rate, maintaining the integrity and reliability of the data.

## Contributors
- <a href="https://github.com/SamuelClauss" style="text-decoration: none; color: black;">Samuel Clauss</a>

