// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IArweaveBackgroundBank {
    function backgroundNames(uint256) external view returns (string);
    function getBackgroundName(uint8 id) external view returns (string);
    function getBackgroundUrl(uint8 id) external view returns (string);
    function owner() external view returns (address);
    function setBackgroundUrl(uint8 id, string url) external;
    function setMultipleUrls(uint8[] ids, string[] urls) external;
}
