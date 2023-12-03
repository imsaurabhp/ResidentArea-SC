// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./MemberContract.sol";
import "hardhat/console.sol";

contract GoverningBody{
    address public contractManager;
    

    modifier onlyContractManager() {
        require(msg.sender == contractManager, "Only the contract manager can call this function");
        _;
    }

    struct GovernBody{
        uint id;
        uint startDate;
        uint resArea;
        address[] members; // [President, Secretary, ...otherMembers];
    }

    uint nextGovBodyId = 1;

    mapping(uint => mapping(uint => GovernBody)) govBodies; // [resArea][govBody]

    function addGovBody(uint _resArea, address[] memory _members) public {
        GovernBody storage newGovBody = govBodies[_resArea][nextGovBodyId];
        newGovBody.id = nextGovBodyId;
        newGovBody.startDate = block.timestamp;
        newGovBody.resArea = _resArea;
        newGovBody.members = _members;

        nextGovBodyId++;
        console.log("New Gov Body created");
    }

    function getGovBody(uint _resArea, uint _govBodyID) public view returns(GovernBody memory){
        return govBodies[_resArea][_govBodyID];
    }

    function getLatestGovBody(uint _resArea) public view returns(GovernBody memory){
        return govBodies[_resArea][nextGovBodyId - 1];
    }
}