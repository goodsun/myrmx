// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IIArweaveItemBank {
    function getItemName(uint8 id) external view returns (string);
    function getItemSVG(uint8 id) external view returns (string);
}
