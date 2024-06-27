// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MovieTicket {
    address public owner;
    mapping(address => uint256) public ticketsOwned;
    uint256 public constant maxTicketsPerUser = 5;
    uint256 public constant ticketPrice = 1 ether;

    event TicketPurchased(address indexed buyer, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    function buyTickets(uint256 amount) external payable {
        require(amount > 0, "Amount must be greater than zero");
        require(amount <= maxTicketsPerUser, "Cannot buy more than 5 tickets at once");

        ticketsOwned[msg.sender] += amount;

        emit TicketPurchased(msg.sender, amount);
    }

    function getTicketsOwned(address user) external view returns (uint256) {
        return ticketsOwned[user];
    }

    function withdrawFunds() external {
        if (msg.sender != owner) {
            revert("Only owner can withdraw funds");
        }
        payable(msg.sender).transfer(address(this).balance);
    }

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
}
