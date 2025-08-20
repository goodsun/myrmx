// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IBackgroundBank {
    function getBackgroundSVG(uint8 BackgroundId) external view returns (string memory);
    function getBackgroundName(uint8 BackgroundId) external view returns (string memory);
}