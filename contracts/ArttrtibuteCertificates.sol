// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ArttributeCertificates is ERC721Enumerable, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    struct Certificate{
        address owner;
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
        certificates[newTokenId] = Certificate(recipient, itemId, details);
        return newTokenId;
    }

    /**
     * @dev Get certificate data.
     * @param tokenId ID of the certificate.
     */
    function getCertificate(uint256 tokenId) public view returns (Certificate memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        return certificates[tokenId];   
    }

    /**
     * @dev Get all certificates by owner.
     * @param owner Owner of the certificate.
     */
    function getCertificatesByOwner(address owner) public view returns (Certificate[] memory) {
        uint256 certificateCount = 0;
        for (uint256 i = 0; i < _tokenIds.current(); i++) {
            if (certificates[i].owner == owner) {
                certificateCount++;
            }
        }
        Certificate[] memory certificatesByOwner = new Certificate[](certificateCount);
        uint256 index = 0;
        for (uint256 i = 0; i < _tokenIds.current(); i++) {
            if (certificates[i].owner == owner) {
                certificatesByOwner[index] = certificates[i];
                index++;
            }
        }
        return certificatesByOwner;
    }
     
}



