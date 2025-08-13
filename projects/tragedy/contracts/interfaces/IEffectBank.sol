// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IEffectBank {
    function getEffectUrl(uint8 id) external view returns (string memory);
    function getEffectName(uint8 id) external view returns (string memory);
}