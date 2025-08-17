// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DAOShop is ERC721, ERC721URIStorage, Ownable {
    uint256 private _nextTokenId;

    struct ItemInfo {
        string title;      // 商品名
        string tokenInfo;  // <contractAddress>/<tokenId>
        string contact;    // 連絡先 URL/メールアドレス等
        string price;      // 販売価格・単位込み。販売サイトによる
        string status;     // 予約受付中・販売中・非表示・売切など
        address creator;   // 商品登録者
    }

    mapping(uint256 => ItemInfo) public items;

    event ItemCreated(uint256 indexed tokenId, address indexed creator, string title);
    event ItemUpdated(uint256 indexed tokenId, address indexed updater);

    constructor() ERC721("DAOShop", "SHOP") {}

    modifier onlyItemCreator(uint256 tokenId) {
        require(items[tokenId].creator == msg.sender, "Only item creator can update");
        _;
    }

    function createItem(
        string memory title,
        string memory tokenInfo,
        string memory contact,
        string memory price,
        string memory status
    ) public returns (uint256) {
        uint256 tokenId = _nextTokenId++;
        _safeMint(msg.sender, tokenId);

        items[tokenId] = ItemInfo({
            title: title,
            tokenInfo: tokenInfo,
            contact: contact,
            price: price,
            status: status,
            creator: msg.sender
        });

        emit ItemCreated(tokenId, msg.sender, title);
        return tokenId;
    }

    function updateItem(
        uint256 tokenId,
        string memory title,
        string memory tokenInfo,
        string memory contact,
        string memory price,
        string memory status
    ) public onlyItemCreator(tokenId) {
        require(ownerOf(tokenId) != address(0), "Token does not exist");

        ItemInfo storage item = items[tokenId];
        item.title = title;
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
        _burn(tokenId);
        delete items[tokenId];
    }

    // Override functions
    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}