// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract MainContract {
    uint32 resAreaCount;
    address admin;
    enum UnitType {Flat, Shop}
    enum PropType {General, Special}

    struct ResArea {
        string title;
    }

    struct Member {
        uint32 resArea;
        string name;
        address memAddr;
    }

    struct Building{
        string title;
    }

    struct FlatShop{
        string unitFloor; // <----- later change to bytes32 
        UnitType isflatShop;
    }

    struct Prop{
        PropType propType;
        string title;
        string desc;
        uint acceptVotes;
        uint32 rejectVotes;
        uint deadline;
        bool accepted; // Accept = true, Reject = false
        bool completed;
    }

    mapping(uint32 => ResArea) public resAreas; 
    mapping(uint32 => mapping(address => Member)) public members; 
    mapping(uint32 => address[20]) public govBodies; // max 10 gov members 
    mapping(uint32 => mapping(uint32 => Building)) public buildings; 
    mapping(uint32 => uint8) buildingCount; // [resArea] 
    mapping(uint32 => mapping(uint8 => mapping(uint8 => FlatShop))) public flatShops; // [ResArea][Building][FlatShopCount]
    mapping(uint32 => mapping(uint8 => uint8)) FlatShopCount; // [resArea][building]
    mapping(uint32 => mapping(uint32 => Prop)) public proposals; // [resArea][PropID]
    mapping(uint32 => uint32) propCount; // [resArea] = propCount
    mapping(uint32 => mapping(uint32 => mapping(address => bool))) haveVoted; //[resArea][PropID][memAddress]

    modifier onlyAdmin(){
        require(msg.sender == admin, "Admin Only");
        _;
    }

    modifier onlyMember(uint32 _resArea){
        require(bytes(members[_resArea][msg.sender].name).length > 0, "You aren't Resident Member");
        _;
    }

    modifier onlyPresident(uint32 _resArea){
        require(msg.sender == govBodies[_resArea][0],"Only President allowed");
        _;
    }

    constructor(){
        admin = msg.sender;
    }

    function addResArea(string calldata _title) external onlyAdmin {
        resAreas[resAreaCount].title = _title;
        resAreaCount++;
    }

    function addMember(uint32 _resArea, string calldata _name, address _memAddr) external onlyPresident(_resArea){
        members[_resArea][_memAddr].resArea = _resArea;
        members[_resArea][_memAddr].name = _name;
        members[_resArea][_memAddr].memAddr = _memAddr;
    }

    function addUpdateGovBody(uint32 _resArea, address[10] calldata _memList) external onlyAdmin {
        govBodies[_resArea] = _memList;
    }

    function addBuilding(uint32 _resArea, string calldata _title) external onlyAdmin {
        buildings[_resArea][buildingCount[_resArea]].title = _title;
        buildingCount[_resArea]++;
    }

    function addFlatShop(uint32 _resArea, uint8 _bldgID, string calldata _unitFloor, UnitType _isflatShop) external onlyAdmin {
        uint8 nextUnitID = FlatShopCount[_resArea][_bldgID];
        flatShops[_resArea][_bldgID][nextUnitID].unitFloor = _unitFloor;
        flatShops[_resArea][_bldgID][nextUnitID].isflatShop = _isflatShop;
        FlatShopCount[_resArea][_bldgID]++;
    }

    function addProp(uint32 _resArea, PropType _propType, string calldata _title, string calldata _desc, uint _deadline) external onlyPresident(_resArea) {
        uint32 nextPropCount = propCount[_resArea];
        proposals[_resArea][nextPropCount].propType = _propType;
        proposals[_resArea][nextPropCount].title = _title;
        proposals[_resArea][nextPropCount].desc = _desc;
        proposals[_resArea][nextPropCount].deadline = _deadline;
        propCount[_resArea]++;
    }

    function voteProp(uint32 _resArea, uint32 _propID, bool vote) external onlyMember(_resArea){
        require(proposals[_resArea][_propID].deadline > block.timestamp, "Voting closed");
        require(!haveVoted[_resArea][_propID][msg.sender], "You have already voted");
        if(vote){
            proposals[_resArea][_propID].acceptVotes++;
        }
        else{
            proposals[_resArea][_propID].rejectVotes++;
        }
        haveVoted[_resArea][_propID][msg.sender] = true;
    }

    function processProp(uint32 _resArea, uint32 _propID) external onlyPresident(_resArea){
        require(!proposals[_resArea][_propID].completed, "Proposal already processed");
        require(proposals[_resArea][_propID].deadline < block.timestamp, "Voting ongoing");
        proposals[_resArea][_propID].completed = true;
        if(proposals[_resArea][_propID].acceptVotes > proposals[_resArea][_propID].rejectVotes){
            proposals[_resArea][_propID].accepted = true;
        }
        else{
            proposals[_resArea][_propID].accepted = false;
        }
    }
}
