// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./GoverningBodyContract.sol";
import "hardhat/console.sol";
import "./Library.sol";

contract ResidentArea{
    address public contractManager;
    uint256 public nextResAreaId = 1;
    uint256 public nextBuildingId = 1;
    uint256 public nextFlatShopId = 1;

    struct ResArea{
        uint256 id;
        string name;
    }

    struct Building{
        uint id;
        string name;
    }

    struct FlatShop{
        uint id;
        string unitFloor;
        string unitType;
        address owner;
    }

    mapping(uint => ResArea) public resAreas;
    mapping(uint => mapping(uint => Building)) public buildings; // [resArea][bldgID]
    mapping(uint => mapping(string => bool)) buildingNames; // [resArea][bldgName]
    mapping(uint => mapping(uint => mapping(uint => FlatShop))) public flatsShops; // [resArea][bldg][FlatShopID]

    function addResArea(string memory _name) external {
        uint resAreaId = nextResAreaId++;
        ResArea storage newResArea = resAreas[resAreaId];
        newResArea.id = resAreaId;
        newResArea.name = _name;

        // newResArea.govBody = address(new GoverningBody());
    }

    function getResArea(uint _resArea) public view returns(ResArea memory){
        return resAreas[_resArea];
    }

    function checkBuildingExist(uint _resArea, string memory _name) public returns(bool){
        if(buildingNames[_resArea][_name] == false){
            buildingNames[_resArea][_name] = true;
            return true;
        }
        else{
            return false;
        }
    }
    function addBuilding(uint _resArea, string memory _name) public {
        require(bytes(getResArea(_resArea).name).length > 0, "Resident Area does not exist");
        require(checkBuildingExist(_resArea, _name), "Building already exist in the Resident Area");
        Building storage newBuilding = buildings[_resArea][nextBuildingId];
        newBuilding.id = nextBuildingId;
        newBuilding.name = _name;
        nextBuildingId++;
    }

    function getBuilding(uint _resArea, uint _bldgID) public view returns(Building memory){
        return buildings[_resArea][_bldgID];
    }

    function addFlatShop(uint _resArea, uint _bldgID, string memory _unitFloor, string memory _unitType, address _owner) public{
        FlatShop storage newFlatShop = flatsShops[_resArea][_bldgID][nextFlatShopId];
        newFlatShop.id = nextFlatShopId;
        newFlatShop.unitFloor = _unitFloor;
        newFlatShop.unitType = _unitType;
        newFlatShop.owner = _owner;
        nextFlatShopId++;
    }

    function getFlatShop(uint _resArea, uint _bldgID, uint _flatShopID) public view returns(FlatShop memory){
        return flatsShops[_resArea][_bldgID][_flatShopID];
    }
}