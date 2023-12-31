// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ArttributeCertificate is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    struct Certificate{
        uint256 licensedItemId;
        string details;
    }
    
    mapping(uint256 => Certificate) public certificates;

    event CertificateMinted(uint256 tokenId, address owner, uint256 itemId, string details, string tokenUri);

    constructor() ERC721("Arttribute Certificate", "ATRB") {}

    function mintCertificate(address recipient, uint256 itemId, string memory details,  string memory tokenUri) public returns (uint256) {
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();
        _safeMint(recipient, newTokenId);
        _setTokenURI(newTokenId, tokenUri);
        certificates[newTokenId] = Certificate(itemId, details);
        emit CertificateMinted(newTokenId, recipient, itemId, details, tokenUri);
        return newTokenId;
    }

    function getCertificate(uint256 tokenId) public view returns (Certificate memory) {
        require(_exists(tokenId), "Certificate does not exist");
        return certificates[tokenId];   
    }
}
