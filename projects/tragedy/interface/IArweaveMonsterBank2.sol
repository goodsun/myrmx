// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IArweaveMonsterBank2 {
    function getMonsterName(uint8 monsterId) external pure returns (string);
    function getMonsterSVG(uint8 monsterId) external pure returns (string);
}
