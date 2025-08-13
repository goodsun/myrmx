// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IArweaveTragedyComposer {
    function backgroundBank() external view returns (address);
    function composeSVG(uint8 species, uint8 background, uint8 item, uint8 effect) external view returns (string);
    function composeSVGWithSynergy(uint8 species, uint8 background, uint8 displayItem, uint8 effect) external view returns (string);
    function effectBank() external view returns (address);
    function filterParams(uint8 background) external view returns (uint16, uint16, uint16);
    function getDisplayItem(uint8 species, uint8 item) external pure returns (uint8);
    function itemBank() external view returns (address);
    function monsterBank() external view returns (address);
    function svgToBase64DataUri(string svg) external pure returns (string);
}
