// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IIArweaveMonsterBank {
    function getMonsterName(uint8 id) external view returns (string);
    function getMonsterSVG(uint8 id) external view returns (string);
}
