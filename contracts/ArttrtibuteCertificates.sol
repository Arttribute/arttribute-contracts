// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ArttributeCertificate is ERC721Enumerable, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    struct Certificate{
        uint256 licensedItemId;
        string details;
    }

    // Mapping from token ID to certificate data
    mapping(uint256 => Certificate) public certificates;

    constructor() ERC721("ArttributeCertificate", "ATRB") {}

    /**
     * @dev Mint a certificate.
     * @param recipient Address of the recipient.
     * @param itemId ID of the licensed item.
     * @param details Details of the certificate.
     */

    function mintCertificate(address recipient, uint256 itemId, string memory details) public returns (uint256) {
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();
        _safeMint(recipient, newTokenId);
        certificates[newTokenId] = Certificate(itemId, details);
        return newTokenId;
    }

    /**
     * @dev Get certificate data.
     * @param tokenId ID of the certificate.
     */

    function getCertificate(uint256 tokenId) public view returns (Certificate memory) {
        return certificates[tokenId];   
    }
}



