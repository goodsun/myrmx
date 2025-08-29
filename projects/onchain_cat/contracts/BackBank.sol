// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./banks/BackBank1.sol";
import "./banks/BackBank2.sol";
import "./banks/BackBank3.sol";

contract BackBank {
    BackBank1 public immutable backBank1;
    BackBank2 public immutable backBank2;
    BackBank3 public immutable backBank3;

    constructor(
        address _backBank1,
        address _backBank2,
        address _backBank3
    ) {
        backBank1 = BackBank1(_backBank1);
        backBank2 = BackBank2(_backBank2);
        backBank3 = BackBank3(_backBank3);
    }

    function getBackSVG(uint8 backId) external view returns (string memory) {
        if (backId < 4) {
            return backBank1.getBackSVG(backId);
        } else if (backId < 7) {
            return backBank2.getBackSVG(backId);
        } else {
            return backBank3.getBackSVG(backId);
        }
    }

    function getBackName(uint8 backId) external view returns (string memory) {
        if (backId < 4) {
            return backBank1.getBackName(backId);
        } else if (backId < 7) {
            return backBank2.getBackName(backId);
        } else {
            return backBank3.getBackName(backId);
        }
    }
}