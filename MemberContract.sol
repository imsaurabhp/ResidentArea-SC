// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract ResidentMember{

    struct Member{
        uint id;
        uint resArea;
        string name;
        address memAddress;
    }

    mapping(uint => mapping(address => Member)) members;
    mapping(uint => uint) nextResMembersCount;

    function addMember(uint _resArea, string memory _name, address _memAddress) public {
        uint resMembersCount = nextResMembersCount[_resArea];
        nextResMembersCount[_resArea]++;
        Member storage newMember = members[_resArea][_memAddress];
        newMember.id = resMembersCount;
        newMember.resArea = _resArea;
        newMember.name = _name;
        newMember.memAddress = _memAddress;
    }

    function getMember(uint _resArea, address _memAddress) public view returns(Member memory){
        return members[_resArea][_memAddress];
    }
}