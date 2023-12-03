// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ResidentAreaContract.sol";
import "./GoverningBodyContract.sol";
import "./MemberContract.sol";
import "./ProposalContract.sol";
import "hardhat/console.sol";

contract MainContract{

    address contractManager;

    ResidentArea ResAreaInst = new ResidentArea();
    ResidentMember ResMemberInst = new ResidentMember();
    GoverningBody GovBodyInst = new GoverningBody();
    Proposal PropInst = new Proposal();


    modifier onlyAdmin(){
        require(msg.sender == contractManager, "Only the contract manager can call this function");
        _;
    }

    modifier onlyGovBodyOrAdmin(uint _resArea){
        GoverningBody.GovernBody memory GovBody = GovBodyInst.getLatestGovBody(_resArea);
        checkGovBodyMember(GovBody.members, msg.sender);
        require(checkGovBodyMember(GovBody.members, msg.sender) || (msg.sender == contractManager), "You don't belong to Governing Body");
        _;
    }

    modifier onlyResMemOrAdmin(uint _resArea, address _memAddress){
        require(bytes(ResMemberInst.getMember(_resArea, _memAddress).name).length > 0 || (msg.sender == contractManager), "You are not the member of this Resident Area");
        _;
    }

    constructor(){
        contractManager = msg.sender;
    }

    function addResArea(string memory _name) external onlyAdmin{
        ResAreaInst.addResArea(_name);
    }

    function getResArea(uint _resArea) external view onlyResMemOrAdmin(_resArea, msg.sender) returns(uint ID, string memory Name){
        ResidentArea.ResArea memory ResArea = ResAreaInst.getResArea(_resArea);
        return (ResArea.id, ResArea.name);
    }

    function addResMem(uint _resArea, string memory _name, address _memAddress) external onlyGovBodyOrAdmin(_resArea){
        ResMemberInst.addMember(_resArea, _name, _memAddress);
    }

    function getResMem(uint _resArea, address _memAddress) public view onlyGovBodyOrAdmin(_resArea) returns(uint ID, uint ResArea, string memory Name, address MemAddress){ //ResidentMember.Member memory
        ResidentMember.Member memory ResMem = ResMemberInst.getMember(_resArea, _memAddress);
        return (ResMem.id, ResMem.resArea, ResMem.name, ResMem.memAddress);
    }

    function addGovBody(uint _resArea, address[] memory _members) external onlyAdmin{
        GovBodyInst.addGovBody(_resArea, _members);
    }

    function getGovBody(uint _resArea, uint _govBodyID) external view onlyResMemOrAdmin(_resArea, msg.sender) returns(uint ID, string memory President, string memory Secretary){
        GoverningBody.GovernBody memory GovBody = GovBodyInst.getGovBody(_resArea, _govBodyID);
        string memory _pres = ResMemberInst.getMember(_resArea, GovBody.members[0]).name;
        string memory _sec = ResMemberInst.getMember(_resArea, GovBody.members[1]).name;
        return (GovBody.id, _pres, _sec);
    }

    function addBuilding(uint _resArea, string memory _name) external onlyGovBodyOrAdmin(_resArea) {
        ResAreaInst.addBuilding(_resArea, _name);
    }

    function getBuilding(uint _resArea, uint _bldgID) external view onlyResMemOrAdmin(_resArea, msg.sender) returns(uint ID, string memory Name){
        ResidentArea.Building memory Building = ResAreaInst.getBuilding(_resArea, _bldgID);
        return(Building.id, Building.name);
    }

    function addFlatShop(uint _resArea, uint _bldgID, string memory _unitFloor, string memory _unitType, address _owner) external onlyGovBodyOrAdmin(_resArea) {
        ResAreaInst.addFlatShop(_resArea, _bldgID, _unitFloor, _unitType, _owner);
    }

    function getFlatShop(uint _resArea, uint _bldgID, uint _flatShopID) external view onlyResMemOrAdmin(_resArea, msg.sender) returns(uint ID, string memory Unit_Floor, string memory UnitType, string memory Owner){
        ResidentArea.FlatShop memory FlatShop = ResAreaInst.getFlatShop(_resArea, _bldgID, _flatShopID);
        string memory _owner = ResMemberInst.getMember(_resArea, FlatShop.owner).name;
        return(FlatShop.id, FlatShop.unitFloor, FlatShop.unitType, _owner);
    }

    function addProp(uint _resArea, string memory _title, string memory _desc, Proposal.PropType _propType, uint _deadline) external onlyGovBodyOrAdmin(_resArea){
        PropInst.addProp(_resArea, _title, _desc, _propType, _deadline);
    }

    function getProp(uint _resArea, uint _propID) external view onlyResMemOrAdmin(_resArea, msg.sender) returns(uint ID, string memory Title, string memory Desc, Proposal.PropType ProposalType, uint Deadline, bool Accepted, bool Completed){
        Proposal.Prop memory Prop = PropInst.getProp(_resArea, _propID);
        return (Prop.id, Prop.title, Prop.desc, Prop.propType, Prop.deadline, Prop.accepted, Prop.completed);
    }

    function checkGovBodyMember(address[] memory _govBodyMembers, address _memAddress) public pure returns(bool){
        for(uint i = 0; i < _govBodyMembers.length; i++){
            if(_memAddress == _govBodyMembers[i]){
                return true;
            }
        }
        return false;
    }

    function voteProp(uint _resArea, uint _propID, bool _vote) external onlyResMemOrAdmin(_resArea, msg.sender) {
        Proposal.Prop memory Prop = PropInst.getProp(_resArea, _propID);
        if(Prop.propType == Proposal.PropType.General)
        {
            require(bytes(ResMemberInst.getMember(_resArea, msg.sender).name).length > 0, "Only Resident Area members are permitted to vote");
            PropInst.voteProp(_resArea, _propID, _vote, msg.sender);
        }
        else if(Prop.propType == Proposal.PropType.Special){
            GoverningBody.GovernBody memory GovBody = GovBodyInst.getLatestGovBody(_resArea);
            checkGovBodyMember(GovBody.members, msg.sender);
            require(checkGovBodyMember(GovBody.members, msg.sender), "You don't belong to Governing Body");
            PropInst.voteProp(_resArea, _propID, _vote, msg.sender);
        }
    }

    function processProp(uint _resArea, uint _propID) external onlyGovBodyOrAdmin(_resArea) {
        PropInst.processProp(_resArea, _propID);
    }
}