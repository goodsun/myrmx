// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./libraries/Base64.sol";
import "./libraries/NarrativeGenerator.sol";
import "./ArweaveTragedyComposer.sol";

interface IArweaveTragedyComposer {
    function composeSVG(uint8 species, uint8 background, uint8 item, uint8 effect) external view returns (string memory);
    function filterParams(uint8) external view returns (uint16, uint16, uint16);
    function monsterBank() external view returns (address);
    function itemBank() external view returns (address);
    function backgroundBank() external view returns (address);
    function effectBank() external view returns (address);
}

interface IMonsterBank {
    function getMonsterName(uint8 id) external view returns (string memory);
}

interface IBackgroundBank {
    function getBackgroundName(uint8 id) external view returns (string memory);
}

interface IItemBank {
    function getItemName(uint8 id) external view returns (string memory);
}

interface IEffectBank {
    function getEffectName(uint8 id) external view returns (string memory);
}

interface ILegendaryBank {
    function isLegendaryId(uint256 tokenId) external view returns (bool);
    function getLegendaryTitle(uint256 tokenId) external view returns (string memory);
    function getLegendaryDescription(uint256 tokenId) external view returns (string memory);
}

/**
 * @title TragedyMetadataV5
 * @notice Implements proper attribute names and adds Curse+Realm synergies
 */
