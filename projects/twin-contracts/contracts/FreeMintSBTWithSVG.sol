// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./SVGGenerator.sol";

contract FreeMintSBTWithSVG is ERC721, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    SVGGenerator public immutable svgGenerator;

    // Mapping to track if an address has already minted
    mapping(address => bool) public hasMinted;

    // Event emitted when an SBT is minted
    event SBTMinted(address indexed to, uint256 tokenId);

    constructor(
        string memory name,
        string memory symbol
    ) ERC721(name, symbol) Ownable() {
        svgGenerator = new SVGGenerator();
        _tokenIdCounter.increment(); // Start token IDs at 1
    }

    /**
     * @dev Mint a free SBT. Each EOA can only mint once.
     */
    function mint() external {
        require(tx.origin == msg.sender, "Contracts cannot mint");
        require(!hasMinted[msg.sender], "Already minted");

        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();

        hasMinted[msg.sender] = true;
        _safeMint(msg.sender, tokenId);

        emit SBTMinted(msg.sender, tokenId);
    }

    /**
     * @dev Override transfer functions to make tokens non-transferable (Soul Bound)
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override {
        // Allow minting and burning, but not transfers
        require(
            from == address(0) || to == address(0),
            "SBT: Transfer not allowed"
        );

        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    /**
     * @dev Returns the token URI with dynamically generated SVG
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireMinted(tokenId);
        return svgGenerator.generateDataURI(tokenId);
    }

    /**
     * @dev Check if an address has already minted
     */
    function canMint(address account) external view returns (bool) {
        return !hasMinted[account] && tx.origin == account;
    }

    /**
     * @dev Get total supply of minted tokens
     */
    function totalSupply() external view returns (uint256) {
        return _tokenIdCounter.current() - 1;
    }

    /**
     * @dev Explicitly disable approve functions for SBT
     */
    function approve(address, uint256) public pure override {
        revert("SBT: Approve not allowed");
    }

    function setApprovalForAll(address, bool) public pure override {
        revert("SBT: Approve not allowed");
    }
}