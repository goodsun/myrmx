// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title ArweaveBackgroundBank
 * @notice Stores Arweave URLs for background images
 * @dev Backgrounds are stored on Arweave for permanent storage
 */
contract ArweaveBackgroundBank {
    mapping(uint8 => string) private backgroundUrls;
    
    string[10] public backgroundNames = [
        "Bloodmoon",
        "Abyss",
        "Decay",
        "Corruption",
        "Venom",
        "Void",
        "Inferno",
        "Frost",
        "Ragnarok",
        "Shadow"
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
        backgroundUrls[0] = "https://lxvcqyczt77lxtat44fqqmd6cpqxk7hk3vjcjuqy5iz5nl7fhdja.arweave.net/XeooYFmf_rvME-cLCDB-E-F1fOrdUiTSGOoz1q_lONI";
        backgroundUrls[1] = "https://5x7bo6yw4nxw4gr3bwz6fsq3nownuapgcbewsk6wsyacurtzq63q.arweave.net/7f4Xexbjb24aOw2z4soba6zaAeYQSWkr1pYAKkZ5h7c";
        backgroundUrls[2] = "https://gqjker5tx6hlaxlvqdg33uqmpvxo3uwhhfuirf53fz2pcz7qhypa.arweave.net/NBKiR7O_jrBddYDNvdIMfW7t0sc5aIiXuy508WfwPh4";
        backgroundUrls[3] = "https://yrik7nm3tw2vrpa3kzauvo7z67o3yxxh7ly3vllptt3janbr45da.arweave.net/xFCvtZudtVi8G1ZBSrv59928Xuf68bqtb5z2kDQx50Y";
        backgroundUrls[4] = "https://pu7jeutfyahvbs3nltgzcc4kjyrxvzs7sokpychieglwmjttpcfa.arweave.net/fT6SUmXAD1DLbVzNkQuKTiN65l-TlPwI6CGXZiZzeIo";
        backgroundUrls[5] = "https://ogw4pggbgq3vygwidtu5g5gu6yiaeyak4inmoxo6guivk6c7lr6a.arweave.net/ca3HmME0N1wayBzp03TU9hACYAriGsdd3jURVXhfXHw";
        backgroundUrls[6] = "https://2irspnocjx73h5hnlyj6l24ospnzkezynk7ibov5ciyqe4ev4pcq.arweave.net/0iMntcJN_7P07V4T5euOk9uVEzhqvoC6vRIxAnCV48U";
        backgroundUrls[7] = "https://nqh3x6bfhcxppbyyb5xlb3v7jrcw44jjww7e5lpx52bdyh5uhusa.arweave.net/bA-7-CU4rveHGA9usO6_TEVucSm1vk6t9-6CPB-0PSQ";
        backgroundUrls[8] = "https://xdkw55h2fof752iqkj27szunqp4hoqj5bbe5dud7ib7tabozsifa.arweave.net/uNVu9Pori_7pEFJ1-WaNg_h3QT0ISdHQf0B_MAXZkgo";
        backgroundUrls[9] = "https://7gljr6kg5j4gfxxx3tj36vfocuelp5p245hgjq477a4z5bbynzra.arweave.net/-ZaY-UbqeGLe99zTv1SuFQi39frnTmTDn_g5noQ4bmI";
    }
    
    function getBackgroundUrl(uint8 id) external view returns (string memory) {
        require(id < 10, "Invalid background ID");
        return backgroundUrls[id];
    }
    
    function getBackgroundName(uint8 id) external view returns (string memory) {
        require(id < 10, "Invalid background ID");
        return backgroundNames[id];
    }
    
    function setBackgroundUrl(uint8 id, string calldata url) external onlyOwner {
        require(id < 10, "Invalid background ID");
        backgroundUrls[id] = url;
    }
    
    // Batch update for gas efficiency
    function setMultipleUrls(uint8[] calldata ids, string[] calldata urls) external onlyOwner {
        require(ids.length == urls.length, "Arrays length mismatch");
        for (uint i = 0; i < ids.length; i++) {
            require(ids[i] < 10, "Invalid background ID");
            backgroundUrls[ids[i]] = urls[i];
        }
    }
}