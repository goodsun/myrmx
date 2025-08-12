// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title LegendaryBank
 * @notice Stores titles and descriptions for legendary token IDs
 */
contract LegendaryBank {
    
    // Legendary token IDs
    uint256[] public legendaryIds = [
        1, 7, 13, 23, 42, 86, 100, 111, 187, 217, 333, 404, 555, 616, 666, 777,
        911, 999, 1000, 1111, 1337, 1347, 1408, 1492, 1692, 1776, 2187, 3141,
        4077, 5150, 6174, 7777, 8128, 9999
    ];
    
    // Legendary titles
    string[] public legendaryTitles = [
        "The Genesis",
        "The Seventh Seal",
        "The Cursed",
        "The Enigma",
        "The Answer",
        "The Vanisher",
        "The Centurion",
        "Trinity Gate",
        "Death's Contract",
        "The Shining",
        "The Half Beast",
        "The Lost Soul",
        "The Pentacle",
        "The True Beast",
        "The Beast Awakened",
        "Lucky Seven",
        "The Final Call",
        "The Gatekeeper",
        "The Millennial",
        "The Awakening",
        "The Chosen One",
        "The Black Death",
        "The Haunted Room",
        "The Discovery",
        "The Witch Hunter",
        "The Revolution",
        "The Exponential Death",
        "Pi's Madness",
        "The Field Medic",
        "The Insane",
        "Kaprekar's Curse",
        "Fortune's Avatar",
        "Perfect Despair",
        "The Final Guardian"
    ];
    
    // Legendary descriptions
    string[] public legendaryDescriptions = [
        "The first manifestation. Where all nightmares begin.",
        "The breaking of the seventh seal unleashes the final judgment.",
        "Forever marked by misfortune, carrying curses across realms.",
        "Neither mortal nor divine, existing between all states.",
        "The answer to life, the universe, and everything cursed.",
        "Those who speak its name vanish from memory itself.",
        "The centurion who led a hundred souls to damnation.",
        "Where three paths meet, the gateway to trinity opens.",
        "The code of murder, written in blood and binding.",
        "Room 217 - where madness overwrites reality.",
        "Half the beast's power, twice the hunger for souls.",
        "A soul that exists yet cannot be found - eternally lost.",
        "The five-pointed star that channels dark transformations.",
        "The original number of the beast, older and more terrible.",
        "The beast of Revelation awakens to consume the light.",
        "Blessed and cursed in equal measure, fortune's double edge.",
        "The emergency call that goes unanswered in the void.",
        "The keeper of the final gate before absolute ending.",
        "The first of the new millennium, bearing ancient promises.",
        "When all align, the awakening cannot be stopped.",
        "Elite among the damned, chosen for a darker purpose.",
        "The year death swept across continents, leaving only plague.",
        "A room that exists outside time, trapping all who enter.",
        "The discovery that changed worlds and cursed them all.",
        "Salem's flames still burn in this hunter of the accused.",
        "Revolution born from blood, freedom paid in souls.",
        "Three to the seventh power - exponential horror multiplied.",
        "The irrational number that drives mathematicians to madness.",
        "The medic who couldn't save anyone, not even themselves.",
        "Van Halen's code for the involuntarily insane.",
        "The mathematical loop that traps consciousness forever.",
        "Quadruple luck becomes a curse of infinite probability.",
        "The perfect number that brings perfect despair.",
        "The last guardian before the void consumes all."
    ];
    
    /**
     * @notice Check if a token ID is legendary
     */
    function isLegendaryId(uint256 tokenId) external view returns (bool) {
        for (uint i = 0; i < legendaryIds.length; i++) {
            if (legendaryIds[i] == tokenId) {
                return true;
            }
        }
        return false;
    }
    
    /**
     * @notice Get legendary title for a token ID
     */
    function getLegendaryTitle(uint256 tokenId) external view returns (string memory) {
        for (uint i = 0; i < legendaryIds.length; i++) {
            if (legendaryIds[i] == tokenId) {
                return legendaryTitles[i];
            }
        }
        return "";
    }
    
    /**
     * @notice Get legendary description for a token ID
     */
    function getLegendaryDescription(uint256 tokenId) external view returns (string memory) {
        for (uint i = 0; i < legendaryIds.length; i++) {
            if (legendaryIds[i] == tokenId) {
                return legendaryDescriptions[i];
            }
        }
        return "";
    }
    
    /**
     * @notice Get total number of legendary IDs
     */
    function getLegendaryCount() external view returns (uint256) {
        return legendaryIds.length;
    }
}