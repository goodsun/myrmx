// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./banks/MainBank1.sol";
import "./banks/MainBank2.sol";

contract MainBank {
    MainBank1 public immutable mainBank1;
    MainBank2 public immutable mainBank2;

    constructor(address _mainBank1, address _mainBank2) {
        mainBank1 = MainBank1(_mainBank1);
        mainBank2 = MainBank2(_mainBank2);
    }

    function getMainSVG(uint8 mainId) external view returns (string memory) {
        if (mainId < 5) {
            return mainBank1.getMainSVG(mainId);
        } else {
            return mainBank2.getMainSVG(mainId);
        }
    }

    function getMainName(uint8 mainId) external view returns (string memory) {
        if (mainId < 5) {
            return mainBank1.getMainName(mainId);
        } else {
            return mainBank2.getMainName(mainId);
        }
    }
}