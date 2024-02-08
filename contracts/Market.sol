// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFTMarketplace is ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _itemIds;
    Counters.Counter private _itemsSold;

    address payable owner;
    uint256 listingPrice = 0.025 ether;

    constructor() {
        owner = payable(msg.sender);
    }

    struct MarketItem {
        uint itemId;
        address nftContract;
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
        bool isERC1155;
        uint256 amount;
    }

    mapping(uint => MarketItem) private idToMarketItem;

    event MarketItemCreated (
        uint indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        bool sold,
        bool isERC1155,
        uint256 amount
    );

    function createMarketItem(
        address nftContract,
        uint256 tokenId,
        uint256 price,
        bool isERC1155,
        uint256 amount
    ) public payable nonReentrant {
        require(price > 0, "Price must be at least 1 wei");
        require(msg.value == listingPrice, "Price must be equal to listing price");

        _itemIds.increment();
        uint256 itemId = _itemIds.current();
        
        idToMarketItem[itemId] = MarketItem(
            itemId,
            nftContract,
            tokenId,
            payable(msg.sender),
            payable(address(0)),
            price,
            false,
            isERC1155,
            amount
        );

        if (isERC1155) {
            IERC1155(nftContract).safeTransferFrom(msg.sender, address(this), tokenId, amount, "");
        } else {
            IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);
        }

        emit MarketItemCreated(
            itemId,
            nftContract,
            tokenId,
            msg.sender,
            address(0),
            price,
            false,
            isERC1155,
            amount
        );
    }

    function createMarketSale(
        address nftContract,
        uint256 itemId
    ) public payable nonReentrant {
        uint price = idToMarketItem[itemId].price;
        uint tokenId = idToMarketItem[itemId].tokenId;
        bool isERC1155 = idToMarketItem[itemId].isERC1155;
        uint256 amount = idToMarketItem[itemId].amount;

        require(msg.value == price, "Please submit the asking price in order to complete the purchase");

        idToMarketItem[itemId].seller.transfer(msg.value);
        if (isERC1155) {
            IERC1155(nftContract).safeTransferFrom(address(this), msg.sender, tokenId, amount, "");
        } else {
            IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);
        }
        idToMarketItem[itemId].owner = payable(msg.sender);
        idToMarketItem[itemId].sold = true;
        _itemsSold.increment();
        payable(owner).transfer(listingPrice);
    }

    // Function to withdraw the listing fee (for contract owner)
    function withdrawListingFee() public {
        require(msg.sender == owner, "Only the contract owner can withdraw");
        owner.transfer(address(this).balance);
    }

    // Additional utility functions like fetching market items, items the user has purchased, and items a user has listed can be added here.
}
