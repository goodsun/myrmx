// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title ArweaveEffectBank
 * @notice Stores Arweave URLs for effect overlays
 * @dev Effects are stored on Arweave for permanent storage
 */
contract ArweaveEffectBank {
    mapping(uint8 => string) private effectUrls;
    
    string[12] public effectNames = [
        "Seizure",
        "Mindblast",
        "Confusion",
        "Meteor",
        "Bats",
        "Poisoning",
        "Lightning",
        "Blizzard",
        "Burning",
        "Brainwash",
        "Blackout",
        "Matrix"
    ];
    
    address public owner;
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
    
    constructor() {
        owner = msg.sender;
        _initializeUrls();
    }
    
    function _initializeUrls() private {
        // Initialize with final direct gateway URLs (no redirects)
        effectUrls[0] = "https://6lgmx6c5j7m5dyg5olswadselx64cvzuaz66d7yil7a7rshogrha.arweave.net/8szL-F1P2dHg3XLlYA5EXf3BVzQGfeH_CF_B-MjuNE4";
        effectUrls[1] = "https://bxmkuadmrhqxbvwuifoybicxuot5fnnvxyvm3gg57xadhxua3agq.arweave.net/DdiqAGyJ4XDW1EFdgKBXo6fStbW-Ks2Y3f3AM96A2A0";
        effectUrls[2] = "https://27scopsc2pskeo3zad4nwtbla543xh6yk6h3522os2tw7hx33qgq.arweave.net/1-QnPkLT5KI7eQD420wrB3m7n9hXj77rTpanb5773A0";
        effectUrls[3] = "https://jxi6ywfbf4eincugauogqzljn3hfwlcnsxtgplihfqkijxzvamxa.arweave.net/TdHsWKEvCIaKhgUcaGVpbs5bLE2V5metBywUhN81Ay4";
        effectUrls[4] = "https://qi7xe4wvqyld3eegynyszak5wtzn45sgohhy5ngbldoxg4hqfjfa.arweave.net/gj9yctWGFj2QhsNxLIFdtPLedkZxz460wVjdc3DwKko";
        effectUrls[5] = "https://ncab6vr4saipz2vkp2hliaczzrjgbwzgcjiwoxvxozw5aqbthz2a.arweave.net/aIAfVjyQEPzqqn6OtABZzFJg2yYSUWdet3Zt0EAzPnQ";
        effectUrls[6] = "https://3n4imdvf6rjisoxhohzn5crvup3d5bndm7g4dtc3klhzr2f4emba.arweave.net/23iGDqX0Uok653Hy3oo1o_Y-haNnzcHMW1LPmOi8IwI";
        effectUrls[7] = "https://ouhfrxzuptiwk6ri3huio3lyzumt56yrdwomosvuhreptaygeezq.arweave.net/dQ5Y3zR80WV6KNnoh214zRk--xEdnMdKtDxI-YMGITM";
        effectUrls[8] = "https://arweave.net/pQ8Vd7LVqQIBKSbAOoq26rqKKggxF-qAsSyZfwU_ZgA";
        effectUrls[9] = "https://gnuiyadnkqh5iknil5hjerjlfopixffzuocfnhrxi7vewjjrh32q.arweave.net/M2iMAG1UD9QpqF9OkkUrK56LlLmjhFaeN0fqSyUxPvU";
        effectUrls[10] = "https://arweave.net/Re2AJZkxWB-Y3wgNOqpwKJDvc_BBM869GiGlBlCsbZI";
        effectUrls[11] = "https://arweave.net/Ajas3JTP0OL727D7uBMGX_6pJsOnINV9BEewkufnQDo";
    }
    
    function getEffectUrl(uint8 id) external view returns (string memory) {
        require(id < 12, "Invalid effect ID");
        return effectUrls[id];
    }
    
    function getEffectName(uint8 id) external view returns (string memory) {
        require(id < 12, "Invalid effect ID");
        return effectNames[id];
    }
    
    function setEffectUrl(uint8 id, string calldata url) external onlyOwner {
        require(id < 12, "Invalid effect ID");
        effectUrls[id] = url;
    }
    
    // Batch update for gas efficiency
    function setMultipleUrls(uint8[] calldata ids, string[] calldata urls) external onlyOwner {
        require(ids.length == urls.length, "Arrays length mismatch");
        for (uint i = 0; i < ids.length; i++) {
            require(ids[i] < 12, "Invalid effect ID");
            effectUrls[ids[i]] = urls[i];
        }
    }
}