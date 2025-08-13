// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IArweaveItemBank {
    function bank1() external view returns (address);
    function bank2() external view returns (address);
    function getItemName(uint8 itemId) external view returns (string);
    function getItemSVG(uint8 itemId) external view returns (string);
}
