// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAIModelRegistry {
    function getModelRoyalty(uint256 modelId) external view returns (uint96);
    function ownerOf(uint256 tokenId) external view returns (address);
}
