// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract AIArtNFTMarketplace is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using EnumerableMap for EnumerableMap.AddressToUintMap;

    uint256 public marketplaceFee = 250; // 2.5% marketplace fee in basis points
    // Custom royalty info mapping
    mapping(address => mapping(uint256 => address)) private royaltyReceivers;
    mapping(address => mapping(uint256 => uint256)) private royaltyPercentages; // Stored as basis points

    struct Listing {
        uint256 price;
        address seller;
        bool isAuction;
        uint256 auctionEndTime;
        address highestBidder;
        uint256 highestBid;
    }

    mapping(address => mapping(uint256 => Listing)) public listings;
    mapping(address => mapping(uint256 => EnumerableMap.AddressToUintMap)) private bids;

    event Listed(address indexed nftContract, uint256 indexed tokenId, uint256 price, address seller, bool isAuction, uint256 auctionEndTime);
    event Sale(address indexed nftContract, uint256 indexed tokenId, uint256 price, address seller, address buyer);
    event BidPlaced(address indexed nftContract, uint256 indexed tokenId, address bidder, uint256 bid);
    event AuctionEnded(address indexed nftContract, uint256 indexed tokenId, address winner, uint256 winningBid);

    constructor() {}

    // Set or update royalty information for an NFT
    function setRoyaltyInfo(address nftContract, uint256 tokenId, address receiver, uint256 percentage) external onlyOwner {
        require(percentage <= 10000, "Percentage too high"); // Max 100%
        royaltyReceivers[nftContract][tokenId] = receiver;
        royaltyPercentages[nftContract][tokenId] = percentage;
    }

    // List an NFT on the marketplace
    function listNFT(address nftContract, uint256 tokenId, uint256 price, bool isAuction, uint256 auctionDuration) public {
        require(IERC721(nftContract).ownerOf(tokenId) == msg.sender, "Caller is not the NFT owner");
        require(price > 0, "Price must be greater than zero");

        Listing memory listing = Listing({
            price: price,
            seller: msg.sender,
            isAuction: isAuction,
            auctionEndTime: isAuction ? block.timestamp.add(auctionDuration) : 0,
            highestBidder: address(0),
            highestBid: 0
        });

        listings[nftContract][tokenId] = listing;

        emit Listed(nftContract, tokenId, price, msg.sender, isAuction, listing.auctionEndTime);
    }

    // Buy an NFT or place a bid
    function buyOrBid(address nftContract, uint256 tokenId) public payable nonReentrant {
        Listing storage listing = listings[nftContract][tokenId];
        require(block.timestamp <= listing.auctionEndTime, "Auction has ended or NFT is not for auction");
        require(msg.value > listing.highestBid, "Bid must be higher than the current highest bid");

        if (listing.isAuction) {
            // Refund the previous highest bidder
            if (listing.highestBidder != address(0)) {
                payable(listing.highestBidder).transfer(listing.highestBid);
            }

            // Update the highest bid and bidder
            listing.highestBid = msg.value;
            listing.highestBidder = msg.sender;

            emit BidPlaced(nftContract, tokenId, msg.sender, msg.value);
        } else {
            require(msg.value >= listing.price, "Insufficient funds for direct purchase");
            finalizeSale(nftContract, tokenId, msg.sender, msg.value);
        }
    }

    // End auction
    function endAuction(address nftContract, uint256 tokenId) public nonReentrant {
        Listing storage listing = listings[nftContract][tokenId];
        require(block.timestamp > listing.auctionEndTime, "Auction not yet ended");
        require(listing.isAuction, "NFT is not for auction");

        if (listing.highestBidder != address(0)) {
            finalizeSale(nftContract, tokenId, listing.highestBidder, listing.highestBid);
            emit AuctionEnded(nftContract, tokenId, listing.highestBidder, listing.highestBid);
        } else {
            // Auction ended without any bids
            emit AuctionEnded(nftContract, tokenId, address(0), 0);
        }

        // Clear the auction
        listing.isAuction = false;
        listing.highestBidder = address(0);
        listing.highestBid = 0;
        listing.auctionEndTime = 0;
    }

    // Finalize the sale of an NFT
    function finalizeSale(address nftContract, uint256 tokenId, address buyer, uint256 salePrice) internal {
        Listing storage listing = listings[nftContract][tokenId];
        uint256 marketplaceFeeAmount = salePrice.mul(marketplaceFee).div(10000);
        uint256 sellerProceeds = salePrice.sub(marketplaceFeeAmount);

        address royaltyReceiver = royaltyReceivers[nftContract][tokenId];
        uint256 royaltyAmount = salePrice.mul(royaltyPercentages[nftContract][tokenId]).div(10000);

        sellerProceeds = sellerProceeds.sub(royaltyAmount);

        // Transfer funds
        payable(listing.seller).transfer(sellerProceeds);
        payable(royaltyReceiver).transfer(royaltyAmount);
        payable(owner()).transfer(marketplaceFeeAmount);

        // Transfer NFT to buyer
        IERC721(nftContract).transferFrom(listing.seller, buyer, tokenId);

        emit Sale(nftContract, tokenId, salePrice, listing.seller, buyer);

        // Remove the listing
        delete listings[nftContract][tokenId];
    }

}
