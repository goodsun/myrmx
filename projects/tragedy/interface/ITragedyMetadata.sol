// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ITragedyMetadata {
    function SHUFFLE_SEED() external view returns (uint256);
    function composer() external view returns (address);
    function decodeTokenId(uint256 tokenId) external pure returns (uint8 species, uint8 background, uint8 item, uint8 effect);
    function generateMetadata(uint256 tokenId, uint8 species, uint8 background, uint8 item, uint8 effect) external view returns (string);
    function getMetadata(uint256 index) external view returns (string);
    function getMetadataCount() external pure returns (uint256);
    function legendaryBank() external view returns (address);
}
