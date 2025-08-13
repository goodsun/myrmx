// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IFreeMintSBTWithSVG {
    event Approval(indexed address owner, indexed address approved, indexed uint256 tokenId);
    event ApprovalForAll(indexed address owner, indexed address operator, bool approved);
    event OwnershipTransferred(indexed address previousOwner, indexed address newOwner);
    event SBTMinted(indexed address to, uint256 tokenId);
    event Transfer(indexed address from, indexed address to, indexed uint256 tokenId);

    function approve(address, uint256) external pure;
    function balanceOf(address owner) external view returns (uint256);
    function canMint(address account) external view returns (bool);
    function getApproved(uint256 tokenId) external view returns (address);
    function hasMinted(address) external view returns (bool);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function mint() external;
    function name() external view returns (string);
    function owner() external view returns (address);
    function ownerOf(uint256 tokenId) external view returns (address);
    function renounceOwnership() external;
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes data) external;
    function setApprovalForAll(address, bool) external pure;
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
    function svgGenerator() external view returns (address);
    function symbol() external view returns (string);
    function tokenURI(uint256 tokenId) external view returns (string);
    function totalSupply() external view returns (uint256);
    function transferFrom(address from, address to, uint256 tokenId) external;
    function transferOwnership(address newOwner) external;
}
