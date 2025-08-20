// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IEffectBank {
    function getEffectSVG(uint8 EffectId) external view returns (string memory);
    function getEffectName(uint8 EffectId) external view returns (string memory);
}