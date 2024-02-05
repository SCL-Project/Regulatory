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
    The VATTokenContract for Switzerland is an ERC20 (ERC20Burnable and ERC20Permit) token contract, forming an essential part of the blockchain-based VAT system. It is specifically designed for handling VAT transactions in Switzerland, ensuring seamless and secure VAT processing. The VAT payment in this contract is the basis to be able to create a receipt token. The contract's primary role is to facilitate the issuance, transfer, and management of VAT tokens, representing VAT amounts in digital form. This contract serves as a digital ledger for VAT transactions, making VAT management more efficient and transparent, particularly for cross-border transactions. Therefore the contract streamlines VAT payments and refunds and fraud scenarios in complex tax calculation scenarios and input tax deduction can be prevented.
- **Features**:
  - **Ownership and Permissions**: Utilizes Ownable and custom modifiers to ensure that only authorized entities (Swiss tax authority) can perform critical operations.
  - **Tokenization of VAT**: The contract creates a digital representation of VAT credit given by the government after a fiat transaction is made, allowing for seamless and transparent tracking of VAT payments and obligations.
  - **ERC20 Compliance**: Adheres to the ERC20 standard, ensuring compatibility with a wide range of wallets and services in the Ethereum ecosystem.
  - **Tax Payment and Refund Mechanism**: Facilitates VAT payments from businesses to the government and manages tax refunds, ensuring accurate, fast and transparent transactions with the use of the VAT rates of the Oracle.
  - **Governmental Oversight**: Empowers government entities, such as tax authority, to mint, distribute, and manage VAT tokens, ensuring regulatory compliance.
  - **Transfer Restrictions**: Implements rules to prevent unauthorized or non-compliant transfer of tokens, reinforcing the integrity of the VAT process.
  - **Buy and Sell Functionality**: Enables businesses to buy VAT tokens against their token credit and sell them back to the government, facilitating liquidity in the VAT ecosystem.
  - **Token Purchase and Redemption**: Allows companies to buy VAT tokens using their token credit and sell VAT tokens back to the government, enhancing liquidity and flexibility in VAT management.
  - **Event Logging**: The VATTokenContract for Germany incorporates event logging as a crucial feature to provide transparency and traceability in its operations. This feature is essential for auditing, regulatory compliance, and maintaining the integrity of the VAT system.
  - **Receipt Token Integration**: Integrates with the ReceiptTokenContract to access detailed transaction data of the ReceiptTokens for accurate VAT calculation and refund processing.
  - **Cross-Border Considerations**: Works with the CrossBorderContract for managing VAT in cross-border transactions, addressing VAT complexities between Switzerland and Germany.
  - **VATTokenContract Collaboration**: Works in conjunction with the VATTokenContract of Germany

### [ETHOracle](Reimbursement%20Fraud/ETHOracle.sol)
- **Purpose**: The ETHOracle contract serves as a crucial component in the blockchain-based Reimbursement system providing the ETH/CHF exchange rate to other contracts. This exchange rate is needed when other contracts calculate a precentage of a price in CHF which they intend to pay on chain in ETH. The default rate is 1927.33 where it can be updates at any time. 
- **Features**:
  - **Ownership and Permissions**: Uses Ownable and custom modifiers, ensuring operations are conducted only by authorized entities
  - **Exchange Rate Provision**: Manages and stores the exchange rate between CHF and ETH, vital for on chain transactions. This feature is critical for paying the fees in the Reimbursement system.
  - **Owner-Controlled Updates**: Designed to allow only the contract owner (a trusted third party) to update the exchange rate, maintaining the integrity and reliability of the data.

## Contributors
- <a href="https://github.com/SamuelClauss" style="text-decoration: none; color: black;">Samuel Clauss</a>

