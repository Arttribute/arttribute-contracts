// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFTVault {
    IERC721 public nft;
    IERC20 public fractionalToken;

    uint256 public nftId;
    address public owner;
    uint256 public totalShares;

    constructor(address _nft, uint256 _nftId, address _fractionalToken, uint256 _totalShares) {
        nft = IERC721(_nft);
        nftId = _nftId;
        fractionalToken = IERC20(_fractionalToken);
        totalShares = _totalShares;
        owner = msg.sender;
    }

    function depositNFT() public {
        require(msg.sender == owner, "Only owner can deposit NFT");
        nft.transferFrom(msg.sender, address(this), nftId);
    }

    function withdrawNFT() public {
        require(msg.sender == owner, "Only owner can withdraw NFT");
        require(fractionalToken.totalSupply() == 0, "All fractional tokens must be redeemed first");
        nft.transferFrom(address(this), msg.sender, nftId);
    }
}