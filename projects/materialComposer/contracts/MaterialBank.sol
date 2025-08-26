// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract materialBank {
    address public owner;
    bool public locked = false;

    // 16個制限の定数
    uint8 public constant MAX_MATERIALS_PER_TYPE = 16;

    struct Material {
        string name;
        string attribute;
        string image;
        bool exists;
    }

    // materials[type][id] = Material
    mapping(string => mapping(uint8 => Material)) public materials;

    // 各タイプの現在の登録数を追跡
    mapping(string => uint8) public materialCount;
    
    // 登録されているタイプを追跡
    string[] public materialTypes;
    mapping(string => bool) private typeExists;

    // イベント
    event MaterialSet(string indexed materialType, uint8 indexed id, string name);
    event MaterialDeleted(string indexed materialType, uint8 indexed id);
    event ContractLocked();

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier notLocked() {
        require(!locked, "Contract is locked");
        _;
    }

    modifier validId(uint8 id) {
        require(id < MAX_MATERIALS_PER_TYPE, "ID must be less than 16");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    /**
     * マテリアルを設定
     */
    function setMaterial(
        string memory materialType,
        uint8 id,
        string memory name,
        string memory attribute,
        string memory image
    ) external onlyOwner notLocked validId(id) {
        // 新しいタイプの場合、タイプリストに追加
        if (!typeExists[materialType]) {
            materialTypes.push(materialType);
            typeExists[materialType] = true;
        }
        
        // 新規追加の場合、カウントを増加
        if (!materials[materialType][id].exists) {
            materialCount[materialType]++;
        }

        materials[materialType][id] = Material({
            name: name,
            attribute: attribute,
            image: image,
            exists: true
        });

        emit MaterialSet(materialType, id, name);
    }

    /**
     * マテリアルを削除
     */
    function delMaterial(string memory materialType, uint8 id)
        external onlyOwner notLocked validId(id) {
        require(materials[materialType][id].exists, "Material does not exist");

        delete materials[materialType][id];
        materialCount[materialType]--;
        
        // タイプ内の最後の素材を削除した場合、タイプも削除
        if (materialCount[materialType] == 0) {
            _removeType(materialType);
        }

        emit MaterialDeleted(materialType, id);
    }

    /**
     * マテリアルを取得
     */
    function getMaterial(string memory materialType, uint8 id)
        external view validId(id)
        returns (string memory name, string memory attribute, string memory image) {
        require(materials[materialType][id].exists, "Material does not exist");

        Material memory material = materials[materialType][id];
        return (material.name, material.attribute, material.image);
    }

    /**
     * マテリアルの存在確認
     */
    function materialExists(string memory materialType, uint8 id)
        external view validId(id) returns (bool) {
        return materials[materialType][id].exists;
    }

    /**
     * 特定タイプの全マテリアルIDを取得（16個までなので実用的）
     */
    function getAllMaterialIds(string memory materialType)
        external view returns (uint8[] memory) {
        uint8[] memory ids = new uint8[](materialCount[materialType]);
        uint8 currentIndex = 0;

        for (uint8 i = 0; i < MAX_MATERIALS_PER_TYPE; i++) {
            if (materials[materialType][i].exists) {
                ids[currentIndex] = i;
                currentIndex++;
            }
        }

        return ids;
    }
    
    /**
     * 登録されている全タイプを取得
     */
    function getAllTypes() external view returns (string[] memory) {
        return materialTypes;
    }
    
    /**
     * タイプ数を取得
     */
    function getTypeCount() external view returns (uint256) {
        return materialTypes.length;
    }
    
    /**
     * タイプをリストから削除（内部関数）
     */
    function _removeType(string memory materialType) private {
        require(typeExists[materialType], "Type does not exist");
        
        // 配列から該当タイプを削除
        uint256 length = materialTypes.length;
        for (uint256 i = 0; i < length; i++) {
            if (keccak256(bytes(materialTypes[i])) == keccak256(bytes(materialType))) {
                // 最後の要素を削除位置に移動して削除
                materialTypes[i] = materialTypes[length - 1];
                materialTypes.pop();
                break;
            }
        }
        
        // 存在フラグを削除
        delete typeExists[materialType];
    }

    /**
     * コントラクトのロック状態を確認
     */
    function chkLocked() external view returns (bool) {
        return locked;
    }

    /**
     * コントラクトをロック（不可逆）
     */
    function lock() external onlyOwner {
        locked = true;
        emit ContractLocked();
    }

    /**
     * オーナー権限の移譲
     */
    function transferOwnership(address newOwner) external onlyOwner notLocked {
        require(newOwner != address(0), "New owner cannot be zero address");
        owner = newOwner;
    }

    /**
     * バッチ設定（複数マテリアルを一度に設定）
     */
    function batchSetMaterials(
        string[] memory types,
        uint8[] memory ids,
        string[] memory names,
        string[] memory attributes,
        string[] memory images
    ) external onlyOwner notLocked {
        require(types.length == ids.length, "Array length mismatch");
        require(types.length == names.length, "Array length mismatch");
        require(types.length == attributes.length, "Array length mismatch");
        require(types.length == images.length, "Array length mismatch");

        for (uint i = 0; i < types.length; i++) {
            require(ids[i] < MAX_MATERIALS_PER_TYPE, "ID must be less than 16");

            if (!materials[types[i]][ids[i]].exists) {
                materialCount[types[i]]++;
            }

            // 新しいタイプの場合、タイプリストに追加
            if (!typeExists[types[i]]) {
                materialTypes.push(types[i]);
                typeExists[types[i]] = true;
            }

            materials[types[i]][ids[i]] = Material({
                name: names[i],
                attribute: attributes[i],
                image: images[i],
                exists: true
            });

            emit MaterialSet(types[i], ids[i], names[i]);
        }
    }
}