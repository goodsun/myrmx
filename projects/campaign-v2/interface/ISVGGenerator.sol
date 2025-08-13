// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ISVGGenerator {
    function generateDataURI(uint256 tokenId) external pure returns (string);
    function generateSVG(uint256 tokenId) external pure returns (string);
}
