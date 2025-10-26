// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.12;

import {JanaSewa} from "./JanaSewa.sol";

contract JanaSewaFactory{
    address public owner;
    bool public paused;

    struct Campaign{
        address CampaignAddress;
        address owner;
        string name;
        uint256 creationTime;
    }
    
    Campaign[] public campaigns;
    mapping(address => Campaign[]) public userCampaigns;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    modifier notPaused() {
        require(!paused, "Factory is paused.");
        _;
    }

    constructor(){
        owner = msg.sender;
    }

    function createCampaign(
        string memory _name,
        string memory _description,
        uint256 _goal,
        uint256 _durationInDays
    ) external notPaused {

        JanaSewa newCampaign = new JanaSewa(
            msg.sender,
            _name,
            _description,
            _goal,
            _durationInDays
        );

        address campaignAddress = address(newCampaign);
        Campaign memory campaign = Campaign({
            CampaignAddress: campaignAddress,
            owner: msg.sender,
            name : _name,
            creationTime: block.timestamp
        });

        campaigns.push(campaign);
        userCampaigns[msg.sender].push(campaign);
    }

    function getUserCampaigns(address _user) external view returns(Campaign[] memory){
        return  userCampaigns[_user];
    }

    function getAllCampaigns() external view returns(Campaign[] memory){
        return campaigns;
    }

    function togglePause() external onlyOwner {
        paused = !paused;
    }
    
}