// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./libraries/Base64.sol";
import "./ArweaveMonsterBank.sol";
import "./ArweaveBackgroundBank.sol";
import "./ArweaveItemBank.sol";
import "./ArweaveEffectBank.sol";

interface IArweaveMonsterBank {
    function getMonsterSVG(uint8 id) external view returns (string memory);
    function getMonsterName(uint8 id) external view returns (string memory);
}

interface IArweaveBackgroundBank {
    function getBackgroundUrl(uint8 id) external view returns (string memory);
    function getBackgroundName(uint8 id) external view returns (string memory);
}

interface IArweaveItemBank {
    function getItemSVG(uint8 id) external view returns (string memory);
    function getItemName(uint8 id) external view returns (string memory);
}

interface IArweaveEffectBank {
    function getEffectUrl(uint8 id) external view returns (string memory);
    function getEffectName(uint8 id) external view returns (string memory);
}

/**
 * @title ArweaveTragedyComposerV5
 * @notice Composes SVGs with synergy-based item transformations
 * @dev Transforms Amulet(9)->Head(10) and Shoulder(8)->Arm(11) during synergies
 */
contract ArweaveTragedyComposer {
    IArweaveMonsterBank public monsterBank;
    IArweaveBackgroundBank public backgroundBank;
    IArweaveItemBank public itemBank;
    IArweaveEffectBank public effectBank;
    
    // Filter parameters for each background
    mapping(uint8 => uint16[3]) private _filterParams;
    
    constructor(
        address _monsterBank,
        address _backgroundBank,
        address _itemBank,
        address _effectBank
    ) {
        monsterBank = IArweaveMonsterBank(_monsterBank);
        backgroundBank = IArweaveBackgroundBank(_backgroundBank);
        itemBank = IArweaveItemBank(_itemBank);
        effectBank = IArweaveEffectBank(_effectBank);
        
        // Initialize color filters based on DESIGN.md
        _initializeFilterParams();
    }
    
    function _initializeFilterParams() private {
        // Bloodmoon - red tones
        _filterParams[0] = [uint16(0), uint16(120), uint16(100)];    // hue=0 (red), high saturation
        
        // Abyss - deep blue
        _filterParams[1] = [uint16(240), uint16(100), uint16(80)];   // hue=240 (blue), dark
        
        // Decay - sickly green
        _filterParams[2] = [uint16(90), uint16(80), uint16(70)];     // hue=90 (yellow-green), desaturated
        
        // Corruption - purple
        _filterParams[3] = [uint16(270), uint16(100), uint16(90)];   // hue=270 (purple)
        
        // Venom - pink-purple
        _filterParams[4] = [uint16(300), uint16(100), uint16(100)];  // hue=300 (magenta)
        
        // Void - dark purple
        _filterParams[5] = [uint16(260), uint16(60), uint16(50)];    // hue=260 (dark purple), very dark
        
        // Inferno - flame colors
        _filterParams[6] = [uint16(20), uint16(150), uint16(120)];   // hue=20 (orange), oversaturated
        
        // Frost - ice blue
        _filterParams[7] = [uint16(195), uint16(100), uint16(110)];  // hue=195 (cyan), bright
        
        // Ragnarok - golden
        _filterParams[8] = [uint16(45), uint16(120), uint16(110)];   // hue=45 (gold), bright
        
        // Shadow - grayscale
        _filterParams[9] = [uint16(0), uint16(0), uint16(70)];       // no hue, desaturated, dark
    }
    
    function composeSVG(
        uint8 species, 
        uint8 background, 
        uint8 item, 
        uint8 effect
    ) external view returns (string memory) {
        // Check for synergies that transform items
        uint8 displayItem = getDisplayItem(species, item);
        
        return composeSVGWithSynergy(species, background, displayItem, effect);
    }
    
    function composeSVGWithSynergy(
        uint8 species, 
        uint8 background, 
        uint8 displayItem, 
        uint8 effect
    ) public view returns (string memory) {
        string memory svg = '<svg width="768" height="768" viewBox="0 0 48 48" xmlns="http://www.w3.org/2000/svg" shape-rendering="crispEdges">';
        
        // Add filter definition for monster color adjustment (only applied to monster)
        uint16[3] memory params = _filterParams[background];
        uint16 hue = params[0];
        uint16 sat = params[1];
        uint16 bright = params[2];
        svg = string(abi.encodePacked(svg, 
            '<defs><filter id="colorFilter">',
            '<feColorMatrix type="hueRotate" values="', toString(hue), '"/>',
            '<feColorMatrix type="saturate" values="', toString(sat / 100), '.', toString(sat % 100), '"/>',
            '<feComponentTransfer><feFuncA type="discrete" tableValues="0 1"/><feFuncR type="linear" slope="', 
            toString(bright / 100), '.', toString(bright % 100), '"/><feFuncG type="linear" slope="',
            toString(bright / 100), '.', toString(bright % 100), '"/><feFuncB type="linear" slope="',
            toString(bright / 100), '.', toString(bright % 100), '"/></feComponentTransfer>',
            '</filter></defs>'
        ));
        
        // Layer 1: Background (from Arweave URL)
        string memory bgUrl = backgroundBank.getBackgroundUrl(background);
        svg = string(abi.encodePacked(svg,
            '<image href="', bgUrl, '" x="0" y="0" width="48" height="48"/>'
        ));
        
        // Layer 2: Monster with color filter (from on-chain SVG)
        string memory monsterSvg = monsterBank.getMonsterSVG(species);
        string memory monsterDataUri = svgToBase64DataUri(monsterSvg);
        svg = string(abi.encodePacked(svg,
            '<image href="', monsterDataUri, 
            '" x="0" y="0" width="48" height="48" filter="url(#colorFilter)"/>'
        ));
        
        // Layer 3: Item WITHOUT filter (from on-chain SVG)
        string memory itemSvg = itemBank.getItemSVG(displayItem);
        string memory itemDataUri = svgToBase64DataUri(itemSvg);
        svg = string(abi.encodePacked(svg,
            '<image href="', itemDataUri, 
            '" x="0" y="0" width="48" height="48"/>'
        ));
        
        // Layer 4: Effect (from Arweave URL) 
        string memory effectUrl = effectBank.getEffectUrl(effect);
        svg = string(abi.encodePacked(svg,
            '<image href="', effectUrl, '" x="0" y="0" width="48" height="48"/>'
        ));
        
        svg = string(abi.encodePacked(svg, '</svg>'));
        
        return svg;
    }
    
    function getDisplayItem(uint8 species, uint8 item) public pure returns (uint8) {
        // Check for Werewolf + Amulet synergy
        if (species == 0 && item == 9) { // Werewolf + Amulet
            return 10; // Transform to Head
        }
        
        // Check for Frankenstein + Shoulder synergy
        if (species == 2 && item == 8) { // Frankenstein + Shoulder
            return 11; // Transform to Arm
        }
        
        // No transformation
        return item;
    }
    
    function svgToBase64DataUri(string memory svg) public pure returns (string memory) {
        string memory base64 = Base64.encode(bytes(svg));
        return string(abi.encodePacked("data:image/svg+xml;base64,", base64));
    }
    
    // Add getter that returns the full tuple as expected by IArweaveTragedyComposer
    function filterParams(uint8 background) external view returns (uint16, uint16, uint16) {
        return (_filterParams[background][0], _filterParams[background][1], _filterParams[background][2]);
    }
    
    function toString(uint256 value) internal pure returns (string memory) {
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
}