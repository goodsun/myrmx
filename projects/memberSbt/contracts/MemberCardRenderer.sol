// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./IMemberCardRenderer.sol";

/**
 * @title MemberCardRenderer
 * @notice Default renderer for member card SVGs
 * @dev Implements the IMemberCardRenderer interface
 */
contract MemberCardRenderer is IMemberCardRenderer {
    string public constant DEFAULT_AVATAR = "data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyNCAyNCI+PGcgb3BhY2l0eT0iMC4yIj48cmVjdCB4PSI2IiB5PSIxIiB3aWR0aD0iMiIgaGVpZ2h0PSIzIiBmaWxsPSIjNjY2Ii8+PHJlY3QgeD0iMTYiIHk9IjEiIHdpZHRoPSIyIiBoZWlnaHQ9IjMiIGZpbGw9IiM2NjYiLz48cmVjdCB4PSI3IiB5PSIyIiB3aWR0aD0iMSIgaGVpZ2h0PSIyIiBmaWxsPSIjNjY2Ii8+PHJlY3QgeD0iMTYiIHk9IjIiIHdpZHRoPSIxIiBoZWlnaHQ9IjIiIGZpbGw9IiM2NjYiLz48cmVjdCB4PSIxMSIgeT0iMiIgd2lkdGg9IjIiIGhlaWdodD0iMiIgZmlsbD0iIzY2NiIvPjxyZWN0IHg9IjEwIiB5PSIzIiB3aWR0aD0iNCIgaGVpZ2h0PSIxIiBmaWxsPSIjNjY2Ii8+PHJlY3QgeD0iNyIgeT0iNCIgd2lkdGg9IjEwIiBoZWlnaHQ9IjIiIGZpbGw9IiM2NjYiLz48cmVjdCB4PSI1IiB5PSI2IiB3aWR0aD0iMTQiIGhlaWdodD0iNCIgZmlsbD0iIzY2NiIvPjxyZWN0IHg9IjQiIHk9IjgiIHdpZHRoPSI0IiBoZWlnaHQ9IjIiIGZpbGw9IiM2NjYiLz48cmVjdCB4PSI1IiB5PSI5IiB3aWR0aD0iMiIgaGVpZ2h0PSIxIiBmaWxsPSIjNjY2Ii8+PHJlY3QgeD0iMiIgeT0iNyIgd2lkdGg9IjIiIGhlaWdodD0iMSIgZmlsbD0iIzY2NiIvPjxyZWN0IHg9IjEiIHk9IjYiIHdpZHRoPSIyIiBoZWlnaHQ9IjEiIGZpbGw9IiM2NjYiLz48cmVjdCB4PSIyIiB5PSI4IiB3aWR0aD0iMSIgaGVpZ2h0PSIxIiBmaWxsPSIjNjY2Ii8+PHJlY3QgeD0iOCIgeT0iMTAiIHdpZHRoPSI4IiBoZWlnaHQ9IjIiIGZpbGw9IiM2NjYiLz48cmVjdCB4PSI2IiB5PSIxMiIgd2lkdGg9IjEyIiBoZWlnaHQ9IjQiIGZpbGw9IiM2NjYiLz48cmVjdCB4PSI3IiB5PSIxNiIgd2lkdGg9IjEwIiBoZWlnaHQ9IjMiIGZpbGw9IiM2NjYiLz48cmVjdCB4PSIyIiB5PSIxMSIgd2lkdGg9IjQiIGhlaWdodD0iMiIgZmlsbD0iIzY2NiIvPjxyZWN0IHg9IjE4IiB5PSIxMSIgd2lkdGg9IjQiIGhlaWdodD0iMiIgZmlsbD0iIzY2NiIvPjxyZWN0IHg9IjEiIHk9IjEyIiB3aWR0aD0iMyIgaGVpZ2h0PSI0IiBmaWxsPSIjNjY2Ii8+PHJlY3QgeD0iMjAiIHk9IjEyIiB3aWR0aD0iMyIgaGVpZ2h0PSI0IiBmaWxsPSIjNjY2Ii8+PHJlY3QgeD0iMCIgeT0iMTMiIHdpZHRoPSIyIiBoZWlnaHQ9IjIiIGZpbGw9IiM2NjYiLz48cmVjdCB4PSIyMiIgeT0iMTMiIHdpZHRoPSIyIiBoZWlnaHQ9IjIiIGZpbGw9IiM2NjYiLz48cmVjdCB4PSI5IiB5PSIxMSIgd2lkdGg9IjEiIGhlaWdodD0iMiIgZmlsbD0iIzY2NiIvPjxyZWN0IHg9IjEyIiB5PSIxMSIgd2lkdGg9IjEiIGhlaWdodD0iMiIgZmlsbD0iIzY2NiIvPjxyZWN0IHg9IjE1IiB5PSIxMSIgd2lkdGg9IjEiIGhlaWdodD0iMiIgZmlsbD0iIzY2NiIvPjxyZWN0IHg9IjciIHk9IjE5IiB3aWR0aD0iMyIgaGVpZ2h0PSIyIiBmaWxsPSIjNjY2Ii8+PHJlY3QgeD0iMTQiIHk9IjE5IiB3aWR0aD0iMyIgaGVpZ2h0PSIyIiBmaWxsPSIjNjY2Ii8+PHJlY3QgeD0iNiIgeT0iMjEiIHdpZHRoPSIxIiBoZWlnaHQ9IjIiIGZpbGw9IiM2NjYiLz48cmVjdCB4PSI3IiB5PSIyMSIgd2lkdGg9IjEiIGhlaWdodD0iMiIgZmlsbD0iIzY2NiIvPjxyZWN0IHg9IjgiIHk9IjIxIiB3aWR0aD0iMSIgaGVpZ2h0PSIyIiBmaWxsPSIjNjY2Ii8+PHJlY3QgeD0iOSIgeT0iMjEiIHdpZHRoPSIxIiBoZWlnaHQ9IjIiIGZpbGw9IiM2NjYiLz48cmVjdCB4PSIxNCIgeT0iMjEiIHdpZHRoPSIxIiBoZWlnaHQ9IjIiIGZpbGw9IiM2NjYiLz48cmVjdCB4PSIxNSIgeT0iMjEiIHdpZHRoPSIxIiBoZWlnaHQ9IjIiIGZpbGw9IiM2NjYiLz48cmVjdCB4PSIxNiIgeT0iMjEiIHdpZHRoPSIxIiBoZWlnaHQ9IjIiIGZpbGw9IiM2NjYiLz48cmVjdCB4PSIxNyIgeT0iMjEiIHdpZHRoPSIxIiBoZWlnaHQ9IjIiIGZpbGw9IiM2NjYiLz48cmVjdCB4PSIxNyIgeT0iMTciIHdpZHRoPSIzIiBoZWlnaHQ9IjIiIGZpbGw9IiM2NjYiLz48cmVjdCB4PSIxOSIgeT0iMTgiIHdpZHRoPSIyIiBoZWlnaHQ9IjIiIGZpbGw9IiM2NjYiLz48cmVjdCB4PSIyMCIgeT0iMTkiIHdpZHRoPSIyIiBoZWlnaHQ9IjEiIGZpbGw9IiM2NjYiLz48cmVjdCB4PSIyMSIgeT0iMTkiIHdpZHRoPSIxIiBoZWlnaHQ9IjEiIGZpbGw9IiM2NjYiLz48L2c+PHJlY3QgeD0iMTAiIHk9IjQiIHdpZHRoPSI0IiBoZWlnaHQ9IjIiIGZpbGw9IiM5YjRkZmYiLz48cmVjdCB4PSI4IiB5PSI2IiB3aWR0aD0iMiIgaGVpZ2h0PSIyIiBmaWxsPSIjOWI0ZGZmIi8+PHJlY3QgeD0iMTQiIHk9IjYiIHdpZHRoPSIyIiBoZWlnaHQ9IjIiIGZpbGw9IiM5YjRkZmYiLz48cmVjdCB4PSIxNCIgeT0iOCIgd2lkdGg9IjIiIGhlaWdodD0iMiIgZmlsbD0iIzliNGRmZiIvPjxyZWN0IHg9IjEyIiB5PSIxMCIgd2lkdGg9IjIiIGhlaWdodD0iMiIgZmlsbD0iIzliNGRmZiIvPjxyZWN0IHg9IjExIiB5PSIxMiIgd2lkdGg9IjIiIGhlaWdodD0iMiIgZmlsbD0iIzliNGRmZiIvPjxyZWN0IHg9IjExIiB5PSIxNCIgd2lkdGg9IjIiIGhlaWdodD0iMiIgZmlsbD0iIzliNGRmZiIvPjxyZWN0IHg9IjExIiB5PSIxOCIgd2lkdGg9IjIiIGhlaWdodD0iMiIgZmlsbD0iIzliNGRmZiIvPjxyZWN0IHg9IjExIiB5PSI1IiB3aWR0aD0iMiIgaGVpZ2h0PSIxIiBmaWxsPSIjYjc5MmZmIi8+PHJlY3QgeD0iOSIgeT0iNyIgd2lkdGg9IjEiIGhlaWdodD0iMSIgZmlsbD0iI2I3OTJmZiIvPjxyZWN0IHg9IjEyIiB5PSIxMyIgd2lkdGg9IjEiIGhlaWdodD0iMSIgZmlsbD0iI2I3OTJmZiIvPjxyZWN0IHg9IjEyIiB5PSIxOSIgd2lkdGg9IjEiIGhlaWdodD0iMSIgZmlsbD0iI2I3OTJmZiIvPjwvc3ZnPgo=";

    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

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
    ) external pure override returns (string memory) {
        // Get avatar image (use default if not set)
        string memory avatar = bytes(avatarImage).length > 0 ? avatarImage : DEFAULT_AVATAR;

        // Convert address to string (full format)
        string memory addrStr = _toHexString(uint256(uint160(owner)), 20);

        // Convert tokenId to string
        string memory tokenIdStr = _toString(tokenId);

        // Generate SVG
        return string(abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" width="600" height="600" viewBox="0 0 600 600">',
            '<defs>',
                '<linearGradient id="bg" x1="0%" y1="0%" x2="100%" y2="100%">',
                    '<stop offset="0%" style="stop-color:#000000"/>',
                    '<stop offset="100%" style="stop-color:#020f42ff"/>',
                '</linearGradient>',
                '<linearGradient id="cardGrad" x1="0%" y1="0%" x2="100%" y2="100%">',
                    '<stop offset="0%" style="stop-color:#b00"/>',
                    '<stop offset="100%" style="stop-color:#400"/>',
                '</linearGradient>',
                '<filter id="glow">',
                    '<feGaussianBlur stdDeviation="8" result="coloredBlur"/>',
                    '<feMerge>',
                        '<feMergeNode in="coloredBlur"/>',
                        '<feMergeNode in="SourceGraphic"/>',
                    '</feMerge>',
                '</filter>',
            '</defs>',
            '<rect width="600" height="600" rx="0" fill="url(#bg)"/>',
            '<rect x="20" y="145" width="560" height="310" rx="15" fill="white" opacity="0.7" filter="url(#glow)"/>',
            '<rect x="20" y="145" width="560" height="310" rx="15" fill="url(#cardGrad)"/>',

            // Left side - Avatar and basic info
            '<image x="50" y="245" width="120" height="120" href="', avatar, '" clip-path="inset(0% round 50%)"/>',

            // Vertical divider
            '<rect x="200" y="180" width="1" height="250" fill="white" opacity="0.3"/>',

            // Right side - Card info
            '<text x="390" y="200" text-anchor="middle" font-family="Arial, sans-serif" font-size="28" font-weight="bold" fill="#a33">', tokenName, '</text>',

            '<text x="240" y="260" font-family="Arial, sans-serif" font-size="14" fill="white">Token ID</text>',
            '<text x="540" y="260" text-anchor="end" font-family="Arial, sans-serif" font-size="16" font-weight="bold" fill="white">#', tokenIdStr, '</text>',

            '<text x="240" y="300" font-family="Arial, sans-serif" font-size="14" fill="white">Discord ID</text>',
            '<text x="540" y="300" text-anchor="end" font-family="Arial, sans-serif" font-size="14" fill="white">',
                bytes(discordId).length > 0 ? discordId : "Not Set",
            '</text>',

            '<text x="240" y="340" font-family="Arial, sans-serif" font-size="14" fill="white">EOA</text>',
            '<text x="540" y="340" text-anchor="end" font-family="monospace" font-size="10" fill="white">', addrStr, '</text>',

            // Bottom banner
            '<rect x="230" y="380" width="320" height="50" rx="25" fill="white" opacity="0.1"/>',
            '<text x="390" y="410" text-anchor="middle" font-family="Arial, sans-serif" font-size="16" font-weight="bold" fill="white">',
            (bytes(memberName).length > 0 ? memberName : "Anonymous"),
            '</text>',
            '</svg>'
        ));
    }

    /**
     * @notice Get the default avatar image
     * @return The default avatar as base64 encoded data
     */
    function getDefaultAvatar() external pure override returns (string memory) {
        return DEFAULT_AVATAR;
    }

    /**
     * @dev Convert uint to string
     */
    function _toString(uint256 value) private pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Convert address to hex string
     */
    function _toHexString(uint256 value, uint256 length) private pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

}