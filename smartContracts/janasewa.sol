//SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

contract JanaSewa{
    string public fundName;
    string public fundDescription;
    uint public fundGoal;
    uint public deadline;
    address public fundOwner;
    bool public paused;

    enum campaignState {Active, Sucessful, Failed}
    campaignState public state;

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
        state = campaignState.Active;
    }

    struct Tier{
        string name;
        uint amount;
        uint backers;
    }
    struct Backer{
        uint totalContribution;
        mapping (uint => bool) fundedTiers;
    }

    Tier[] public tiers;
    mapping(address => Backer) public backers;


    // a special type of function
    modifier onlyFundOwner(){
        require(msg.sender == fundOwner,"not the fund owner!");
        _; // runs rest of the code if the function is called by the fund owner
    }

    // modifier for campaign state handling
    modifier campaignOpen(){
        require(state == campaignState.Active, "campaign state is not acive");
        _;
    }

    modifier notPaused(){
        require(!paused, "campaign is paused!");
        _;
    }
    // funding
    function fund(uint _tierIndex) public payable campaignOpen notPaused{
        require( _tierIndex < tiers.length, "tier doesn't exists");
        require(msg.value == tiers[_tierIndex].amount, "invalid amount");
 
        tiers[_tierIndex].backers++;
        backers[msg.sender].totalContribution += msg.value;
        backers[msg.sender].fundedTiers[_tierIndex] = true;

    checkAndUpdateCampaignState();
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

function checkAndUpdateCampaignState() internal{
    if(state == campaignState.Active){
        if(block.timestamp >= deadline){
            state = address(this).balance >= fundGoal ?   campaignState.Sucessful : campaignState.Failed ;
        } else{
            state = address(this).balance >= fundGoal ?   campaignState.Sucessful : campaignState.Failed ;
        }
    }
}

    // withdrawing the fund by the owner
    function withdraw() public  onlyFundOwner{

        checkAndUpdateCampaignState();
        require(state == campaignState.Sucessful ,"campaign is not sucessful yet!");
        require(address(this).balance >= fundGoal, "Cannot withdraw fund, insufficient fund (wait till it reaches  goal)!");

        uint balance = address(this).balance;
        require(balance > 0, "no balance to withdraw");

        payable(fundOwner).transfer(balance);
    }
    // CHECK FUND BALANCE
    function checkFundBalance() public view returns(uint){
        return address(this).balance;
    }

    function refund() public {
        checkAndUpdateCampaignState();
        require(state == campaignState.Failed,"cannot refund, campaign was not failed");
        uint amount = backers[msg.sender].totalContribution;
        require(amount > 0, "no contribution to refund");

        backers[msg.sender].totalContribution = 0;
        payable(msg.sender).transfer(amount);
    }

    function hasFunded(address _backer, uint _tierIndex)public view returns(bool) {
        return backers[_backer].fundedTiers[_tierIndex];
    }

    function getTiers() public view returns(Tier[] memory){
        return tiers;
    }

    function togglePause() public onlyFundOwner{
        paused =!paused;
    }

    function getCampaignStatus() public view returns(campaignState){
        if (state == campaignState.Active && block.timestamp < deadline){
            return address(this).balance >= fundGoal? campaignState.Sucessful : campaignState.Failed;
        }
        return state;
    }

    function extendDeadline(uint daysToAdd) public onlyFundOwner campaignOpen {
        deadline += daysToAdd * 1 days;
    }

}