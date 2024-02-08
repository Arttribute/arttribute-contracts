// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract ArttributeMarketplace is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _itemIds;

    struct Item {
        uint256 itemId;
        uint256 modelId;
        address payable owner;
        uint256 price;
        bool forSale;
    }

    mapping(uint256 => Item) public items;
    mapping(uint256 => address) public modelToOwner;
    mapping(uint256 => uint256) public modelOwnerEarnings;

    event ItemMinted(uint256 indexed itemId, uint256 indexed modelId, address owner, string tokenUri);
    event ItemListedForSale(uint256 indexed itemId, uint256 price);
    event ItemSold(uint256 indexed itemId, address buyer, uint256 price);

    uint256 public constant modelOwnerCommission = 10; // 10% cut for model owners

    constructor() ERC721("AI ART NFT", "AIART") {}

    function mintItem(uint256 modelId, string memory tokenUri) public returns (uint256) {
        _itemIds.increment();
        uint256 newItemId = _itemIds.current();

        _safeMint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenUri);

        items[newItemId] = Item(newItemId, modelId, payable(msg.sender), 0, false);
        emit ItemMinted(newItemId, modelId, msg.sender, tokenUri);

        return newItemId;
    }

    function setSalePrice(uint256 itemId, uint256 price) public {
        require(ownerOf(itemId) == msg.sender, "Only the owner can set the sale price");
        require(price > 0, "Price must be greater than zero");

        Item storage item = items[itemId];
        item.price = price;
        item.forSale = true;

        emit ItemListedForSale(itemId, price);
    }

    function buyItem(uint256 itemId) external payable {
        Item storage item = items[itemId];
        require(item.forSale, "Item is not for sale");
        require(msg.value >= item.price, "Insufficient payment");

        uint256 modelOwnerCommissionAmount = (msg.value * modelOwnerCommission) / 100;
        uint256 sellerAmount = msg.value - modelOwnerCommissionAmount;

        modelOwnerEarnings[item.modelId] += modelOwnerCommissionAmount;
        item.owner.transfer(sellerAmount);

        _transfer(item.owner, msg.sender, itemId);

        item.owner = payable(msg.sender);
        item.forSale = false;

        emit ItemSold(itemId, msg.sender, msg.value);
    }

    function withdrawEarnings(uint256 modelId) external {
        require(modelToOwner[modelId] == msg.sender, "Only the model owner can withdraw earnings");
        uint256 earnings = modelOwnerEarnings[modelId];
        modelOwnerEarnings[modelId] = 0;
        payable(msg.sender).transfer(earnings);
    }
}
