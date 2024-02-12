// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract AIModelRegistry is ERC721URIStorage, Ownable {
    uint256 private _modelIds;
    mapping(uint256 => uint96) private _modelRoyalties;

    constructor() ERC721("AI Model", "AIMDL") {}

    function mintModel(address modelOwner, string memory modelURI, uint96 royaltyPercentage) public returns (uint256) {
        require(royaltyPercentage <= 10000, "Royalty percentage out of bounds"); // Max 100%
        _modelIds++;
        uint256 newModelId = _modelIds;

        _mint(modelOwner, newModelId);
        _setTokenURI(newModelId, modelURI);
        _modelRoyalties[newModelId] = royaltyPercentage;

        return newModelId;
    }

    function getModelRoyalty(uint256 modelId) external view returns (uint96) {
        require(_exists(modelId), "Model does not exist");
        return _modelRoyalties[modelId];
    }
}
