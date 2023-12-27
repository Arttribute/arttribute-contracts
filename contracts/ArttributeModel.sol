// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ArttributeModel is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    struct Model{
        uint256 ModelId;
        string details;
        uint256 priceToUse;
        uint256 acquisitionPrice;
    }

    mapping(uint256 => Model) public models;

    // Mapping from token ID to artist's earnings.
    mapping(uint256 => uint256) public artistEarnings;

    event ModelMinted(uint256 tokenId, address owner, uint256 itemId, string details, string tokenUri, uint256 priceToUse, uint256 acquisitionPrice);
    event ModelPriceUpdated(uint256 indexed tokenId, uint256 newPrice);


    constructor() ERC721("Arttribute Model", "ATMOD") {}

    function mintModel(uint256 itemId, string memory details,  string memory tokenUri, uint256 priceToUse, uint256 acquisitionPrice) public returns (uint256) {
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();
        _safeMint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenUri);
        models[newTokenId] = Model(itemId, details, priceToUse,acquisitionPrice);
        emit ModelMinted(newTokenId,msg.sender, itemId, details, tokenUri, priceToUse, acquisitionPrice);
        return newTokenId;
    }

    function getModel(uint256 tokenId) public view returns (Model memory) {
        require(_exists(tokenId), "Model does not exist");
        return models[tokenId];   
    }

    function updateModelUsePrice(uint256 _tokenId, uint256 _newUsePrice) external {
        require(ownerOf(_tokenId) == msg.sender, "Only the owner can update the price");
        models[_tokenId].priceToUse = _newUsePrice;
        emit ModelPriceUpdated(_tokenId, _newUsePrice);
    }

    function updateModelAcquisitionPrice(uint256 _tokenId, uint256 _newAcquisitionPrice) external {
        require(ownerOf(_tokenId) == msg.sender, "Only the artist can update the acquisition price");
        models[_tokenId].acquisitionPrice = _newAcquisitionPrice;
        emit ModelPriceUpdated(_tokenId, _newAcquisitionPrice);
    }

    //model owner can withdraw his earnings
    function withdrawEarnings(uint256 _tokenId) external {
        require(ownerOf(_tokenId) == msg.sender, "Only the owner can withdraw his earnings");
        uint256 amount = artistEarnings[_tokenId];
        artistEarnings[_tokenId] = 0;
        payable(msg.sender).transfer(amount);
    }

    //model acquisition
    function acquireModel(uint256 _tokenId) external payable {
        require(_exists(_tokenId), "Model does not exist");
        require(msg.value >= models[_tokenId].acquisitionPrice, "Insufficient funds to acquire the model");
        artistEarnings[_tokenId] += msg.value;
    }

    //model use
    function useModel(uint256 _tokenId) external payable {
        require(_exists(_tokenId), "Model does not exist");
        require(msg.value >= models[_tokenId].priceToUse, "Insufficient funds to use the model");
        artistEarnings[_tokenId] += msg.value;
    }
    
    //artist can withdraw his earnings
    function withdrawArtistEarnings(uint256 _tokenId) external {
        require(ownerOf(_tokenId) == msg.sender, "Only the artist can withdraw his earnings");
        uint256 amount = artistEarnings[_tokenId];
        artistEarnings[_tokenId] = 0;
        payable(msg.sender).transfer(amount);
    }
    
}