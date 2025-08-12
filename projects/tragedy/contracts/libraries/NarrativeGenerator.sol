// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library NarrativeGenerator {
    function generateTitle(
        string memory monster,
        string memory background,
        string memory item,
        uint256 tokenId
    ) internal pure returns (string memory) {
        bytes32 monsterHash = keccak256(bytes(monster));
        bytes32 itemHash = keccak256(bytes(item));
        bytes32 backgroundHash = keccak256(bytes(background));
        
        // Create title based on specific combinations
        string memory titlePrefix;
        string memory titleCore;
        
        // Special prefixes for certain backgrounds
        if (backgroundHash == keccak256(bytes("Ragnarok"))) {
            titlePrefix = "Last ";
        } else if (backgroundHash == keccak256(bytes("Void"))) {
            titlePrefix = "Void ";
        } else if (backgroundHash == keccak256(bytes("Corruption"))) {
            titlePrefix = "Corrupted ";
        } else if (backgroundHash == keccak256(bytes("Bloodmoon"))) {
            titlePrefix = "Crimson ";
        } else if (backgroundHash == keccak256(bytes("Inferno"))) {
            titlePrefix = "Infernal ";
        } else if (backgroundHash == keccak256(bytes("Frost"))) {
            titlePrefix = "Frozen ";
        } else {
            titlePrefix = "";
        }
        
        // Generate core title based on monster and item
        if (monsterHash == keccak256(bytes("Dragon"))) {
            if (itemHash == keccak256(bytes("Sword"))) titleCore = "Wyrm Knight";
            else if (itemHash == keccak256(bytes("Shield"))) titleCore = "Scale Guardian";
            else if (itemHash == keccak256(bytes("Crown"))) titleCore = "Drake Lord";
            else titleCore = "Ancient Wyrm";
        } else if (monsterHash == keccak256(bytes("Vampire"))) {
            if (itemHash == keccak256(bytes("Wine"))) titleCore = "Blood Noble";
            else if (itemHash == keccak256(bytes("Crown"))) titleCore = "Night King";
            else titleCore = "Eternal Hunter";
        } else if (monsterHash == keccak256(bytes("Skeleton"))) {
            if (itemHash == keccak256(bytes("Scythe"))) titleCore = "Bone Reaper";
            else if (itemHash == keccak256(bytes("Shield"))) titleCore = "Undead Sentinel";
            else titleCore = "Hollow One";
        } else if (monsterHash == keccak256(bytes("Demon"))) {
            if (itemHash == keccak256(bytes("Torch"))) titleCore = "Flame Bearer";
            else if (itemHash == keccak256(bytes("Sword"))) titleCore = "Hell Blade";
            else titleCore = "Fiend Lord";
        } else if (monsterHash == keccak256(bytes("Werewolf"))) {
            if (itemHash == keccak256(bytes("Amulet"))) titleCore = "Pack Alpha";
            else if (itemHash == keccak256(bytes("Shoulder"))) titleCore = "Beast Warrior";
            else titleCore = "Moon Stalker";
        } else if (monsterHash == keccak256(bytes("Zombie"))) {
            if (itemHash == keccak256(bytes("Poison"))) titleCore = "Plague Walker";
            else if (itemHash == keccak256(bytes("Amulet"))) titleCore = "Cursed Corpse";
            else titleCore = "Shambling Dead";
        } else if (monsterHash == keccak256(bytes("Mummy"))) {
            if (itemHash == keccak256(bytes("Staff"))) titleCore = "Tomb Priest";
            else if (itemHash == keccak256(bytes("Sword"))) titleCore = "Desert Warrior";
            else titleCore = "Ancient Guard";
        } else if (monsterHash == keccak256(bytes("Succubus"))) {
            if (itemHash == keccak256(bytes("Wine"))) titleCore = "Desire Maiden";
            else if (itemHash == keccak256(bytes("Staff"))) titleCore = "Dream Weaver";
            else titleCore = "Soul Temptress";
        } else if (monsterHash == keccak256(bytes("Frankenstein"))) {
            if (itemHash == keccak256(bytes("Shoulder"))) titleCore = "Flesh Sculptor";
            else if (itemHash == keccak256(bytes("Poison"))) titleCore = "Toxic Creation";
            else titleCore = "Stitched Horror";
        } else { // Goblin
            if (itemHash == keccak256(bytes("Sword"))) titleCore = "Cave Raider";
            else if (itemHash == keccak256(bytes("Shield"))) titleCore = "Tribal Guard";
            else titleCore = "Shadow Gremlin";
        }
        
        return string(abi.encodePacked(titlePrefix, titleCore));
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