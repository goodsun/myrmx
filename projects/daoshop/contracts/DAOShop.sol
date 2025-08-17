// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract DAOShop is ERC721, ERC721URIStorage, ERC721Enumerable, Ownable {
    uint256 private _nextTokenId;

    struct ItemInfo {
        string title;      // 商品名
        string detail;     // 商品詳細説明
        string imageUrl;   // 商品画像URL
        string tokenInfo;  // <contractAddress>/<tokenId>
        string contact;    // 連絡先 URL/メールアドレス等
        string price;      // 販売価格・単位込み。販売サイトによる
        string status;     // 予約受付中・販売中・非表示・売切など
        address creator;   // 商品登録者
    }

    mapping(uint256 => ItemInfo) public items;
    
    // creator別のトークンID管理
    mapping(address => uint256[]) private _creatorTokens;
    mapping(uint256 => uint256) private _creatorTokensIndex;

    event ItemCreated(uint256 indexed tokenId, address indexed creator, string title);
    event ItemUpdated(uint256 indexed tokenId, address indexed updater);

    constructor() ERC721("DAOShopManage", "SKU") {}

    modifier onlyItemCreator(uint256 tokenId) {
        require(items[tokenId].creator == msg.sender, "Only item creator can update");
        _;
    }

    function createItem(
        string memory title,
        string memory detail,
        string memory imageUrl,
        string memory tokenInfo,
        string memory contact,
        string memory price,
        string memory status
    ) public returns (uint256) {
        uint256 tokenId = _nextTokenId++;
        _safeMint(msg.sender, tokenId);

        items[tokenId] = ItemInfo({
            title: title,
            detail: detail,
            imageUrl: imageUrl,
            tokenInfo: tokenInfo,
            contact: contact,
            price: price,
            status: status,
            creator: msg.sender
        });
        
        // creatorのトークンリストに追加
        _creatorTokensIndex[tokenId] = _creatorTokens[msg.sender].length;
        _creatorTokens[msg.sender].push(tokenId);

        emit ItemCreated(tokenId, msg.sender, title);
        return tokenId;
    }

    function updateItem(
        uint256 tokenId,
        string memory title,
        string memory detail,
        string memory imageUrl,
        string memory tokenInfo,
        string memory contact,
        string memory price,
        string memory status
    ) public onlyItemCreator(tokenId) {
        require(ownerOf(tokenId) != address(0), "Token does not exist");

        ItemInfo storage item = items[tokenId];
        item.title = title;
        item.detail = detail;
        item.imageUrl = imageUrl;
        item.tokenInfo = tokenInfo;
        item.contact = contact;
        item.price = price;
        item.status = status;

        emit ItemUpdated(tokenId, msg.sender);
    }

    function getItem(uint256 tokenId) public view returns (ItemInfo memory) {
        require(ownerOf(tokenId) != address(0), "Token does not exist");
        return items[tokenId];
    }

    function burnItem(uint256 tokenId) public onlyItemCreator(tokenId) {
        address creator = items[tokenId].creator;
        
        // creatorのトークンリストから削除
        uint256 lastTokenIndex = _creatorTokens[creator].length - 1;
        uint256 tokenIndex = _creatorTokensIndex[tokenId];
        
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _creatorTokens[creator][lastTokenIndex];
            _creatorTokens[creator][tokenIndex] = lastTokenId;
            _creatorTokensIndex[lastTokenId] = tokenIndex;
        }
        
        _creatorTokens[creator].pop();
        delete _creatorTokensIndex[tokenId];
        
        _burn(tokenId);
        delete items[tokenId];
    }

    // Creator別のenumeration関数
    function creatorTokenCount(address creator) public view returns (uint256) {
        return _creatorTokens[creator].length;
    }
    
    function tokenOfCreatorByIndex(address creator, uint256 index) public view returns (uint256) {
        require(index < _creatorTokens[creator].length, "Index out of bounds");
        return _creatorTokens[creator][index];
    }
    
    function getCreatorTokens(address creator) public view returns (uint256[] memory) {
        return _creatorTokens[creator];
    }

    // Override functions
    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }
    
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function _generateAttributes(ItemInfo memory item) private pure returns (bytes memory) {
        return abi.encodePacked(
            '{"trait_type":"Price","value":"', item.price, '"},',
            '{"trait_type":"Status","value":"', item.status, '"},',
            '{"trait_type":"Contact","value":"', item.contact, '"},',
            '{"trait_type":"Token Info","value":"', item.tokenInfo, '"}'
        );
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        require(ownerOf(tokenId) != address(0), "Token does not exist");
        
        ItemInfo memory item = items[tokenId];
        
        bytes memory jsonBytes = abi.encodePacked(
            '{"name":"', item.title,
            '","description":"', item.detail,
            '","image":"', item.imageUrl,
            '","attributes":[',
            _generateAttributes(item),
            ']}'
        );
        
        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(jsonBytes)
            )
        );
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721URIStorage, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}