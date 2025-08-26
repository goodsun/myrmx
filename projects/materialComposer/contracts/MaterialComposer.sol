// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./IMaterialBank.sol";

interface IMaterialComposer {
    struct Layer {
        string materialType;
        uint8 materialId;
        string filter;
        uint8 opacity;
        string transform;
    }

    struct CompositionRule {
        string name;
        uint256 width;
        uint256 height;
        string viewBox;
        string background;
    }

    function composeSVG(
        Layer[] memory layers,
        CompositionRule memory rule
    ) external view returns (string memory);

    function composeSVGWithFilters(
        Layer[] memory layers,
        CompositionRule memory rule,
        string[] memory customFilters
    ) external view returns (string memory);
}

contract MaterialComposer is IMaterialComposer {
    IMaterialBank public materialBank;
    address public owner;

    mapping(string => string) public filters;
    mapping(string => mapping(string => string)) public transformRules;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    constructor(address _materialBank) {
        materialBank = IMaterialBank(_materialBank);
        owner = msg.sender;
        _initializeDefaultFilters();
    }

    function _initializeDefaultFilters() private {
        filters["grayscale"] = '<filter id="grayscale"><feColorMatrix type="saturate" values="0"/></filter>';
        filters["blur"] = '<filter id="blur"><feGaussianBlur stdDeviation="2"/></filter>';
        filters["brightness"] = '<filter id="brightness"><feComponentTransfer><feFuncA type="linear" slope="1.5"/></feComponentTransfer></filter>';
        filters["sepia"] = '<filter id="sepia"><feColorMatrix values="0.393 0.769 0.189 0 0 0.349 0.686 0.168 0 0 0.272 0.534 0.131 0 0 0 0 0 1 0"/></filter>';
    }

    function setFilter(string memory name, string memory filterDef) external onlyOwner {
        filters[name] = filterDef;
    }

    function setTransformRule(
        string memory materialType,
        string memory ruleName,
        string memory transform
    ) external onlyOwner {
        transformRules[materialType][ruleName] = transform;
    }

    function composeSVG(
        Layer[] memory layers,
        CompositionRule memory rule
    ) external view returns (string memory) {
        return _compose(layers, rule, new string[](0));
    }

    function composeSVGWithFilters(
        Layer[] memory layers,
        CompositionRule memory rule,
        string[] memory customFilters
    ) external view returns (string memory) {
        return _compose(layers, rule, customFilters);
    }

    function _compose(
        Layer[] memory layers,
        CompositionRule memory rule,
        string[] memory customFilters
    ) private view returns (string memory) {
        string memory svg = string(abi.encodePacked(
            '<svg width="', _toString(rule.width),
            '" height="', _toString(rule.height),
            '" viewBox="', rule.viewBox,
            '" xmlns="http://www.w3.org/2000/svg">'
        ));

        if (bytes(rule.background).length > 0) {
            svg = string(abi.encodePacked(
                svg,
                '<rect width="100%" height="100%" fill="', rule.background, '"/>'
            ));
        }

        svg = string(abi.encodePacked(svg, '<defs>'));
        
        for (uint i = 0; i < customFilters.length; i++) {
            svg = string(abi.encodePacked(svg, customFilters[i]));
        }

        for (uint i = 0; i < layers.length; i++) {
            if (bytes(layers[i].filter).length > 0 && bytes(filters[layers[i].filter]).length > 0) {
                svg = string(abi.encodePacked(svg, filters[layers[i].filter]));
            }
        }

        svg = string(abi.encodePacked(svg, '</defs>'));

        for (uint i = 0; i < layers.length; i++) {
            svg = string(abi.encodePacked(svg, _renderLayer(layers[i])));
        }

        svg = string(abi.encodePacked(svg, '</svg>'));
        return svg;
    }

    function _renderLayer(Layer memory layer) private view returns (string memory) {
        (,,string memory image) = materialBank.getMaterial(layer.materialType, layer.materialId);
        
        string memory dataUri = _svgToBase64DataUri(image);
        
        string memory element = '<image href="';
        element = string(abi.encodePacked(element, dataUri, '" width="100%" height="100%"'));

        if (bytes(layer.filter).length > 0) {
            element = string(abi.encodePacked(element, ' filter="url(#', layer.filter, ')"'));
        }

        if (layer.opacity < 100) {
            element = string(abi.encodePacked(element, ' opacity="', _toString(layer.opacity), '%"'));
        }

        string memory transform = transformRules[layer.materialType][layer.transform];
        if (bytes(transform).length > 0) {
            element = string(abi.encodePacked(element, ' transform="', transform, '"'));
        } else if (bytes(layer.transform).length > 0) {
            element = string(abi.encodePacked(element, ' transform="', layer.transform, '"'));
        }

        element = string(abi.encodePacked(element, '/>'));
        return element;
    }

    function _svgToBase64DataUri(string memory svg) private pure returns (string memory) {
        return string(abi.encodePacked(
            "data:image/svg+xml;base64,",
            Base64.encode(bytes(svg))
        ));
    }

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
}

library Base64 {
    string internal constant _TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    function encode(bytes memory data) internal pure returns (string memory) {
        if (data.length == 0) return "";
        
        string memory table = _TABLE;
        string memory result = new string(4 * ((data.length + 2) / 3));
        
        assembly {
            let tablePtr := add(table, 1)
            let resultPtr := add(result, 32)
            
            for {
                let dataPtr := data
                let endPtr := add(data, mload(data))
            } lt(dataPtr, endPtr) {
            } {
                dataPtr := add(dataPtr, 3)
                let input := mload(dataPtr)
                
                mstore8(resultPtr, mload(add(tablePtr, and(shr(18, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(shr(12, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(shr(6, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(input, 0x3F))))
                resultPtr := add(resultPtr, 1)
            }
            
            switch mod(mload(data), 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }
            
            mstore(result, sub(resultPtr, add(result, 32)))
        }
        
        return result;
    }
}