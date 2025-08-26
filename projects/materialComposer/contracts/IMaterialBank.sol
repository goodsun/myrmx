// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IMaterialBank {
    struct Material {
        string name;
        string attribute;
        string image;
        bool exists;
    }

    function setMaterial(string memory materialType, uint8 id, string memory name, string memory attribute, string memory image) external;
    function getMaterial(string memory materialType, uint8 id) external view returns (string memory name, string memory attribute, string memory image);
    function materialExists(string memory materialType, uint8 id) external view returns (bool);
    function getAllMaterialIds(string memory materialType) external view returns (uint8[] memory);
    function getAllTypes() external view returns (string[] memory);
    function getTypeCount() external view returns (uint256);
}