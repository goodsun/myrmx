// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";

interface IFreeMintSBTWithSVG is IERC721, IERC721Metadata {
    // Events
    event SBTMinted(address indexed to, uint256 tokenId);

    // Custom Functions
    function mint() external;
    
    function hasMinted(address account) external view returns (bool);
    
    function canMint(address account) external view returns (bool);
    
    function totalSupply() external view returns (uint256);
    
    function svgGenerator() external view returns (address);
    
    // Overridden functions that revert
    function approve(address to, uint256 tokenId) external override;
    
    function setApprovalForAll(address operator, bool approved) external override;
}