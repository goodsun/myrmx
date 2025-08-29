// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./banks/ItemBank1.sol";
import "./banks/ItemBank2.sol";

contract ItemBank {
    ItemBank1 public immutable itemBank1;
    ItemBank2 public immutable itemBank2;

    constructor(address _itemBank1, address _itemBank2) {
        itemBank1 = ItemBank1(_itemBank1);
        itemBank2 = ItemBank2(_itemBank2);
    }

    function getItemSVG(uint8 itemId) external view returns (string memory) {
        if (itemId < 5) {
            return itemBank1.getItemSVG(itemId);
        } else {
            return itemBank2.getItemSVG(itemId);
        }
    }

    function getItemName(uint8 itemId) external view returns (string memory) {
        if (itemId < 5) {
            return itemBank1.getItemName(itemId);
        } else {
            return itemBank2.getItemName(itemId);
        }
    }
}