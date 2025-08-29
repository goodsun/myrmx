// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./banks/FrontBank1.sol";
import "./banks/FrontBank2.sol";

contract FrontBank {
    FrontBank1 public immutable frontBank1;
    FrontBank2 public immutable frontBank2;

    constructor(address _frontBank1, address _frontBank2) {
        frontBank1 = FrontBank1(_frontBank1);
        frontBank2 = FrontBank2(_frontBank2);
    }

    function getFrontSVG(uint8 frontId) external view returns (string memory) {
        if (frontId < 5) {
            return frontBank1.getFrontSVG(frontId);
        } else {
            return frontBank2.getFrontSVG(frontId);
        }
    }

    function getFrontName(uint8 frontId) external view returns (string memory) {
        if (frontId < 5) {
            return frontBank1.getFrontName(frontId);
        } else {
            return frontBank2.getFrontName(frontId);
        }
    }
}