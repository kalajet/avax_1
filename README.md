# MovieTicket Smart Contract

## Overview
The `MovieTicket` contract is an Ethereum smart contract that allows users to purchase movie tickets. Each user can own a maximum of 5 tickets, and each ticket is priced at 1 ether. The contract owner can withdraw the collected funds.

## Features
- **Ticket Purchase**: Users can buy up to 5 tickets at a time.
- **Refunds**: Users can cancel their ticket purchase and receive a refund.
- **Funds Withdrawal**: The contract owner can withdraw the funds collected from ticket sales.
- **Ticket Ownership**: Users can check how many tickets they own.

## Contract Details

### State Variables
- `address public owner`: The owner of the contract.
- `mapping(address => uint256) public ticketsOwned`: Tracks the number of tickets owned by each user.
- `uint256 public constant maxTicketsPerUser`: Maximum number of tickets a user can buy (5).
- `uint256 public constant ticketPrice`: Price per ticket (1 ether).

### Events
- `event TicketPurchased(address indexed buyer, uint256 amount)`: Emitted when a user purchases tickets or cancels their purchase.

### Constructor
The constructor initializes the owner of the contract to the address that deploys the contract.

```solidity
constructor() {
    owner = msg.sender;
}
```

### Functions

#### `buyTickets(uint256 amount) external payable`
Allows users to buy tickets.
- **Parameters**: `amount` - The number of tickets to purchase.
- **Requirements**:
  - `amount` must be greater than 0.
  - `amount` must not exceed `maxTicketsPerUser`.
- **Effects**:
  - Adds the purchased amount to `ticketsOwned[msg.sender]`.
  - Emits a `TicketPurchased` event.

```solidity
function buyTickets(uint256 amount) external payable {
    require(amount > 0, "Amount must be greater than zero");
    require(amount <= maxTicketsPerUser, "Cannot buy more than 5 tickets at once");

    ticketsOwned[msg.sender] += amount;

    emit TicketPurchased(msg.sender, amount);
}
```

#### `getTicketsOwned(address user) external view returns (uint256)`
Returns the number of tickets owned by a specific user.

```solidity
function getTicketsOwned(address user) external view returns (uint256) {
    return ticketsOwned[user];
}
```

#### `withdrawFunds() external`
Allows the contract owner to withdraw the collected funds.
- **Requirements**: Only the contract owner can call this function.

```solidity
function withdrawFunds() external {
    if (msg.sender != owner) {
        revert("Only owner can withdraw funds");
    }
    payable(msg.sender).transfer(address(this).balance);
}
```

#### `cancelTicketPurchase() external`
Allows users to cancel their ticket purchase and receive a refund.
- **Effects**:
  - Sets `ticketsOwned[msg.sender]` to 0.
  - Transfers the refund amount to `msg.sender`.
  - Emits a `TicketPurchased` event with the amount set to 0.

```solidity
function cancelTicketPurchase() external {
    uint256 ticketsBought = ticketsOwned[msg.sender];
    if (ticketsBought == 0) {
        revert("You haven't purchased any tickets");
    }

    ticketsOwned[msg.sender] = 0;
    uint256 refundAmount = ticketsBought * ticketPrice;
    (bool transferSuccess, ) = payable(msg.sender).call{value: refundAmount}("");
    assert(transferSuccess); // Ensure transfer of refund succeeds

    emit TicketPurchased(msg.sender, 0);
}
```

## Usage
1. **Deploy the Contract**: Deploy the `MovieTicket` contract to the Ethereum blockchain.
2. **Purchase Tickets**: Call the `buyTickets` function with the desired amount of tickets (up to 5) and send the corresponding ether.
3. **Check Ticket Ownership**: Use the `getTicketsOwned` function to check how many tickets a user owns.
4. **Cancel Ticket Purchase**: Call the `cancelTicketPurchase` function to cancel the purchase and receive a refund.
5. **Withdraw Funds**: The contract owner can call the `withdrawFunds` function to withdraw the collected funds.

## Important Notes
- Ensure you have sufficient ether to purchase tickets.
- Only the contract owner can withdraw the funds collected from ticket sales.
- Users can cancel their ticket purchase and receive a full refund.
- The contract uses Solidity version `^0.8.0`.

## License
This contract is licensed under the MIT License.
