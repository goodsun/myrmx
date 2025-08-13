// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IIArweaveEffectBank {
    function getEffectName(uint8 id) external view returns (string);
    function getEffectUrl(uint8 id) external view returns (string);
}
