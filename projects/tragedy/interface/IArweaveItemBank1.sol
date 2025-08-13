// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IArweaveItemBank1 {
    function getItemName(uint8 itemId) external pure returns (string);
    function getItemSVG(uint8 itemId) external pure returns (string);
}
