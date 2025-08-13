// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IBackgroundBank {
    function getBackgroundUrl(uint8 id) external view returns (string memory);
    function getBackgroundName(uint8 id) external view returns (string memory);
}