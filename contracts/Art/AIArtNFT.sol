// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract AIArtNFT is ERC721Royalty, Ownable {
    uint256 private _tokenIds;
    mapping(uint256 => string) private _tokenURIs;

    // Constructor to set the name and symbol of the NFT collection
    constructor() ERC721("AI ART NFT", "AIART") {}

    // Function to mint a new AI art NFT
    function mintAIArt(address recipient, string memory _tokenURI, uint96 royaltyFraction) public returns (uint256) {
        _tokenIds++;
        uint256 newItemId = _tokenIds;

        _mint(recipient, newItemId);
        _setTokenURI(newItemId, _tokenURI);
        // Set the royalty info for this NFT to pay the AI model owner
        _setTokenRoyalty(newItemId, owner(), royaltyFraction);

        return newItemId;
    }

    // Override required by Solidity for _setTokenURI
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    // Function to fetch the URI of a given token ID
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        return _tokenURIs[tokenId];
    }

    // Function to update royalty information
    function setTokenRoyalty(uint256 tokenId, address recipient, uint96 fraction) public onlyOwner {
        _setTokenRoyalty(tokenId, recipient, fraction);
    }
}
