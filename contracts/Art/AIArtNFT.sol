// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/IAIModelRegistry.sol";

contract AIArtNFT is ERC721Royalty, Ownable {
    uint256 private _tokenIds;
    mapping(uint256 => string) private _tokenURIs;
    IAIModelRegistry private _modelRegistry;

    constructor(address modelRegistryAddress) ERC721("AI ART NFT", "AIART") {
        _modelRegistry = IAIModelRegistry(modelRegistryAddress);
    }

    function mintAIArt(uint256 modelId, address recipient, string memory artURI) public onlyOwner returns (uint256) {
        uint96 royaltyPercentage = _modelRegistry.getModelRoyalty(modelId);
        address modelOwner = _modelRegistry.ownerOf(modelId);

        _tokenIds++;
        uint256 newArtId = _tokenIds;

        _mint(recipient, newArtId);
        _setTokenURI(newArtId, artURI);
        _setTokenRoyalty(newArtId, modelOwner, royaltyPercentage);

        return newArtId;
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
}
