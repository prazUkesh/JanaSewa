//SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

contract JanaSewa{
    string public fundName;
    string public fundDescription;
    uint public fundGoal;
    uint public deadline;
    address public fundOwner;
    
    constructor(
        string memory _fundName,
        string memory _fundDescription,
        uint256  _fundGoal,
        uint256  _durationInDays
    ){
        fundName = _fundName;
        fundDescription = _fundDescription;
        fundGoal = _fundGoal;
        deadline = block.timestamp + ( _durationInDays * 1 days);
        fundOwner = msg.sender;
    }

    // funding 
    function fund() public payable{
        require(block.timestamp < deadline, "Cannot fund!campaign deadline has came to an end");
        require(msg.value > 0, "Cannot fund value less than 0!");
    }

    // withdrawing the fund by the owner
    function withdraw() public {
        require(msg.sender == fundOwner, "Fund can only be withdrawn by the Fund Owner!");
        require(address(this).balance >= fundGoal, "Cannot withdraw fund, insufficient fund (wait till it reaches  goal)!");

        uint balance = address(this).balance;
        require(balance > 0, "no balance to withdraw");

        payable(fundOwner).transfer(balance);
    }

    function checkFundBalance() public view returns(uint){
        return address(this).balance;
    }
}