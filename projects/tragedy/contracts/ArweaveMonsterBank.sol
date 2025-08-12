// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IMonsterBank {
    function getMonsterSVG(uint8 monsterId) external pure returns (string memory);
    function getMonsterName(uint8 monsterId) external pure returns (string memory);
}

contract ArweaveMonsterBank {
    IMonsterBank public bank1;
    IMonsterBank public bank2;
    
    constructor(address _bank1, address _bank2) {
        bank1 = IMonsterBank(_bank1);
        bank2 = IMonsterBank(_bank2);
    }
    
    function getMonsterSVG(uint8 monsterId) public view returns (string memory) {
        if (monsterId < 5) {
            return bank1.getMonsterSVG(monsterId);
        } else if (monsterId < 10) {
            return bank2.getMonsterSVG(monsterId);
        }
        revert("Invalid monster ID");
    }
    
    function getMonsterName(uint8 monsterId) public view returns (string memory) {
        if (monsterId < 5) {
            return bank1.getMonsterName(monsterId);
        } else if (monsterId < 10) {
            return bank2.getMonsterName(monsterId);
        }
        revert("Invalid monster ID");
    }
}