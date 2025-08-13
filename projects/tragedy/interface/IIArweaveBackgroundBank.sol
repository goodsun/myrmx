// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IIArweaveBackgroundBank {
    function getBackgroundName(uint8 id) external view returns (string);
    function getBackgroundUrl(uint8 id) external view returns (string);
}
