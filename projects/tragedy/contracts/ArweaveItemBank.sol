// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IItemBank {
    function getItemSVG(uint8 itemId) external pure returns (string memory);
    function getItemName(uint8 itemId) external pure returns (string memory);
}

contract ArweaveItemBank {
    IItemBank public bank1;
    IItemBank public bank2;
    
    constructor(address _bank1, address _bank2) {
        bank1 = IItemBank(_bank1);
        bank2 = IItemBank(_bank2);
    }
    
    function getItemSVG(uint8 itemId) public view returns (string memory) {
        if (itemId < 6) {
            return bank1.getItemSVG(itemId);
        } else if (itemId < 12) {
            return bank2.getItemSVG(itemId);
        }
        revert("Invalid item ID");
    }
    
    function getItemName(uint8 itemId) public view returns (string memory) {
        if (itemId < 6) {
            return bank1.getItemName(itemId);
        } else if (itemId < 12) {
            return bank2.getItemName(itemId);
        }
        revert("Invalid item ID");
    }
}