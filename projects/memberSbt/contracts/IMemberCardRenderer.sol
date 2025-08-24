// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title IMemberCardRenderer
 * @notice Interface for member card SVG renderers
 * @dev Allows for swappable rendering implementations
 */
interface IMemberCardRenderer {
    /**
     * @notice Generate SVG image for a member card
     * @param tokenId The token ID
     * @param owner The owner's address
     * @param memberName The member's display name
     * @param discordId The member's Discord ID
     * @param avatarImage The member's avatar image (base64 encoded)
     * @param tokenName The name of the token collection
     * @return The generated SVG as a string
     */
    function generateSVG(
        uint256 tokenId,
        address owner,
        string memory memberName,
        string memory discordId,
        string memory avatarImage,
        string memory tokenName
    ) external pure returns (string memory);

    /**
     * @notice Get the default avatar image
     * @return The default avatar as base64 encoded data
     */
    function getDefaultAvatar() external view returns (string memory);
}