// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IILegendaryBank {
    function getLegendaryDescription(uint256 tokenId) external view returns (string);
    function getLegendaryTitle(uint256 tokenId) external view returns (string);
    function isLegendaryId(uint256 tokenId) external view returns (bool);
}
