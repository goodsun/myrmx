// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IEffectBank {
    function getEffectSVG(uint8 EffectId) external pure returns (string memory);
    function getEffectName(uint8 EffectId) external pure returns (string memory);
}

contract EffectBank {
    IEffectBank public bank1;
    IEffectBank public bank2;
    IEffectBank public bank3;

    constructor(address _bank1, address _bank2, address _bank3) {
        bank1 = IEffectBank(_bank1);
        bank2 = IEffectBank(_bank2);
        bank3 = IEffectBank(_bank3);
    }

    function getEffectSVG(uint8 EffectId) public view returns (string memory) {
        if (EffectId < 4) {
            return bank1.getEffectSVG(EffectId);
        } else if (EffectId < 8) {
            return bank2.getEffectSVG(EffectId);
        } else if (EffectId < 12) {
            return bank3.getEffectSVG(EffectId);
        }
        revert("Invalid Effect ID");
    }

    function getEffectName(uint8 EffectId) public view returns (string memory) {
        if (EffectId < 4) {
            return bank1.getEffectName(EffectId);
        } else if (EffectId < 18) {
            return bank2.getEffectName(EffectId);
        } else if (EffectId < 12) {
            return bank3.getEffectName(EffectId);
        }
        revert("Invalid Effect ID");
    }
}