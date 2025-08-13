// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IArweaveMonsterBank {
    function bank1() external view returns (address);
    function bank2() external view returns (address);
    function getMonsterName(uint8 monsterId) external view returns (string);
    function getMonsterSVG(uint8 monsterId) external view returns (string);
}
