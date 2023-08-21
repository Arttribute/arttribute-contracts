// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Arttribute is ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    Counters.Counter private _itemIds;

    struct Item {
        address payable owner;
        string title;
        string details;
        bool requiresPayment;
    }

    struct Certificate{
        address owner;
        uint256 licensedItemId;
        string details;
    }
    
    mapping(uint256 => Item) public items;
    mapping(uint256 => Certificate) public certificates;

    constructor() ERC721("ArttributeCertificate", "ATRB") {}

    event ItemCreated(address owner, uint256 id, string title, string details, bool requiresPayment);

     /**
     * @dev Create an item.
     * @param _title Title of the item.
     * @param _details Details of the item.
     * @param _requiresPayment Whether the item requires payment.
     */
    function createItem(string memory _title, string memory _details, bool _requiresPayment) public {
        _itemIds.increment();
        uint256 newItemId = _itemIds.current();
        items[newItemId] = Item(payable(msg.sender), _title, _details, _requiresPayment);
        emit ItemCreated(msg.sender, newItemId, _title, _details, _requiresPayment);
    }

    /**
     * @dev Mint a certificate for an existing item.
     * @dev Require payment if item requires payment.
     * @param recipient Address of the recipient.
     * @param itemId ID of the licensed item.
     * @param details Details of the certificate.
     */
    function mintCertificate(address recipient, uint256 itemId, string memory details) public payable returns (uint256) {
        require(itemId-1 < _itemIds.current(), "Item does not exist");
        if (items[itemId].requiresPayment) {
            require(msg.value > 0, "No amount sent");
            payable(items[itemId].owner).transfer(msg.value);
             _tokenIds.increment();
            uint256 newTokenId = _tokenIds.current();
            _safeMint(recipient, newTokenId);
            certificates[newTokenId] = Certificate(recipient, itemId, details);
            return newTokenId;
        }else{
            _tokenIds.increment();
            uint256 newTokenId = _tokenIds.current();
            _safeMint(recipient, newTokenId);
            certificates[newTokenId] = Certificate(recipient, itemId, details);
            return newTokenId;
        }
        
    }

    /**
     * @dev Get certificate data.
     * @param tokenId ID of the certificate.
     */
    function getCertificate(uint256 tokenId) public view returns (Certificate memory) {
        require(_exists(tokenId), "Query for nonexistent token");
        return certificates[tokenId];   
    }

    /**
     * @dev Get the item details.
     * @param _id Id of the item.
     */
    function getItem(uint256 _id) public view returns (Item memory) {
        return items[_id];
    }

}