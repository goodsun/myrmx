// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./Base64.sol";

/**
 * @title Members SBT
 * @notice Soul Bound Token for web3Community membership card
 * @dev Non-transferable NFT with the following features:
 * - Free minting (no mint fee)
 * - One token per account limit
 * - Only contract owner can burn tokens
 * - No transfer functionality (Soul Bound)
 */
contract MembersSBT {
    // Token name and symbol
    string public name;
    string public symbol;

    // Default avatar image (base64 encoded SVG - simple avatar placeholder)
    string public constant DEFAULT_AVATAR = "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjAwIiBoZWlnaHQ9IjIwMCIgdmlld0JveD0iMCAwIDIwMCAyMDAiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+PGNpcmNsZSBjeD0iMTAwIiBjeT0iODAiIHI9IjQwIiBmaWxsPSIjNjY3ZWVhIi8+PHBhdGggZD0iTTEwMCwxMzBjLTQwLDAuNS04MCwyMC04MCw1MHYyMGgxNjB2LTIwQzE4MCwxNTAsMTQwLDEzMC41LDEwMCwxMzB6IiBmaWxsPSIjNjY3ZWVhIi8+PC9zdmc+";

    // Owner of the contract
    address public owner;

    // Total supply counter
    uint256 public totalSupply;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping from owner address to token ID (one token per address)
    mapping(address => uint256) private _tokenOfOwner;

    // Mapping from owner address to mint status
    mapping(address => bool) private _hasMinted;

    // User information structure
    struct UserInfo {
        string memberName;
        string discordId;
        string avatarImage;
    }

    // Mapping from address to user information
    mapping(address => UserInfo) private _userInfo;

    // Events
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Mint(address indexed to, uint256 indexed tokenId);
    event Burn(uint256 indexed tokenId);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event UserInfoUpdated(address indexed user, string memberName, string discordId, string avatarImage);

    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier hasNotMinted() {
        require(!_hasMinted[msg.sender], "Already minted");
        _;
    }

    /**
     * @dev Constructor sets the original owner of the contract
     * @param _name The name of the token
     * @param _symbol The symbol of the token
     */
    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    /**
     * @notice Mint a new SBT to the caller
     * @dev Each address can only mint once, no fee required
     */
    function mint() external hasNotMinted {
        uint256 tokenId = totalSupply + 1;

        _owners[tokenId] = msg.sender;
        _tokenOfOwner[msg.sender] = tokenId;
        _hasMinted[msg.sender] = true;

        totalSupply = tokenId;

        emit Transfer(address(0), msg.sender, tokenId);
        emit Mint(msg.sender, tokenId);
    }

    /**
     * @notice Burn a specific token
     * @param tokenId The ID of the token to burn
     * @dev Only contract owner can burn tokens
     */
    function burn(uint256 tokenId) external onlyOwner {
        require(_exists(tokenId), "Token does not exist");

        address tokenOwner = _owners[tokenId];

        delete _owners[tokenId];
        delete _tokenOfOwner[tokenOwner];
        delete _hasMinted[tokenOwner];
        delete _userInfo[tokenOwner];

        emit Transfer(tokenOwner, address(0), tokenId);
        emit Burn(tokenId);
    }

    /**
     * @notice Transfer ownership of the contract
     * @param newOwner The address of the new owner
     */
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "New owner cannot be zero address");
        address oldOwner = owner;
        owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    /**
     * @notice Get the balance of an address (0 or 1 for SBT)
     * @param account The address to query
     * @return The number of tokens owned (0 or 1)
     */
    function balanceOf(address account) external view returns (uint256) {
        return _hasMinted[account] ? 1 : 0;
    }

    /**
     * @notice Get the owner of a specific token
     * @param tokenId The ID of the token
     * @return The address of the token owner
     */
    function ownerOf(uint256 tokenId) external view returns (address) {
        address tokenOwner = _owners[tokenId];
        require(tokenOwner != address(0), "Token does not exist");
        return tokenOwner;
    }

    /**
     * @notice Get the token ID owned by an address
     * @param account The address to query
     * @return The token ID (0 if no token owned)
     */
    function tokenOfOwner(address account) external view returns (uint256) {
        return _tokenOfOwner[account];
    }

    /**
     * @notice Check if an address has already minted
     * @param account The address to check
     * @return True if the address has minted, false otherwise
     */
    function hasMinted(address account) external view returns (bool) {
        return _hasMinted[account];
    }

    /**
     * @notice Get the mint price (always 0 for this contract)
     * @return The mint price in wei (0)
     */
    function mintPrice() external pure returns (uint256) {
        return 0;
    }

    /**
     * @notice Get the maximum supply (unlimited for this contract)
     * @return The maximum supply (type(uint256).max)
     */
    function maxSupply() external pure returns (uint256) {
        return type(uint256).max;
    }

    /**
     * @notice Set user information
     * @param memberName The member's display name
     * @param discordId The member's Discord ID
     * @param avatarImage The member's avatar image (base64 encoded image data)
     * @dev Only the token holder can update their own information
     * @dev If avatarImage is empty, DEFAULT_AVATAR will be used when queried
     */
    function setUserInfo(
        string memory memberName,
        string memory discordId,
        string memory avatarImage
    ) external {
        require(_hasMinted[msg.sender], "Must hold a token to set user info");

        _userInfo[msg.sender] = UserInfo({
            memberName: memberName,
            discordId: discordId,
            avatarImage: avatarImage
        });

        emit UserInfoUpdated(msg.sender, memberName, discordId, avatarImage);
    }

    /**
     * @notice Get user information
     * @param user The address to query
     * @return memberName The member's display name
     * @return discordId The member's Discord ID
     * @return avatarImage The member's avatar image (returns DEFAULT_AVATAR if not set)
     */
    function getUserInfo(address user) external view returns (
        string memory memberName,
        string memory discordId,
        string memory avatarImage
    ) {
        UserInfo memory info = _userInfo[user];
        // Return default avatar if avatarImage is empty
        if (bytes(info.avatarImage).length == 0) {
            return (info.memberName, info.discordId, DEFAULT_AVATAR);
        }
        return (info.memberName, info.discordId, info.avatarImage);
    }

    /**
     * @dev Check if a token exists
     * @param tokenId The ID of the token to check
     * @return True if the token exists, false otherwise
     */
    function _exists(uint256 tokenId) private view returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev This function is intentionally left empty to prevent transfers
     * SBTs cannot be transferred
     */
    function transferFrom(address, address, uint256) external pure {
        revert("SBT: Transfer not allowed");
    }

    /**
     * @dev This function is intentionally left empty to prevent transfers
     * SBTs cannot be transferred
     */
    function safeTransferFrom(address, address, uint256) external pure {
        revert("SBT: Transfer not allowed");
    }

    /**
     * @dev This function is intentionally left empty to prevent transfers
     * SBTs cannot be transferred
     */
    function safeTransferFrom(address, address, uint256, bytes memory) external pure {
        revert("SBT: Transfer not allowed");
    }

    /**
     * @dev This function is intentionally left empty to prevent approvals
     * SBTs cannot be approved for transfer
     */
    function approve(address, uint256) external pure {
        revert("SBT: Approval not allowed");
    }

    /**
     * @dev This function is intentionally left empty to prevent approvals
     * SBTs cannot be approved for transfer
     */
    function setApprovalForAll(address, bool) external pure {
        revert("SBT: Approval not allowed");
    }

    /**
     * @dev This function returns zero address as approvals are not allowed
     */
    function getApproved(uint256) external pure returns (address) {
        return address(0);
    }

    /**
     * @dev This function returns false as approvals are not allowed
     */
    function isApprovedForAll(address, address) external pure returns (bool) {
        return false;
    }

    /**
     * @notice Generate SVG image for the member card
     * @param tokenId The token ID
     * @return The SVG image as a string
     */
    function _generateSVG(uint256 tokenId) private view returns (string memory) {
        address tokenOwner = _owners[tokenId];
        UserInfo memory info = _userInfo[tokenOwner];

        // Get avatar image (use default if not set)
        string memory avatarImage = bytes(info.avatarImage).length > 0 ? info.avatarImage : DEFAULT_AVATAR;

        // Convert address to string (shortened format)
        string memory addrStr = _toHexString(uint256(uint160(tokenOwner)), 20);
        string memory shortAddr = string(abi.encodePacked(
            _substring(addrStr, 0, 6),
            "...",
            _substring(addrStr, 36, 42)
        ));

        // Convert tokenId to string
        string memory tokenIdStr = _toString(tokenId);

        // Generate SVG
        return string(abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" width="600" height="350" viewBox="0 0 600 350">',
            '<defs>',
                '<linearGradient id="bg" x1="0%" y1="0%" x2="100%" y2="100%">',
                    '<stop offset="0%" style="stop-color:#667eea"/>',
                    '<stop offset="100%" style="stop-color:#764ba2"/>',
                '</linearGradient>',
                '<filter id="shadow">',
                    '<feDropShadow dx="0" dy="4" stdDeviation="4" flood-opacity="0.25"/>',
                '</filter>',
            '</defs>',
            '<rect width="600" height="350" rx="20" fill="url(#bg)"/>',
            '<rect x="20" y="20" width="560" height="310" rx="15" fill="white" fill-opacity="0.95" filter="url(#shadow)"/>',

            // Left side - Avatar and basic info
            '<image x="50" y="75" width="120" height="120" href="', avatarImage, '" clip-path="inset(0% round 50%)"/>',
            '<text x="110" y="225" text-anchor="middle" font-family="Arial, sans-serif" font-size="18" font-weight="bold" fill="#333">',
                bytes(info.memberName).length > 0 ? info.memberName : "Anonymous",
            '</text>',
            '<text x="110" y="250" text-anchor="middle" font-family="Arial, sans-serif" font-size="12" fill="#666">',
                bytes(info.discordId).length > 0 ? info.discordId : "Not Set",
            '</text>',

            // Vertical divider
            '<rect x="220" y="50" width="1" height="250" fill="#e0e0e0"/>',

            // Right side - Card info
            '<text x="400" y="70" text-anchor="middle" font-family="Arial, sans-serif" font-size="28" font-weight="bold" fill="#333">', name, '</text>',

            '<text x="260" y="130" font-family="Arial, sans-serif" font-size="14" fill="#666">Token ID</text>',
            '<text x="540" y="130" text-anchor="end" font-family="Arial, sans-serif" font-size="16" font-weight="bold" fill="#333">#', tokenIdStr, '</text>',

            '<text x="260" y="170" font-family="Arial, sans-serif" font-size="14" fill="#666">Owner</text>',
            '<text x="540" y="170" text-anchor="end" font-family="monospace" font-size="12" fill="#333">', shortAddr, '</text>',

            '<text x="260" y="210" font-family="Arial, sans-serif" font-size="14" fill="#666">Type</text>',
            '<text x="540" y="210" text-anchor="end" font-family="Arial, sans-serif" font-size="14" font-weight="bold" fill="#667eea">Soul Bound</text>',

            // Bottom banner
            '<rect x="240" y="250" width="320" height="50" rx="25" fill="#667eea"/>',
            '<text x="400" y="280" text-anchor="middle" font-family="Arial, sans-serif" font-size="16" font-weight="bold" fill="white">Community Member</text>',
            '</svg>'
        ));
    }

    /**
     * @notice Get the token URI for a given token
     * @param tokenId The token ID
     * @return The token URI as a Base64 encoded data URI
     */
    function tokenURI(uint256 tokenId) external view returns (string memory) {
        require(_exists(tokenId), "Token does not exist");

        address tokenOwner = _owners[tokenId];
        UserInfo memory info = _userInfo[tokenOwner];

        string memory svg = _generateSVG(tokenId);
        string memory svgBase64 = Base64.encode(bytes(svg));

        // Create JSON metadata
        string memory json = string(abi.encodePacked(
            '{"name":"', name, ' #', _toString(tokenId), '",',
            '"description":"Soul Bound Token for web3Community membership",',
            '"image":"data:image/svg+xml;base64,', svgBase64, '",',
            '"attributes":[',
                '{"trait_type":"Member Name","value":"', bytes(info.memberName).length > 0 ? info.memberName : "Anonymous", '"},',
                '{"trait_type":"Discord ID","value":"', bytes(info.discordId).length > 0 ? info.discordId : "Not Set", '"},',
                '{"trait_type":"Token Type","value":"Soul Bound"},',
                '{"trait_type":"Transferable","value":"No"}',
            ']}'
        ));

        return string(abi.encodePacked(
            "data:application/json;base64,",
            Base64.encode(bytes(json))
        ));
    }

    /**
     * @notice Get the contract URI for OpenSea metadata
     * @return The contract URI as a Base64 encoded data URI
     */
    function contractURI() external view returns (string memory) {
        string memory json = string(abi.encodePacked(
            '{"name":"', name, '",',
            '"description":"Soul Bound Token for web3Community membership. Non-transferable NFT that represents membership in the web3Community.",',
            '"image":"data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNjAwIiBoZWlnaHQ9IjM1MCIgdmlld0JveD0iMCAwIDYwMCAzNTAiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+PGRlZnM+PGxpbmVhckdyYWRpZW50IGlkPSJncmFkIiB4MT0iMCUiIHkxPSIwJSIgeDI9IjEwMCUiIHkyPSIxMDAlIj48c3RvcCBvZmZzZXQ9IjAlIiBzdHlsZT0ic3RvcC1jb2xvcjojNjY3ZWVhIi8+PHN0b3Agb2Zmc2V0PSIxMDAlIiBzdHlsZT0ic3RvcC1jb2xvcjojNzY0YmEyIi8+PC9saW5lYXJHcmFkaWVudD48L2RlZnM+PHJlY3Qgd2lkdGg9IjYwMCIgaGVpZ2h0PSIzNTAiIHJ4PSIyMCIgZmlsbD0idXJsKCNncmFkKSIvPjx0ZXh0IHg9IjMwMCIgeT0iMTUwIiB0ZXh0LWFuY2hvcj0ibWlkZGxlIiBmb250LWZhbWlseT0iQXJpYWwsIHNhbnMtc2VyaWYiIGZvbnQtc2l6ZT0iMzYiIGZvbnQtd2VpZ2h0PSJib2xkIiBmaWxsPSJ3aGl0ZSI+TWVtYmVycyBDYXJkPC90ZXh0Pjx0ZXh0IHg9IjMwMCIgeT0iMjAwIiB0ZXh0LWFuY2hvcj0ibWlkZGxlIiBmb250LWZhbWlseT0iQXJpYWwsIHNhbnMtc2VyaWYiIGZvbnQtc2l6ZT0iMjAiIGZpbGw9IndoaXRlIiBmaWxsLW9wYWNpdHk9IjAuOCI+U291bCBCb3VuZCBUb2tlbjwvdGV4dD48L3N2Zz4=",',
            '"external_link":"https://web3community.com",',
            '"seller_fee_basis_points":0,',
            '"fee_recipient":"0x0000000000000000000000000000000000000000"}'
        ));

        return string(abi.encodePacked(
            "data:application/json;base64,",
            Base64.encode(bytes(json))
        ));
    }

    /**
     * @dev Convert uint to string
     */
    function _toString(uint256 value) private pure returns (string memory) {
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

    /**
     * @dev Convert address to hex string
     */
    function _toHexString(uint256 value, uint256 length) private pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Get substring of a string
     */
    function _substring(string memory str, uint256 startIndex, uint256 endIndex) private pure returns (string memory) {
        bytes memory strBytes = bytes(str);
        bytes memory result = new bytes(endIndex - startIndex);
        for (uint256 i = startIndex; i < endIndex; i++) {
            result[i - startIndex] = strBytes[i];
        }
        return string(result);
    }

    /**
     * @dev Hex symbols for address conversion
     */
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
}