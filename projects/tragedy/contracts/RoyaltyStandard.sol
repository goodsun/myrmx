// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/interfaces/IERC2981.sol";

/**
 * @title RoyaltyStandard
 * @dev Implementation of the NFT Royalty Standard (ERC-2981)
 * @notice Allows contracts to signal royalty information for NFT marketplaces
 */
abstract contract RoyaltyStandard is IERC2981 {
    struct RoyaltyInfo {
        address receiver;
        uint96 royaltyFraction;
    }

    RoyaltyInfo private _defaultRoyaltyInfo;
    mapping(uint256 => RoyaltyInfo) private _tokenRoyaltyInfo;

    /**
     * @dev Sets default royalty information for all tokens
     * @param receiver Address to receive royalties
     * @param feeNumerator Royalty fee numerator (fee = sale price * feeNumerator / 10000)
     */
    function _setDefaultRoyalty(address receiver, uint96 feeNumerator) internal virtual {
        require(feeNumerator <= 10000, "ERC2981: royalty fee will exceed salePrice");
        require(receiver != address(0), "ERC2981: invalid receiver");

        _defaultRoyaltyInfo = RoyaltyInfo(receiver, feeNumerator);
    }

    /**
     * @dev Sets royalty information for a specific token
     * @param tokenId The token ID to set royalty for
     * @param receiver Address to receive royalties for this token
     * @param feeNumerator Royalty fee numerator for this token
     */
    function _setTokenRoyalty(
        uint256 tokenId,
        address receiver,
        uint96 feeNumerator
    ) internal virtual {
        require(feeNumerator <= 10000, "ERC2981: royalty fee will exceed salePrice");
        require(receiver != address(0), "ERC2981: Invalid parameters");

        _tokenRoyaltyInfo[tokenId] = RoyaltyInfo(receiver, feeNumerator);
    }

    /**
     * @dev See {IERC2981-royaltyInfo}
     * @param tokenId The token ID to query royalty for
     * @param salePrice The sale price of the NFT
     * @return receiver The royalty recipient address
     * @return royaltyAmount The royalty payment amount
     */
    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        public
        view
        virtual
        override
        returns (address receiver, uint256 royaltyAmount)
    {
        RoyaltyInfo memory royalty = _tokenRoyaltyInfo[tokenId];

        if (royalty.receiver == address(0)) {
            royalty = _defaultRoyaltyInfo;
        }

        royaltyAmount = (salePrice * royalty.royaltyFraction) / 10000;

        return (royalty.receiver, royaltyAmount);
    }

    /**
     * @dev See {IERC165-supportsInterface}
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC2981).interfaceId;
    }
}