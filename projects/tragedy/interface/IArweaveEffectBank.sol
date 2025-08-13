// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IArweaveEffectBank {
    function effectNames(uint256) external view returns (string);
    function getEffectName(uint8 id) external view returns (string);
    function getEffectUrl(uint8 id) external view returns (string);
    function owner() external view returns (address);
    function setEffectUrl(uint8 id, string url) external;
    function setMultipleUrls(uint8[] ids, string[] urls) external;
}
