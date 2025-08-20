// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IBackgroundBank {
    function getBackgroundSVG(uint8 BackgroundId) external pure returns (string memory);
    function getBackgroundName(uint8 BackgroundId) external pure returns (string memory);
}

contract BackgroundBank {
    IBackgroundBank public bank1;
    IBackgroundBank public bank2;
    IBackgroundBank public bank3;

    constructor(address _bank1, address _bank2, address _bank3) {
        bank1 = IBackgroundBank(_bank1);
        bank2 = IBackgroundBank(_bank2);
        bank3 = IBackgroundBank(_bank3);
    }

    function getBackgroundSVG(uint8 BackgroundId) public view returns (string memory) {
        if (BackgroundId < 4) {
            return bank1.getBackgroundSVG(BackgroundId);
        } else if (BackgroundId < 8) {
            return bank2.getBackgroundSVG(BackgroundId);
        } else if (BackgroundId < 12) {
            return bank3.getBackgroundSVG(BackgroundId);
        }
        revert("Invalid Background ID");
    }

    function getBackgroundName(uint8 BackgroundId) public view returns (string memory) {
        if (BackgroundId < 4) {
            return bank1.getBackgroundName(BackgroundId);
        } else if (BackgroundId < 18) {
            return bank2.getBackgroundName(BackgroundId);
        } else if (BackgroundId < 12) {
            return bank3.getBackgroundName(BackgroundId);
        }
        revert("Invalid Background ID");
    }
}