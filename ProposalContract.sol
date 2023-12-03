// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import "./MemberContract.sol";

contract Proposal{

    enum PropType {General, Special}

    struct Prop{
        uint id;
        uint resArea;
        PropType propType;
        string title;
        string desc;
        uint acceptVotes;
        uint rejectVotes;
        uint deadline;
        bool accepted; // Accept = true, Reject = false
        bool completed;
    }

    mapping(uint => mapping(uint => Prop)) proposals; // [resArea][PropID]
    mapping(uint => uint) propCount; // [ResArea] Counter for Resident Area Specific
    mapping(uint => mapping(uint => mapping(address => bool))) voted; // [resArea][PropID][memAddress]

    function addProp(uint _resArea, string memory _title, string memory _desc, PropType _propType, uint _deadline) public {
        uint nextPropCount = propCount[_resArea] + 1;
        Prop storage prop = proposals[_resArea][nextPropCount];
        prop.id = nextPropCount;
        prop.resArea = _resArea;
        prop.title = _title;
        prop.desc = _desc;
        prop.propType = _propType;
        prop.deadline = _deadline;
        propCount[_resArea]++;
    }

    function getProp(uint _resArea, uint propID) public view returns(Prop memory){
        return proposals[_resArea][propID];
    }

    function voteProp(uint _resArea, uint _propID, bool vote, address voter) public {
        // ResidentMember.Member memory ResMem = ResMemberInst.getMember(_resArea, voter);
        // console.log(ResMem.resArea, _resArea, ResMem.name);
        // require(ResMem.resArea == _resArea, "You don't belong to the Resident Area");
        require(voted[_resArea][_propID][voter] == false, "You have already voted");
        Prop storage prop = proposals[_resArea][_propID];
        require(prop.deadline > block.timestamp, "Voting window has closed");
        if(vote){
            prop.acceptVotes++;
        }
        else{
            prop.rejectVotes++;
        }
        voted[_resArea][_propID][voter] = true;
    }

    function processProp(uint _resArea, uint _propID) public {
        Prop storage prop = proposals[_resArea][_propID];
        require(prop.completed == false, "Proposal is already processed");
        require(prop.deadline < block.timestamp, "Voting window is still open");
        if(prop.acceptVotes > prop.rejectVotes){
            prop.accepted = true;
        }
        else{
            prop.accepted = false;
        }
        prop.completed = true;
    }
}