contract TragedyMetadata {
    IArweaveTragedyComposer public composer;
    ILegendaryBank public legendaryBank;
    uint256 public constant SHUFFLE_SEED = 4567; // LCG multiplier (prime number) - perfect distribution
    
    struct SynergyResult {
        bool found;
        string title;
        string description;
        uint8 synergyType; // 0=none, 1=dual, 2=trinity, 3=quad
    }
    
    constructor(address _composer, address _legendaryBank) {
        composer = IArweaveTragedyComposer(_composer);
        legendaryBank = ILegendaryBank(_legendaryBank);
    }
    
    function decodeTokenId(uint256 tokenId) public pure returns (uint8 species, uint8 background, uint8 item, uint8 effect) {
        // Use LCG to ensure unique mapping: (tokenId-1) * SHUFFLE_SEED + 1) % 10000
        uint256 shuffled = ((tokenId - 1) * SHUFFLE_SEED + 1) % 10000;
        
        // Decode base-10 digits (each digit 0-9)
        effect = uint8(shuffled % 10);
        item = uint8((shuffled / 10) % 10);
        background = uint8((shuffled / 100) % 10);
        species = uint8((shuffled / 1000) % 10);
        
        // Check for legendary effect transformations
        effect = getDisplayEffect(species, item, background, effect);
    }
    
    function getDisplayEffect(uint8 species, uint8 item, uint8 background, uint8 effect) internal pure returns (uint8) {
        // Legendary combination 1: Skeleton + Scythe + Shadow + Mind Blast → Blackout
        if (species == 9 && item == 6 && background == 9 && effect == 1) {
            return 10; // Blackout effect
        }
        
        // Legendary combination 2: Frankenstein + Poison + Venom + Seizure → Matrix
        if (species == 2 && item == 3 && background == 4 && effect == 0) {
            return 11; // Matrix effect
        }
        
        // No transformation
        return effect;
    }
    
    // IMetadataBank interface implementation
    function getMetadata(uint256 index) external view returns (string memory) {
        uint256 tokenId = index + 1;
        (uint8 species, uint8 background, uint8 item, uint8 effect) = decodeTokenId(tokenId);
        return generateMetadata(tokenId, species, background, item, effect);
    }
    
    function getMetadataCount() external pure returns (uint256) {
        return 10000;
    }
    
    function generateMetadata(
        uint256 tokenId,
        uint8 species,
        uint8 background,
        uint8 item,
        uint8 effect
    ) public view returns (string memory) {
        // Get SVG from composer
        string memory svg = composer.composeSVG(species, background, item, effect);
        
        // Get names from banks
        string memory monsterName = IMonsterBank(address(composer.monsterBank())).getMonsterName(species);
        string memory backgroundName = IBackgroundBank(address(composer.backgroundBank())).getBackgroundName(background);
        string memory itemName = IItemBank(address(composer.itemBank())).getItemName(item);
        // Use the original effect ID for getting the base effect name
        uint256 shuffled = ((tokenId - 1) * SHUFFLE_SEED + 1) % 10000;
        uint8 originalEffect = uint8(shuffled % 10);
        string memory effectName = IEffectBank(address(composer.effectBank())).getEffectName(effect);
        
        // For legendary combinations, use the special effect name
        if (effect == 10 && originalEffect == 3 && species == 9 && item == 6 && background == 9) {
            effectName = "Blackout";
        } else if (effect == 11 && originalEffect == 3 && species == 2 && item == 3 && background == 4) {
            effectName = "Matrix";
        }
        
        // Check for synergies
        SynergyResult memory synergy = checkSynergies(monsterName, backgroundName, itemName, effectName);
        
        // Get title and description
        string memory title;
        string memory description;
        string memory displayItemName = itemName;
        
        // Legendary IDs get special treatment
        if (legendaryBank.isLegendaryId(tokenId)) {
            title = legendaryBank.getLegendaryTitle(tokenId);
            description = legendaryBank.getLegendaryDescription(tokenId);
        } else if (synergy.found) {
            title = synergy.title;
            description = synergy.description;
            
            // Swap item names during synergy
            if (item == 9) { // Amulet -> Head
                displayItemName = "Head";
            } else if (item == 8) { // Shoulder -> Arm
                displayItemName = "Arm";
            }
        } else {
            // Generate narrative title and description
            title = NarrativeGenerator.generateTitle(monsterName, backgroundName, itemName, tokenId);
            description = getNarrativeDescription(monsterName, backgroundName, itemName, effectName);
        }
        
        
        // Build metadata JSON with proper attribute names
        string memory json = string(abi.encodePacked(
            '{"name":"', title, '",',
            '"description":"', description, '",',
            '"image":"data:image/svg+xml;base64,', Base64.encode(bytes(svg)), '",',
            '"attributes":['
        ));
        
        // Use Species, Equipment, Realm, Curse as trait types
        json = string(abi.encodePacked(
            json,
            '{"trait_type":"Species","value":"', monsterName, '"},',
            '{"trait_type":"Equipment","value":"', displayItemName, '"},',
            '{"trait_type":"Realm","value":"', backgroundName, '"},',
            '{"trait_type":"Curse","value":"', effectName, '"}'
        ));
        
        // Calculate rarity
        string memory rarity = calculateRarity(species, item, background, effect, tokenId, synergy.synergyType);
        
        // Add synergy attribute if found
        if (synergy.found) {
            json = string(abi.encodePacked(
                json,
                ',{"trait_type":"Synergy","value":"', synergy.title, '"}'
            ));
        }
        
        // Add rarity attribute
        json = string(abi.encodePacked(
            json,
            ',{"trait_type":"Rarity","value":"', rarity, '"}'
        ));
        
        
        json = string(abi.encodePacked(json, ']}'));
        
        return string(abi.encodePacked(
            'data:application/json;base64,',
            Base64.encode(bytes(json))
        ));
    }
    
    function checkSynergies(
        string memory monster,
        string memory background,
        string memory item,
        string memory effect
    ) internal pure returns (SynergyResult memory) {
        // Check Quad Synergies (only most important ones)
        if (keccak256(bytes(monster)) == keccak256(bytes("Dragon")) &&
            keccak256(bytes(item)) == keccak256(bytes("Crown")) &&
            keccak256(bytes(background)) == keccak256(bytes("Ragnarok")) &&
            keccak256(bytes(effect)) == keccak256(bytes("Meteor"))) {
            return SynergyResult(true, "Cosmic Sovereign", "The cosmic ruler who brings the end times. Its crown channels meteor storms that herald the final days.", 3);
        }
        
        if (keccak256(bytes(monster)) == keccak256(bytes("Vampire")) &&
            keccak256(bytes(item)) == keccak256(bytes("Wine")) &&
            keccak256(bytes(background)) == keccak256(bytes("Bloodmoon")) &&
            keccak256(bytes(effect)) == keccak256(bytes("Bats"))) {
            return SynergyResult(true, "Crimson Lord", "Under the blood moon, the crimson ruler commands legions of bats. The ancient vampire lord in its truest form.", 3);
        }
        
        // Check Legendary Effect Synergies
        if (keccak256(bytes(monster)) == keccak256(bytes("Skeleton")) &&
            keccak256(bytes(item)) == keccak256(bytes("Scythe")) &&
            keccak256(bytes(background)) == keccak256(bytes("Shadow")) &&
            keccak256(bytes(effect)) == keccak256(bytes("Mind Blast"))) {
            return SynergyResult(true, "Soul Harvester", "The ultimate death incarnate. This skeletal reaper cuts through dimensions, harvesting souls across all realities in absolute darkness.", 3);
        }
        
        if (keccak256(bytes(monster)) == keccak256(bytes("Frankenstein")) &&
            keccak256(bytes(item)) == keccak256(bytes("Poison")) &&
            keccak256(bytes(background)) == keccak256(bytes("Venom")) &&
            keccak256(bytes(effect)) == keccak256(bytes("Seizure"))) {
            return SynergyResult(true, "Toxic Abomination", "A monstrous fusion of flesh and digital poison. Its body constantly glitches between physical and virtual toxicity.", 3);
        }
        
        // Check remaining Quad Synergies
        if (keccak256(bytes(monster)) == keccak256(bytes("Demon")) &&
            keccak256(bytes(item)) == keccak256(bytes("Torch")) &&
            keccak256(bytes(background)) == keccak256(bytes("Inferno")) &&
            keccak256(bytes(effect)) == keccak256(bytes("Lightning"))) {
            return SynergyResult(true, "Hellstorm Avatar", "The incarnation of hell's tempest. Lightning-wreathed flames announce its apocalyptic arrival.", 3);
        }
        
        if (keccak256(bytes(monster)) == keccak256(bytes("Succubus")) &&
            keccak256(bytes(item)) == keccak256(bytes("Magic Wand")) &&
            keccak256(bytes(background)) == keccak256(bytes("Corruption")) &&
            keccak256(bytes(effect)) == keccak256(bytes("Brain Wash"))) {
            return SynergyResult(true, "Mind Empress", "The corrupted empress who enslaves minds. Her wand weaves thoughts into chains of eternal servitude.", 3);
        }
        
        if (keccak256(bytes(monster)) == keccak256(bytes("Mummy")) &&
            keccak256(bytes(item)) == keccak256(bytes("Sword")) &&
            keccak256(bytes(background)) == keccak256(bytes("Void")) &&
            keccak256(bytes(effect)) == keccak256(bytes("Burning"))) {
            return SynergyResult(true, "Eternal Warrior", "An immortal ancient warrior wrapped in void flames. Time means nothing to this burning guardian.", 3);
        }
        
        if (keccak256(bytes(monster)) == keccak256(bytes("Werewolf")) &&
            keccak256(bytes(item)) == keccak256(bytes("Amulet")) &&
            keccak256(bytes(background)) == keccak256(bytes("Abyss")) &&
            keccak256(bytes(effect)) == keccak256(bytes("Confusion"))) {
            return SynergyResult(true, "Lunatic Alpha", "The pack leader consumed by abyssal madness. It carries trophies of those who challenged its insanity.", 3);
        }
        
        if (keccak256(bytes(monster)) == keccak256(bytes("Zombie")) &&
            keccak256(bytes(item)) == keccak256(bytes("Shoulder")) &&
            keccak256(bytes(background)) == keccak256(bytes("Decay")) &&
            keccak256(bytes(effect)) == keccak256(bytes("Poisoning"))) {
            return SynergyResult(true, "Rotting Collector", "A putrid corpse collector spreading toxic decay. Each arm in its collection tells a story of plague.", 3);
        }
        
        if (keccak256(bytes(monster)) == keccak256(bytes("Goblin")) &&
            keccak256(bytes(item)) == keccak256(bytes("Shield")) &&
            keccak256(bytes(background)) == keccak256(bytes("Frost")) &&
            keccak256(bytes(effect)) == keccak256(bytes("Blizzard"))) {
            return SynergyResult(true, "Frozen Guardian", "The ice sprite defending eternal permafrost. Its shield channels blizzards that freeze time itself.", 3);
        }
        
        // Check Trinity Synergies (3-element perfect harmony)
        // Fire Trinity
        if (keccak256(bytes(monster)) == keccak256(bytes("Dragon")) &&
            keccak256(bytes(item)) == keccak256(bytes("Sword")) &&
            keccak256(bytes(effect)) == keccak256(bytes("Burning"))) {
            return SynergyResult(true, "Primordial Flame Lord", "The ancient dragon wielding flames from the dawn of creation.", 2);
        }
        
        if (keccak256(bytes(monster)) == keccak256(bytes("Demon")) &&
            keccak256(bytes(item)) == keccak256(bytes("Torch")) &&
            keccak256(bytes(background)) == keccak256(bytes("Inferno"))) {
            return SynergyResult(true, "Hell's Gatekeeper", "The guardian of hell's entrance, eternally burning.", 2);
        }
        
        // Death Trinity
        if (keccak256(bytes(monster)) == keccak256(bytes("Skeleton")) &&
            keccak256(bytes(item)) == keccak256(bytes("Scythe")) &&
            keccak256(bytes(background)) == keccak256(bytes("Shadow"))) {
            return SynergyResult(true, "Death Incarnate", "Death itself given form, the inevitable end.", 2);
        }
        
        if (keccak256(bytes(monster)) == keccak256(bytes("Zombie")) &&
            keccak256(bytes(item)) == keccak256(bytes("Amulet")) && // Will display as Head
            keccak256(bytes(background)) == keccak256(bytes("Decay"))) {
            return SynergyResult(true, "Undead Overlord", "The crowned ruler of the walking dead.", 2);
        }
        
        // Mind Trinity
        if (keccak256(bytes(monster)) == keccak256(bytes("Succubus")) &&
            keccak256(bytes(item)) == keccak256(bytes("Wine")) &&
            keccak256(bytes(effect)) == keccak256(bytes("Brain Wash"))) {
            return SynergyResult(true, "Mind Seductress", "The temptress who intoxicates minds and souls.", 2);
        }
        
        if (keccak256(bytes(monster)) == keccak256(bytes("Vampire")) &&
            keccak256(bytes(item)) == keccak256(bytes("Crown")) &&
            keccak256(bytes(effect)) == keccak256(bytes("Mind Blast"))) {
            return SynergyResult(true, "Psychic Monarch", "The telepathic ruler of the night.", 2);
        }
        
        if (keccak256(bytes(monster)) == keccak256(bytes("Vampire")) &&
            keccak256(bytes(item)) == keccak256(bytes("Wine")) &&
            keccak256(bytes(effect)) == keccak256(bytes("Bats"))) {
            return SynergyResult(true, "Classic Nosferatu", "The original vampire in its truest form.", 2);
        }
        
        // Nature Trinity
        if (keccak256(bytes(monster)) == keccak256(bytes("Werewolf")) &&
            keccak256(bytes(item)) == keccak256(bytes("Shoulder")) && // Will display as Arm
            keccak256(bytes(background)) == keccak256(bytes("Bloodmoon"))) {
            return SynergyResult(true, "Lunar Beast", "The beast empowered by the crimson moon.", 2);
        }
        
        if (keccak256(bytes(monster)) == keccak256(bytes("Mummy")) &&
            keccak256(bytes(background)) == keccak256(bytes("Void")) &&
            keccak256(bytes(effect)) == keccak256(bytes("Meteor"))) {
            return SynergyResult(true, "Ancient Apocalypse", "The harbinger of cosmic destruction from ages past.", 2);
        }
        
        // Madness Trinity
        if (keccak256(bytes(monster)) == keccak256(bytes("Frankenstein")) &&
            keccak256(bytes(effect)) == keccak256(bytes("Lightning"))) {
            // Note: This is a simplified check as we can't check all 3 at once with current structure
            return SynergyResult(true, "Aberrant Creation", "A creation gone wrong, sparking with madness.", 2);
        }
        
        if (keccak256(bytes(monster)) == keccak256(bytes("Goblin")) &&
            keccak256(bytes(background)) == keccak256(bytes("Corruption")) &&
            keccak256(bytes(effect)) == keccak256(bytes("Confusion"))) {
            return SynergyResult(true, "Mad Trickster", "The chaotic jester of corrupted realms.", 2);
        }
        
        // Poison Trinity
        if (keccak256(bytes(item)) == keccak256(bytes("Poison")) &&
            keccak256(bytes(background)) == keccak256(bytes("Venom")) &&
            keccak256(bytes(effect)) == keccak256(bytes("Poisoning"))) {
            return SynergyResult(true, "Toxic Trinity", "The perfect convergence of all toxins.", 2);
        }
        
        // Ice Trinity
        if (keccak256(bytes(item)) == keccak256(bytes("Shield")) &&
            keccak256(bytes(background)) == keccak256(bytes("Frost")) &&
            keccak256(bytes(effect)) == keccak256(bytes("Blizzard"))) {
            return SynergyResult(true, "Frozen Fortress", "An impenetrable wall of eternal ice.", 2);
        }
        
        // Cosmic Trinity
        if (keccak256(bytes(item)) == keccak256(bytes("Magic Wand")) &&
            keccak256(bytes(background)) == keccak256(bytes("Abyss")) &&
            keccak256(bytes(effect)) == keccak256(bytes("Meteor"))) {
            return SynergyResult(true, "Cosmic Sorcery", "Magic that commands the stars themselves.", 2);
        }
        
        // Check important Dual Synergies (Equipment transformation synergies)
        if (keccak256(bytes(monster)) == keccak256(bytes("Werewolf")) &&
            keccak256(bytes(item)) == keccak256(bytes("Amulet"))) {
            return SynergyResult(true, "The Alpha's Trophy", "What appears to be a simple amulet is revealed as the severed head of the previous pack leader.", 1);
        }
        
        if (keccak256(bytes(monster)) == keccak256(bytes("Frankenstein")) &&
            keccak256(bytes(item)) == keccak256(bytes("Shoulder"))) {
            return SynergyResult(true, "The Collector", "The shoulder armor is actually a collection of harvested arms, still twitching with unnatural life.", 1);
        }
        
        // Check Curse + Realm Synergies
        if (keccak256(bytes(effect)) == keccak256(bytes("Burning")) && 
            keccak256(bytes(background)) == keccak256(bytes("Inferno"))) {
            return SynergyResult(true, "Eternal Flame", "Fire that burns without fuel, consuming reality itself.", 1);
        }
        
        if (keccak256(bytes(effect)) == keccak256(bytes("Blizzard")) && 
            keccak256(bytes(background)) == keccak256(bytes("Frost"))) {
            return SynergyResult(true, "Absolute Zero", "Where ice meets storm, nothing survives.", 1);
        }
        
        if (keccak256(bytes(effect)) == keccak256(bytes("Poisoning")) && 
            keccak256(bytes(background)) == keccak256(bytes("Venom"))) {
            return SynergyResult(true, "Toxic Miasma", "A poisonous fog that corrupts all it touches.", 1);
        }
        
        if (keccak256(bytes(effect)) == keccak256(bytes("Mind Blast")) && 
            keccak256(bytes(background)) == keccak256(bytes("Void"))) {
            return SynergyResult(true, "Mental Collapse", "The void between thoughts where sanity dies.", 1);
        }
        
        if (keccak256(bytes(effect)) == keccak256(bytes("Lightning")) && 
            keccak256(bytes(background)) == keccak256(bytes("Bloodmoon"))) {
            return SynergyResult(true, "Crimson Thunder", "Blood-red lightning that strikes with divine wrath.", 1);
        }
        
        if (keccak256(bytes(effect)) == keccak256(bytes("Brain Wash")) && 
            keccak256(bytes(background)) == keccak256(bytes("Corruption"))) {
            return SynergyResult(true, "Mind Corruption", "Thoughts twisted into weapons against their owner.", 1);
        }
        
        if (keccak256(bytes(effect)) == keccak256(bytes("Meteor")) && 
            keccak256(bytes(background)) == keccak256(bytes("Ragnarok"))) {
            return SynergyResult(true, "Apocalypse Rain", "The sky falls, bringing the end of all things.", 1);
        }
        
        if (keccak256(bytes(effect)) == keccak256(bytes("Bats")) && 
            keccak256(bytes(background)) == keccak256(bytes("Shadow"))) {
            return SynergyResult(true, "Night Terror", "Living shadows that feast on fear.", 1);
        }
        
        if (keccak256(bytes(effect)) == keccak256(bytes("Confusion")) && 
            keccak256(bytes(background)) == keccak256(bytes("Decay"))) {
            return SynergyResult(true, "Madness Plague", "A disease that rots both mind and body.", 1);
        }
        
        if (keccak256(bytes(effect)) == keccak256(bytes("Seizure")) && 
            keccak256(bytes(background)) == keccak256(bytes("Abyss"))) {
            return SynergyResult(true, "Deep Tremor", "Convulsions from staring too long into the infinite dark.", 1);
        }
        
        // Check important Dual Synergies (Species + Equipment)
        if (keccak256(bytes(monster)) == keccak256(bytes("Vampire")) &&
            keccak256(bytes(item)) == keccak256(bytes("Wine"))) {
            return SynergyResult(true, "Blood Sommelier", "A refined predator who has transcended mere survival. This vampire has cultivated an exquisite palate for the finest vintages.", 1);
        }
        
        if (keccak256(bytes(monster)) == keccak256(bytes("Skeleton")) &&
            keccak256(bytes(item)) == keccak256(bytes("Scythe"))) {
            return SynergyResult(true, "Death's Herald", "The original harbinger of doom. This skeletal reaper has collected souls since the dawn of mortality itself.", 1);
        }
        
        return SynergyResult(false, "", "", 0);
    }
    
    function getNarrativeDescription(
        string memory monster,
        string memory background,
        string memory item,
        string memory effect
    ) internal pure returns (string memory) {
        return string(abi.encodePacked(
            getRealmPrefix(background), " ",
            getMonsterAction(monster, item), " ",
            getCurseDescription(effect)
        ));
    }
    
    function getRealmPrefix(string memory background) internal pure returns (string memory) {
        bytes32 bgHash = keccak256(bytes(background));
        
        if (bgHash == keccak256(bytes("Bloodmoon"))) return "Under the crimson gaze,";
        else if (bgHash == keccak256(bytes("Abyss"))) return "From the endless void,";
        else if (bgHash == keccak256(bytes("Decay"))) return "In rotting wastelands,";
        else if (bgHash == keccak256(bytes("Corruption"))) return "Where reality breaks,";
        else if (bgHash == keccak256(bytes("Venom"))) return "In toxic mists,";
        else if (bgHash == keccak256(bytes("Void"))) return "At existence's edge,";
        else if (bgHash == keccak256(bytes("Inferno"))) return "Within eternal flames,";
        else if (bgHash == keccak256(bytes("Frost"))) return "In frozen wastes,";
        else if (bgHash == keccak256(bytes("Ragnarok"))) return "As the world ends,";
        else return "In shadow's reach,";
    }
    
    function getMonsterAction(string memory monster, string memory item) internal pure returns (string memory) {
        bytes32 monsterHash = keccak256(bytes(monster));
        bytes32 itemHash = keccak256(bytes(item));
        
        if (monsterHash == keccak256(bytes("Dragon"))) {
            if (itemHash == keccak256(bytes("Crown"))) return "the wyrm reclaims dominion";
            else if (itemHash == keccak256(bytes("Sword"))) return "the drake wields dragonfire steel";
            else return "this terror hoards cursed treasures";
        } else if (monsterHash == keccak256(bytes("Vampire"))) {
            if (itemHash == keccak256(bytes("Wine"))) return "the noble savors crimson vintage";
            else return "this nightwalker hunts eternally";
        } else if (monsterHash == keccak256(bytes("Skeleton"))) {
            if (itemHash == keccak256(bytes("Scythe"))) return "death's herald reaps souls";
            else return "ancient bones clutch their relics";
        } else if (monsterHash == keccak256(bytes("Demon"))) {
            if (itemHash == keccak256(bytes("Torch"))) return "the hellspawn lights perdition's path";
            else return "this fiend wields torment";
        } else if (monsterHash == keccak256(bytes("Werewolf"))) {
            return "the beast stalks with primal fury";
        } else if (monsterHash == keccak256(bytes("Zombie"))) {
            if (itemHash == keccak256(bytes("Poison"))) return "the plague walker spreads infection";
            else return "this corpse shambles onward";
        } else if (monsterHash == keccak256(bytes("Mummy"))) {
            if (itemHash == keccak256(bytes("Staff"))) return "the pharaoh commands divinely";
            else return "this guardian endures eternally";
        } else if (monsterHash == keccak256(bytes("Succubus"))) {
            return "the temptress ensnares souls";
        } else if (monsterHash == keccak256(bytes("Frankenstein"))) {
            return "this creation defies nature";
        } else {
            return "the goblin plots mischief";
        }
    }
    
    function getCurseDescription(string memory effect) internal pure returns (string memory) {
        bytes32 effectHash = keccak256(bytes(effect));
        
        if (effectHash == keccak256(bytes("Burning"))) return "while flames consume endlessly.";
        else if (effectHash == keccak256(bytes("Blizzard"))) return "as frozen winds tear reality.";
        else if (effectHash == keccak256(bytes("Lightning"))) return "beneath electric fury.";
        else if (effectHash == keccak256(bytes("Meteor"))) return "while heavens rain destruction.";
        else if (effectHash == keccak256(bytes("Mind Blast"))) return "its screams shatter sanity.";
        else if (effectHash == keccak256(bytes("Brain Wash"))) return "enslaving minds with madness.";
        else if (effectHash == keccak256(bytes("Confusion"))) return "spreading fractured chaos.";
        else if (effectHash == keccak256(bytes("Seizure"))) return "causing reality to convulse.";
        else if (effectHash == keccak256(bytes("Poisoning"))) return "leaving toxic death behind.";
        else return "commanding nightborn servants.";
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
    
    function calculateRarity(
        uint8 species,
        uint8 item,
        uint8 background,
        uint8 effect,
        uint256 tokenId,
        uint8 synergyType
    ) internal view returns (string memory) {
        // Check if it's a Legendary ID
        if (legendaryBank.isLegendaryId(tokenId)) {
            return "Legendary";
        }
        
        // Quad synergy always gets Ultimate
        if (synergyType == 3) {
            return "Ultimate";
        }
        
        // Trinity synergy always gets Trinity
        if (synergyType == 2) {
            return "Trinity";
        }
        
        // Dual synergy always gets Epic (DESIGN.md specification)
        if (synergyType == 1) {
            return "Epic";
        }
        
        // Calculate base rarity level
        uint8 baseLevel = getBaseRarityLevel(tokenId);
        
        return getRarityName(baseLevel);
    }
    
    function getBaseRarityLevel(uint256 tokenId) internal pure returns (uint8) {
        // Check for 3-digit patterns first (Rare)
        uint256 last3 = tokenId % 1000;
        uint256 d1 = last3 / 100;
        uint256 d2 = (last3 / 10) % 10;
        uint256 d3 = last3 % 10;
        
        // Triple digits (111, 222, 333, etc.)
        if (d1 == d2 && d2 == d3 && tokenId >= 100) {
            return 2; // Rare
        }
        
        // Sequential ascending (123, 234, 345, etc.)
        if (d1 + 1 == d2 && d2 + 1 == d3 && tokenId >= 100) {
            return 2; // Rare
        }
        
        // Sequential descending (321, 432, 543, etc.)
        if (d1 == d2 + 1 && d2 == d3 + 1 && tokenId >= 100) {
            return 2; // Rare
        }
        
        // Check for 2-digit doubles (Uncommon)
        uint256 last2 = tokenId % 100;
        if (last2 == 11 || last2 == 22 || last2 == 33 || last2 == 44 || 
            last2 == 55 || last2 == 66 || last2 == 77 || last2 == 88 || 
            last2 == 99 || last2 == 0) { // 00 counts as double
            return 1; // Uncommon
        }
        
        // Everything else is Common
        return 0; // Common
    }
    
    function getRarityName(uint8 level) internal pure returns (string memory) {
        if (level == 0) return "Common";
        if (level == 1) return "Uncommon";
        if (level == 2) return "Rare";
        if (level == 3) return "Epic";
        if (level == 4) return "Legendary";
        if (level == 5) return "Trinity";
        return "Ultimate";
    }
}