// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract SVGGenerator {
    using Strings for uint256;

    /**
     * @dev Generate SVG with serial number overlay
     */
    function generateSVG(uint256 tokenId) public pure returns (string memory) {
        return string(abi.encodePacked(
            '<svg viewBox="0 0 400 400" xmlns="http://www.w3.org/2000/svg">',
            '<defs>',
            '<radialGradient id="purpleGlow">',
            '<stop offset="0%" style="stop-color:#9b4dff;stop-opacity:0.8"/>',
            '<stop offset="100%" style="stop-color:#9b4dff;stop-opacity:0"/>',
            '</radialGradient>',
            '<linearGradient id="textGradient" x1="0%" y1="0%" x2="100%" y2="100%">',
            '<stop offset="0%" style="stop-color:#9b4dff"/>',
            '<stop offset="50%" style="stop-color:#ff4d4d"/>',
            '<stop offset="100%" style="stop-color:#9b4dff"/>',
            '</linearGradient>',
            '<filter id="glow">',
            '<feGaussianBlur stdDeviation="2" result="coloredBlur"/>',
            '<feMerge>',
            '<feMergeNode in="coloredBlur"/>',
            '<feMergeNode in="SourceGraphic"/>',
            '</feMerge>',
            '</filter>',
            '</defs>',
            _generateBackground(),
            _generateCircles(),
            _generateSymbols(),
            _generateCenterMagicCircle(),
            _generateTexts(),
            _generateSerialNumber(tokenId),
            _generateDecorations(),
            '</svg>'
        ));
    }

    function _generateBackground() private pure returns (string memory) {
        return '<rect x="0" y="0" width="400" height="400" fill="#0a0a0a"/>';
    }

    function _generateCircles() private pure returns (string memory) {
        return string(abi.encodePacked(
            '<circle cx="200" cy="200" r="170" fill="none" stroke="#9b4dff" stroke-width="1" opacity="0.3"/>',
            '<circle cx="200" cy="200" r="160" fill="none" stroke="#9b4dff" stroke-width="2" opacity="0.5">',
            '<animate attributeName="r" values="160;164;160" dur="3s" repeatCount="indefinite"/>',
            '</circle>',
            '<circle cx="200" cy="200" r="120" fill="none" stroke="#ff4d4d" stroke-width="1" opacity="0.3" stroke-dasharray="5,5">',
            '<animateTransform attributeName="transform" type="rotate" from="0 200 200" to="360 200 200" dur="20s" repeatCount="indefinite"/>',
            '</circle>',
            '<circle cx="200" cy="200" r="140" fill="none" stroke="#9b4dff" stroke-width="1" opacity="0.2" stroke-dasharray="10,10">',
            '<animateTransform attributeName="transform" type="rotate" from="360 200 200" to="0 200 200" dur="30s" repeatCount="indefinite"/>',
            '</circle>'
        ));
    }

    function _generateSymbols() private pure returns (string memory) {
        return string(abi.encodePacked(
            '<g opacity="0.5">',
            '<path d="M 200 60 L 200 100" stroke="#9b4dff" stroke-width="2"/>',
            '<path d="M 200 300 L 200 340" stroke="#9b4dff" stroke-width="2"/>',
            '<path d="M 60 200 L 100 200" stroke="#9b4dff" stroke-width="2"/>',
            '<path d="M 300 200 L 340 200" stroke="#9b4dff" stroke-width="2"/>',
            '<path d="M 100 100 L 130 130" stroke="#ff4d4d" stroke-width="1"/>',
            '<path d="M 300 100 L 270 130" stroke="#ff4d4d" stroke-width="1"/>',
            '<path d="M 100 300 L 130 270" stroke="#ff4d4d" stroke-width="1"/>',
            '<path d="M 300 300 L 270 270" stroke="#ff4d4d" stroke-width="1"/>',
            '</g>'
        ));
    }

    function _generateCenterMagicCircle() private pure returns (string memory) {
        return string(abi.encodePacked(
            '<g transform="translate(200, 200)">',
            '<path d="M 0,-50 L 43.3,25 L -43.3,25 Z" fill="none" stroke="#9b4dff" stroke-width="1" opacity="0.4"/>',
            '<path d="M 0,50 L 43.3,-25 L -43.3,-25 Z" fill="none" stroke="#9b4dff" stroke-width="1" opacity="0.4"/>',
            '<circle cx="0" cy="0" r="30" fill="none" stroke="#ff4d4d" stroke-width="1" opacity="0.3"/>',
            _generateDragonSilhouette(),
            '</g>'
        ));
    }

    function _generateDragonSilhouette() private pure returns (string memory) {
        return string(abi.encodePacked(
            '<g opacity="0.1" transform="scale(8) translate(-12, -12)">',
            '<rect x="6" y="1" width="2" height="3" fill="#9b4dff"/>',
            '<rect x="16" y="1" width="2" height="3" fill="#9b4dff"/>',
            '<rect x="7" y="2" width="1" height="2" fill="#9b4dff"/>',
            '<rect x="16" y="2" width="1" height="2" fill="#9b4dff"/>',
            '<rect x="11" y="2" width="2" height="2" fill="#9b4dff"/>',
            '<rect x="10" y="3" width="4" height="1" fill="#9b4dff"/>',
            '<rect x="7" y="4" width="10" height="2" fill="#9b4dff"/>',
            '<rect x="5" y="6" width="14" height="4" fill="#9b4dff"/>',
            '<rect x="4" y="8" width="4" height="2" fill="#9b4dff"/>',
            '<rect x="5" y="9" width="2" height="1" fill="#9b4dff"/>',
            '<rect x="2" y="7" width="2" height="1" fill="#9b4dff"/>',
            '<rect x="1" y="6" width="2" height="1" fill="#9b4dff"/>',
            '<rect x="2" y="8" width="1" height="1" fill="#9b4dff"/>',
            '<rect x="8" y="10" width="8" height="2" fill="#9b4dff"/>',
            '<rect x="6" y="12" width="12" height="4" fill="#9b4dff"/>',
            '<rect x="7" y="16" width="10" height="3" fill="#9b4dff"/>',
            '<rect x="2" y="11" width="4" height="2" fill="#9b4dff"/>',
            '<rect x="18" y="11" width="4" height="2" fill="#9b4dff"/>',
            '<rect x="1" y="12" width="3" height="4" fill="#9b4dff"/>',
            '<rect x="20" y="12" width="3" height="4" fill="#9b4dff"/>',
            '<rect x="0" y="13" width="2" height="2" fill="#9b4dff"/>',
            '<rect x="22" y="13" width="2" height="2" fill="#9b4dff"/>',
            '<rect x="9" y="11" width="1" height="2" fill="#9b4dff"/>',
            '<rect x="12" y="11" width="1" height="2" fill="#9b4dff"/>',
            '<rect x="15" y="11" width="1" height="2" fill="#9b4dff"/>',
            '<rect x="7" y="19" width="3" height="2" fill="#9b4dff"/>',
            '<rect x="14" y="19" width="3" height="2" fill="#9b4dff"/>',
            '<rect x="6" y="21" width="1" height="2" fill="#9b4dff"/>',
            '<rect x="7" y="21" width="1" height="2" fill="#9b4dff"/>',
            '<rect x="8" y="21" width="1" height="2" fill="#9b4dff"/>',
            '<rect x="9" y="21" width="1" height="2" fill="#9b4dff"/>',
            '<rect x="14" y="21" width="1" height="2" fill="#9b4dff"/>',
            '<rect x="15" y="21" width="1" height="2" fill="#9b4dff"/>',
            '<rect x="16" y="21" width="1" height="2" fill="#9b4dff"/>',
            '<rect x="17" y="21" width="1" height="2" fill="#9b4dff"/>',
            '<rect x="17" y="17" width="3" height="2" fill="#9b4dff"/>',
            '<rect x="19" y="18" width="2" height="2" fill="#9b4dff"/>',
            '<rect x="20" y="19" width="2" height="1" fill="#9b4dff"/>',
            '<rect x="21" y="19" width="1" height="1" fill="#9b4dff"/>',
            '</g>'
        ));
    }

    function _generateTexts() private pure returns (string memory) {
        return string(abi.encodePacked(
            '<text x="200" y="120" font-family="monospace" font-size="11" text-anchor="middle" fill="#ffffff" opacity="0.6">',
            'Those who hear their whispered call',
            '</text>',
            '<text x="200" y="135" font-family="monospace" font-size="11" text-anchor="middle" fill="#ffffff" opacity="0.6">',
            'May join their number, after all.',
            '</text>',
            '<g transform-origin="200 195">',
            '<animateTransform attributeName="transform" type="scale" values="1,1; 1.05,1.05; 1,1" dur="2s" repeatCount="indefinite"/>',
            '<text x="200" y="180" font-family="monospace" font-size="24" font-weight="bold" text-anchor="middle" fill="url(#textGradient)" filter="url(#glow)">',
            'The Mythical',
            '</text>',
            '<text x="200" y="210" font-family="monospace" font-size="26" font-weight="bold" text-anchor="middle" fill="url(#textGradient)" filter="url(#glow)">',
            'Cursed-Nightmare',
            '</text>',
            '</g>',
            '<text x="200" y="240" font-family="monospace" font-size="14" text-anchor="middle" fill="#b792ff" opacity="0.9">',
            'Something dark is awakening...',
            '<animate attributeName="opacity" values="0.6;1;0.6" dur="3s" repeatCount="indefinite"/>',
            '</text>',
            '<text x="200" y="290" font-family="Impact, sans-serif" font-size="48" font-weight="900" text-anchor="middle" fill="#ffffff" stroke="#ffffff" stroke-width="2.4">',
            '10.1',
            '</text>',
            '<g transform-origin="200 320">',
            '<animateTransform attributeName="transform" type="scale" values="1,1; 1.03,1.03; 1,1" dur="2s" repeatCount="indefinite"/>',
            '<text x="200" y="320" font-family="monospace" font-size="20" font-weight="bold" text-anchor="middle" fill="#9b4dff" filter="url(#glow)">',
            'COMING SOON',
            '</text>',
            '</g>'
        ));
    }

    function _generateSerialNumber(uint256 tokenId) private pure returns (string memory) {
        return string(abi.encodePacked(
            '<rect x="150" y="340" width="100" height="30" fill="#0a0a0a" stroke="#9b4dff" stroke-width="1" opacity="0.8"/>',
            '<text x="200" y="360" font-family="monospace" font-size="14" font-weight="bold" text-anchor="middle" fill="#ffffff">',
            '#',
            tokenId.toString(),
            '</text>'
        ));
    }

    function _generateDecorations() private pure returns (string memory) {
        return string(abi.encodePacked(
            '<g>',
            '<circle cx="200" cy="60" r="3" fill="#9b4dff">',
            '<animate attributeName="opacity" values="0.3;1;0.3" dur="2s" repeatCount="indefinite"/>',
            '</circle>',
            '<circle cx="200" cy="340" r="3" fill="#9b4dff">',
            '<animate attributeName="opacity" values="0.3;1;0.3" dur="2s" begin="0.5s" repeatCount="indefinite"/>',
            '</circle>',
            '<circle cx="60" cy="200" r="3" fill="#ff4d4d">',
            '<animate attributeName="opacity" values="0.3;1;0.3" dur="2s" begin="1s" repeatCount="indefinite"/>',
            '</circle>',
            '<circle cx="340" cy="200" r="3" fill="#ff4d4d">',
            '<animate attributeName="opacity" values="0.3;1;0.3" dur="2s" begin="1.5s" repeatCount="indefinite"/>',
            '</circle>',
            '<circle cx="120" cy="120" r="2" fill="#e9d5ff" opacity="0.5">',
            '<animate attributeName="opacity" values="0.2;0.7;0.2" dur="3s" repeatCount="indefinite"/>',
            '</circle>',
            '<circle cx="280" cy="120" r="2" fill="#e9d5ff" opacity="0.5">',
            '<animate attributeName="opacity" values="0.2;0.7;0.2" dur="3s" begin="0.75s" repeatCount="indefinite"/>',
            '</circle>',
            '<circle cx="120" cy="280" r="2" fill="#e9d5ff" opacity="0.5">',
            '<animate attributeName="opacity" values="0.2;0.7;0.2" dur="3s" begin="1.5s" repeatCount="indefinite"/>',
            '</circle>',
            '<circle cx="280" cy="280" r="2" fill="#e9d5ff" opacity="0.5">',
            '<animate attributeName="opacity" values="0.2;0.7;0.2" dur="3s" begin="2.25s" repeatCount="indefinite"/>',
            '</circle>',
            '</g>',
            '<circle cx="200" cy="200" r="80" fill="url(#purpleGlow)" opacity="0.3">',
            '<animate attributeName="opacity" values="0.3;0.6;0.3" dur="3s" repeatCount="indefinite"/>',
            '</circle>',
            '<g opacity="0.2">',
            '<path d="M 200 30 L 210 50 L 190 50 Z" fill="#9b4dff">',
            '<animateTransform attributeName="transform" type="rotate" from="0 200 200" to="360 200 200" dur="60s" repeatCount="indefinite"/>',
            '</path>',
            '<path d="M 200 370 L 210 350 L 190 350 Z" fill="#9b4dff">',
            '<animateTransform attributeName="transform" type="rotate" from="0 200 200" to="360 200 200" dur="60s" repeatCount="indefinite"/>',
            '</path>',
            '<path d="M 30 200 L 50 210 L 50 190 Z" fill="#9b4dff">',
            '<animateTransform attributeName="transform" type="rotate" from="0 200 200" to="360 200 200" dur="60s" repeatCount="indefinite"/>',
            '</path>',
            '<path d="M 370 200 L 350 210 L 350 190 Z" fill="#9b4dff">',
            '<animateTransform attributeName="transform" type="rotate" from="0 200 200" to="360 200 200" dur="60s" repeatCount="indefinite"/>',
            '</path>',
            '</g>'
        ));
    }

    /**
     * @dev Generate data URI for the SVG
     */
    function generateDataURI(uint256 tokenId) public pure returns (string memory) {
        string memory svg = generateSVG(tokenId);
        string memory json = string(abi.encodePacked(
            '{"name": "Dark Narrative | The Mythical Cursed-Nightmare #',
            tokenId.toString(),
            '", "description": "Ten souls were cursed in ages past.\\nTen nightmares bound to ever last.\\n\\nNot living. Not dead.\\nWaiting.\\n\\nThey hunger still for mortal breath,\\nFor warmth of life, for peace of death.\\nBut neither shall they ever know-\\nOnly endless dark below.\\n\\nEach bears a tale of tragedy told,\\nEach carries sins from days of old.\\n\\nListen, if you dare.\\nBut know this well-\\n\\nThose who hear their whispered call\\nMay join their number, after all.", ',
            '"image": "data:image/svg+xml;base64,',
            Base64.encode(bytes(svg)),
            '", "external_url": "https://tragedy-nft.github.io/"}'
        ));

        return string(abi.encodePacked(
            "data:application/json;base64,",
            Base64.encode(bytes(json))
        ));
    }
}