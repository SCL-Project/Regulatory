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
    The ReceiptTokenContract is an ERC721 contract integral to our blockchain-based VAT system, designed to tokenize buying and selling transactions. It aims to ensure transparent and immutable transaction records, significantly reducing VAT fraud potential. This contract is crucial in digitizing receipts and VAT records, ensuring each transaction is accurately and securely documented on the blockchain, including details about goods or services. It is invaluable for tracking and auditing, providing a reliable and efficient means of managing VAT-related information. It allows owners to present receipts to tax authorities and transport goods across borders transparently and legally.
- **Features**:
  - **Ownership and Permissions**: Utilizes Ownable and therefore only one central authority of Switzerland and Germany can perform critical operations.
  - **Tokenization of Transactions**: Issues ERC721 tokens (NFTs) to represent individual transactions, ensuring a unique and tamper-proof record of each sale and purchase.
  - **Seller and Buyer Tokens**: Differentiates between tokens issued to sellers and buyers, encapsulating the details of each party's involvement in the transaction.
  - **Twin-Token ID**: The contract incorporates a unique twin-token ID mechanism to link the buyer and seller token.
  - **Receipt and Company Structs**: Defines structured data for receipt tokens and registered companies, encompassing essential transaction and entity details.
  - **VAT Calculation and Recording**: Calculates VAT based on transaction values and stores this information within each token, streamlining the tax recording process.
  - **Enhanced Transparency in Supply Chains**: Tracks and records the usage of products to produce further processed goods in supply chains, contributing to greater transparency and accountability.
  - **Secure Company Registration and Management**: Manages the registration of companies, ensuring that only authorized entities can create receipt tokens.
  - **Cross-Border Functionality**: Coordinates with the CrossBorderContract for international transactions, handling different VAT rates and regulations.
  - **VATToken Functionality**: Interacts with VATToken_DE and VATToken_CH for specific regional VAT handling, and integrates with an Oracle contract for dynamic VAT rate and currency information.
  - **Used Product Tracking**: Records the percentage of used products in further processed goods, aiding in VAT refund claims and supply chain management and transparency.
  - **Events for Token Creation and Chain End**: Emits events for new token creation and signaling the end of a supply chain, adding to the system's  traceability.

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
- **Purpose**:
    The VATTokenContract for Germany, an ERC20 (ERC20Burnable and ERC20Permit) token contract, is a crucial part of the blockchain-based VAT system, tailored for VAT transactions in Germany. Its design ensures seamless VAT processing within the German context. It operates exactly the same as the VATTokenContract of Switzerland.
- **Features**:
  - **Ownership and Permissions**: Uses Ownable and custom modifiers, ensuring operations are conducted only by authorized entities


### [RCTContractInterface](Reimbursement%20Fraud/RCTContractInterface.sol)
- **Purpose**:
    The CrossBorderContract plays a crucial role in managing cross-border transactions within the VAT system. It is designed to automate and streamline the VAT adjustments for products and services that cross borders. The primary goal is to simplify the complex tax implications of cross-border commerce, ensuring compliance with different VAT rates and regulations. This contract is essential for reducing administrative burdens, mitigating VAT fraud, and fostering a more transparent international trade environment.
- **Features**:
  - **Multi-Government Accessibility**: Designed to be operated by multiple government entities (Switzerland & Germany, reflecting the collaborative nature of international trade.
  - **Automated VAT Adjustment**: Calculates and settles tax differences based on varying VAT rates of countries involved in the transaction.
  - **Ownership Verification**: Ensures that the caller of the function is the rightful owner of the token representing the product being exported.
  - **Legal Export Check**: Verifies that the product can be legally exported and imported, adhering to international trade regulations.
  - **VAT Rate Management**: Uses an Oracle allowing for dynamic tax calculations.
  - **Forbidden Goods Handling**: Manages a list of goods that are forbidden from export or import, enhancing regulatory compliance.
  - **Cross-Border Tax Settlements**: Adjusts VAT payments in accordance with the destination country's tax rate using the data of the Oracle, handling both tax credits and additional tax requirements.
  - **Event Logging for Cross-Border Movements**: Records details of items crossing borders, including origin, destination, and token ID, for transparency and tracking.
  - **Integration with VATToken and ReceiptTokenContract**: Works in conjunction with VATTokenContract for tax payments and ReceiptTokenContract for validating transaction details.

## Contributors
- <a href="https://github.com/SamuelClauss" style="text-decoration: none; color: black;">Samuel Clauss</a>

