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

    struct Tier{
        string name;
        uint amount;
        uint backers;
    }

    Tier[] public tiers;

    // a special type of function
    modifier onlyFundOwner(){
        require(msg.sender == fundOwner,"not the fund owner!");
        _; // runs rest of the code if the function is called by the fund owner 
    }
    // funding 
    function fund(uint _tierIndex) public payable{
        require(block.timestamp < deadline, "cannot fund after deadline" );
        require( _tierIndex < tiers.length, "tier doesn't exists");
        require(msg.value == tiers[_tierIndex].amount, "invalid amount");

        tiers[_tierIndex].backers++;
    }


// adding fund tiers (as in different values)
    function addTier(
        string memory _name,
        uint _amount 
    )public onlyFundOwner{
        require(_amount > 0, "amount must be greater than 0");
       tiers.push(Tier(_name, _amount, 0));
    }

    function removeTier(uint _index) public{
        require(_index < tiers.length,"Tier doesn't exist");
        tiers[_index] = tiers[tiers.length -1];
        tiers.pop();
    }



    // withdrawing the fund by the owner
    function withdraw() public  onlyFundOwner{
        require(address(this).balance >= fundGoal, "Cannot withdraw fund, insufficient fund (wait till it reaches  goal)!");

        uint balance = address(this).balance;
        require(balance > 0, "no balance to withdraw");

        payable(fundOwner).transfer(balance);
    }
    // CHECK FUND BALANCE
    function checkFundBalance() public view returns(uint){
        return address(this).balance;
    }
}