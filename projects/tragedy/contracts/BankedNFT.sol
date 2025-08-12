// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "./RoyaltyStandard.sol";
import "./bank/MetadataBank.sol";

/**
 * @title BankedNFT
 * @author BankedNFT Team
 * @notice An NFT contract that can use MetadataBank for centralized metadata management
 * @dev Implements ERC721 with enumerable extension, ERC2981 royalty standard, and MetadataBank integration
 */
contract BankedNFT is ERC721Enumerable, RoyaltyStandard {

    // ============ Custom Errors ============
    error OnlyOwner();
    error InsufficientMintFee();
    error MetadataBankNotSet();
    error MaxSupplyReached();
    error InvalidMaxSupply();
    error NoBalanceToWithdraw();
    error NotOwnerOrApproved();
    error TokenIsSoulBound();
    error TransferFailed();

    // ============ Events ============
    event NFTMinted(
        address indexed to,
        uint256 indexed tokenId,
        address indexed creator,
        string metadataURI
    );

    event SoulBoundNFTMinted(
        address indexed to,
        uint256 indexed tokenId,
        address indexed creator,
        string metadataURI
    );

    event NFTBurned(uint256 indexed tokenId);
    event Withdrawn(address indexed owner, uint256 amount);
    event ReceivedEther(address indexed from, uint256 amount);
    event ConfigUpdated(
        string name,
        string symbol,
        uint256 mintFee,
        uint256 royaltyRate
    );

    // ============ State Variables ============
    address public immutable owner;
    uint256 public immutable maxSupply;
    uint256 public mintFee;
    uint256 public royaltyRate;
    uint256 public totalMinted;
    string private _name;
    string private _symbol;
    IMetadataBank public metadataBank;

    mapping(uint256 => bool) private _soulBoundTokens;

    // ============ Modifiers ============
    /**
     * @dev Restricts function access to contract owner only
     */
    modifier onlyOwner() {
        if (msg.sender != owner) revert OnlyOwner();
        _;
    }

    // ============ Constructor ============
    /**
     * @notice Deploys the NFT contract with specified parameters
     * @param nameParam The name of the NFT collection
     * @param symbolParam The symbol of the NFT collection
     * @param _maxSupply Maximum number of NFTs that can be minted
     * @param _mintFee The fee required to mint an NFT (in wei)
     * @param _royaltyRate The royalty rate in basis points (e.g., 250 = 2.5%)
     */
    constructor(
        string memory nameParam,
        string memory symbolParam,
        uint256 _maxSupply,
        uint256 _mintFee,
        uint256 _royaltyRate
    ) ERC721(nameParam, symbolParam) {
        if (_maxSupply == 0) revert InvalidMaxSupply();
        require(_royaltyRate <= 10000, "Royalty rate exceeds 100%");

        owner = msg.sender;
        maxSupply = _maxSupply;
        mintFee = _mintFee;
        royaltyRate = _royaltyRate;
        _name = nameParam;
        _symbol = symbolParam;
    }

    // ============ Minting Functions ============
    /**
     * @notice Mints a new NFT to the sender
     * @return tokenId The ID of the newly minted NFT
     */
    function mint() public payable returns (uint256) {
        if (msg.value < mintFee) revert InsufficientMintFee();
        if (totalMinted >= maxSupply) revert MaxSupplyReached();
        if (address(metadataBank) == address(0)) revert MetadataBankNotSet();

        totalMinted++;
        uint256 tokenId = totalMinted;
        
        _mint(msg.sender, tokenId);
        _setTokenRoyalty(tokenId, address(this), uint96(royaltyRate));

        // Refund excess payment
        if (msg.value > mintFee) {
            uint256 refundAmount = msg.value - mintFee;
            (bool success, ) = payable(msg.sender).call{value: refundAmount}("");
            if (!success) revert TransferFailed();
        }

        emit NFTMinted(msg.sender, tokenId, msg.sender, "");

        return tokenId;
    }
    
    /**
     * @notice Airdrops an NFT to a specified address (owner only)
     * @param to The address that will receive the NFT
     * @return tokenId The ID of the newly minted NFT
     */
    function airdrop(address to) public onlyOwner returns (uint256) {
        if (totalMinted >= maxSupply) revert MaxSupplyReached();
        if (address(metadataBank) == address(0)) revert MetadataBankNotSet();

        totalMinted++;
        uint256 tokenId = totalMinted;
        
        _mint(to, tokenId);
        _setTokenRoyalty(tokenId, address(this), uint96(royaltyRate));

        emit NFTMinted(to, tokenId, msg.sender, "");

        return tokenId;
    }

    /**
     * @notice Mints a soul-bound (non-transferable) NFT to the sender
     * @return tokenId The ID of the newly minted NFT
     */
    function mintSoulBound() external payable returns (uint256) {
        uint256 tokenId = mint();
        _soulBoundTokens[tokenId] = true;

        emit SoulBoundNFTMinted(msg.sender, tokenId, msg.sender, "");

        return tokenId;
    }
    
    /**
     * @notice Airdrops a soul-bound NFT to a specified address (owner only)
     * @param to The address that will receive the soul-bound NFT
     * @return tokenId The ID of the newly minted NFT
     */
    function airdropSoulBound(address to) external onlyOwner returns (uint256) {
        uint256 tokenId = airdrop(to);
        _soulBoundTokens[tokenId] = true;

        emit SoulBoundNFTMinted(to, tokenId, msg.sender, "");

        return tokenId;
    }

    // ============ Token Functions ============
    /**
     * @notice Returns the metadata URI for a specific token
     * @param tokenId The ID of the token to query
     * @return The metadata URI string
     */
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        _requireOwned(tokenId);
        
        if (address(metadataBank) == address(0)) revert MetadataBankNotSet();
        
        uint256 metadataCount = metadataBank.getMetadataCount();
        if (metadataCount == 0) return "";
        
        uint256 index = (tokenId - 1) % metadataCount;
        return metadataBank.getMetadata(index);
    }

    /**
     * @notice Burns (permanently destroys) a token
     * @param tokenId The ID of the token to burn
     */
    function burn(uint256 tokenId) external {
        if (_msgSender() != ownerOf(tokenId) && !isApprovedForAll(ownerOf(tokenId), _msgSender()) && getApproved(tokenId) != _msgSender()) {
            revert NotOwnerOrApproved();
        }

        delete _soulBoundTokens[tokenId];
        _burn(tokenId);

        emit NFTBurned(tokenId);
    }

    /**
     * @notice Checks if a token is soul-bound (non-transferable)
     * @param tokenId The ID of the token to check
     * @return True if the token is soul-bound, false otherwise
     */
    function isSoulBound(uint256 tokenId) external view returns (bool) {
        return _soulBoundTokens[tokenId];
    }

    // ============ Admin Functions ============
    /**
     * @notice Updates the contract configuration (owner only)
     * @param newName The new name for the NFT collection
     * @param newSymbol The new symbol for the NFT collection
     * @param newMintFee The new minting fee in wei
     * @param newRoyaltyRate The new royalty rate in basis points
     */
    function config(
        string memory newName,
        string memory newSymbol,
        uint256 newMintFee,
        uint256 newRoyaltyRate
    ) external onlyOwner {
        require(newRoyaltyRate <= 10000, "Royalty rate exceeds 100%");
        
        _name = newName;
        _symbol = newSymbol;
        mintFee = newMintFee;
        royaltyRate = newRoyaltyRate;
        
        emit ConfigUpdated(newName, newSymbol, newMintFee, newRoyaltyRate);
    }
    
    /**
     * @notice Sets the MetadataBank contract address (owner only)
     * @param bankAddress The address of the MetadataBank contract
     */
    function setMetadataBank(address bankAddress) external onlyOwner {
        require(bankAddress != address(0), "Invalid bank address");
        metadataBank = IMetadataBank(bankAddress);
    }

    /**
     * @notice Withdraws all contract balance to owner (owner only)
     */
    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        if (balance == 0) revert NoBalanceToWithdraw();

        (bool success, ) = payable(owner).call{value: balance}("");
        if (!success) revert TransferFailed();

        emit Withdrawn(owner, balance);
    }

    // ============ View Functions ============
    /**
     * @notice Returns the number of tokens remaining to be minted
     * @return The number of tokens that can still be minted
     */
    function remainingSupply() external view returns (uint256) {
        return maxSupply - totalMinted;
    }

    /**
     * @notice Checks if minting is still possible
     * @return True if tokens can still be minted, false otherwise
     */
    function canMint() external view returns (bool) {
        return totalMinted < maxSupply;
    }
    
    /**
     * @notice Returns the name of the NFT collection
     * @return The collection name
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }
    
    /**
     * @notice Returns the symbol of the NFT collection
     * @return The collection symbol
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    // ============ Receive Function ============
    /**
     * @notice Allows the contract to receive ETH directly
     * @dev Emits ReceivedEther event when ETH is received
     */
    receive() external payable {
        emit ReceivedEther(msg.sender, msg.value);
    }

    // ============ Internal Functions ============
    /**
     * @dev Hook that is called during token transfers, mints, and burns
     * @param to Destination address
     * @param tokenId Token ID being transferred
     * @param auth Address authorized for the transfer
     * @return The previous owner of the token
     */
    function _update(
        address to,
        uint256 tokenId,
        address auth
    ) internal virtual override returns (address) {
        address from = _ownerOf(tokenId);
        // Allow minting and burning, but check soul-bound status for transfers
        if (from != address(0) && to != address(0)) {
            if (_soulBoundTokens[tokenId]) revert TokenIsSoulBound();
        }
        return super._update(to, tokenId, auth);
    }

    // ============ Interface Support ============
    /**
     * @notice Checks if the contract supports a specific interface
     * @param interfaceId The interface identifier to check
     * @return True if the interface is supported, false otherwise
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721Enumerable, RoyaltyStandard)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}