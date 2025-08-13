// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBankedNFT {
    event Approval(indexed address owner, indexed address approved, indexed uint256 tokenId);
    event ApprovalForAll(indexed address owner, indexed address operator, bool approved);
    event ConfigUpdated(string name, string symbol, uint256 mintFee, uint256 royaltyRate);
    event NFTBurned(indexed uint256 tokenId);
    event NFTMinted(indexed address to, indexed uint256 tokenId, indexed address creator, string metadataURI);
    event ReceivedEther(indexed address from, uint256 amount);
    event SoulBoundNFTMinted(indexed address to, indexed uint256 tokenId, indexed address creator, string metadataURI);
    event Transfer(indexed address from, indexed address to, indexed uint256 tokenId);
    event Withdrawn(indexed address owner, uint256 amount);

    function airdrop(address to) external returns (uint256);
    function airdropSoulBound(address to) external returns (uint256);
    function approve(address to, uint256 tokenId) external;
    function balanceOf(address owner) external view returns (uint256);
    function burn(uint256 tokenId) external;
    function canMint() external view returns (bool);
    function config(string newName, string newSymbol, uint256 newMintFee, uint256 newRoyaltyRate) external;
    function getApproved(uint256 tokenId) external view returns (address);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function isSoulBound(uint256 tokenId) external view returns (bool);
    function maxSupply() external view returns (uint256);
    function metadataBank() external view returns (address);
    function mint() external payable returns (uint256);
    function mintFee() external view returns (uint256);
    function mintSoulBound() external payable returns (uint256);
    function name() external view returns (string);
    function owner() external view returns (address);
    function ownerOf(uint256 tokenId) external view returns (address);
    function remainingSupply() external view returns (uint256);
    function royaltyInfo(uint256 tokenId, uint256 salePrice) external view returns (address receiver, uint256 royaltyAmount);
    function royaltyRate() external view returns (uint256);
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes data) external;
    function setApprovalForAll(address operator, bool approved) external;
    function setMetadataBank(address bankAddress) external;
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
    function symbol() external view returns (string);
    function tokenByIndex(uint256 index) external view returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);
    function tokenURI(uint256 tokenId) external view returns (string);
    function totalMinted() external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function transferFrom(address from, address to, uint256 tokenId) external;
    function withdraw() external;
}
