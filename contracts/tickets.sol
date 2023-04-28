pragma solidity ^0.8.0;

contract TicketSale {
    uint256 public ticketPrice = 1 gwei;
    uint256 public maxTotalTickets = 12;
    uint256 public maxUserTickets = 4;
    uint256 public adminGetPaiementDate;
    address public admin;
    mapping (address => bool) public isOperator;

    address[] private usersList;

    mapping(address=> uint) userTickets;
    mapping(address=> uint) userTicketsBonus;

    event TicketPurchased(address buyer, uint ticketCount);
    event OperatorAdded(address operator);
    event OperatorRemoved(address operator);
    event RefundInitiated(address receiver, uint amount);

    modifier isAdmin() {
        require(msg.sender == admin, "you are not the admin");
        _;
    }

    constructor(){
        usersList.push(0x57283B4BFa8849fD8436f461039aF6bb6c06340B);
        usersList.push(0x72406C3fdc96999337Aa25f0659e4ca0F9eBe68d);
        usersList.push(0xF7510889DC357182f6d9870AAEAFc406878FD668);
        usersList.push(0x27A2Ad5A292048B38c75d1D66cfcfebd829aD2AB);
        adminGetPaiementDate = block.timestamp + 10000;
        admin = 0x3fD652C93dFA333979ad762Cf581Df89BaBa6795;
    }

    function buyTickets(uint _ticketCount) external payable {
        require(_ticketCount > 0, "Number of tickets must be greater than zero.");
        require(block.timestamp >= adminGetPaiementDate, "Event is finish.");
        require(msg.value == _ticketCount * ticketPrice, "Incorrect payment amount.");
        require(_ticketCount <= (maxTotalTickets - totalTicketsSold()), "Not enough tickets available.");
        require(userTickets[msg.sender] + _ticketCount <= maxUserTickets, "Exceeding maximum tickets per user.");

        userTickets[msg.sender] += _ticketCount;
        emit TicketPurchased(msg.sender, _ticketCount);
    }

    function totalTicketsSold() private view returns (uint) {
        uint soldTickets = 0;
        for (uint i = 0; i < usersList.length; i++) {
            soldTickets += userTickets[usersList[i]];
        }
        return soldTickets;
    }

    function getUserTicketCount(address _user) external view returns (uint) {
        return userTickets[_user];
    }

    function getUsersWithTicket() external view returns (address[] memory) {
        uint count = 0;
        for (uint i = 0; i < usersList.length; i++) {
            if (userTickets[usersList[i]] > 0) {
                count++;
            }
        }
        address[] memory userList = new address[](count);
        count = 0;
        for (uint i = 0; i < usersList.length; i++) {
            if (userTickets[usersList[i]] > 0) {
                userList[count] = usersList[i];
                count++;
            }
        }
        return userList;
    }

    function getAdminGetPaiementDate() public view returns (uint256) {
        return adminGetPaiementDate;
    }


    function addOperator(address _operator) external isAdmin {
        require(msg.sender == admin, "Not authorized to add operator.");
        require(!isOperator[_operator], "Address is already an operator.");
        
        isOperator[_operator] = true;
        emit OperatorAdded(_operator);
    }

    function removeOperator(address _operator) external isAdmin {
        require(msg.sender == admin, "Not authorized to remove operator.");
        require(isOperator[_operator], "Address is not an operator.");

        isOperator[_operator] = false;
        emit OperatorRemoved(_operator);
    }

    function stopEvent() external isAdmin {
        require(block.timestamp > adminGetPaiementDate, "Can't stop this event.");
        adminGetPaiementDate = block.timestamp;
        requestRefund();
    }

    function requestRefund() public isAdmin {
        require(block.timestamp >= adminGetPaiementDate, "Refund not allow.");

        for (uint i = 0; i < usersList.length; i++) {
            if (userTickets[usersList[i]] > 0) {
                uint refundAmount = userTickets[usersList[i]] * ticketPrice;
                payable(usersList[i]).transfer(refundAmount);
                emit RefundInitiated(msg.sender, refundAmount);
            }
        }
    }

    function giveBonusTicket(address _user, uint _ticketNumber) external {
        require(isOperator[msg.sender] == true, "not allow");
        require(_ticketNumber <= maxUserTickets, "too much bonus tickets");
        require(_ticketNumber <= (maxUserTickets - totalBonusTicketsSold()), "Not enough tickets available.");

        userTicketsBonus[_user] += _ticketNumber;
    }

    function totalBonusTicketsSold() private view returns (uint) {
        uint soldTickets = 0;
        for (uint i = 0; i < usersList.length; i++) {
            soldTickets += userTicketsBonus[usersList[i]];
        }
        return soldTickets;
    }

    function removeBonusTicket(address _user, uint _ticketNumber) external {
        require(isOperator[msg.sender] == true, "not allow");
        require(_ticketNumber <= maxUserTickets, "too much bonus tickets");
        require(_ticketNumber <= (maxUserTickets - totalBonusTicketsSold()), "Not enough tickets available.");

        userTicketsBonus[_user] -= _ticketNumber;
    }

    function setEventDate(uint256 _newDate) external isAdmin {
        adminGetPaiementDate = _newDate;
    }
}
