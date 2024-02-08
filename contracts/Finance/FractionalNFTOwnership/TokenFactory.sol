// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// ERC-20 Token Template
contract ERC20Token is ERC20 {
    constructor(string memory name, string memory symbol, uint256 initialSupply) ERC20(name, symbol) {
        _mint(msg.sender, initialSupply * 10**18); // Mint initial supply to the contract owner
    }
}

// Factory Contract
contract TokenFactory is Ownable {
    // Mapping to track NFT to ERC-20 token associations
    mapping(address => address) public nftToTokenMap;

    // Event to log token creation
    event TokenCreated(address indexed nftAddress, address indexed tokenAddress);

    // Create a new ERC-20 token for an NFT
    function createToken(address nftAddress, string memory name, string memory symbol, uint256 initialSupply) public onlyOwner {
        require(nftToTokenMap[nftAddress] == address(0), "Token already exists for this NFT");

        // Deploy a new ERC-20 token contract with the specified initial supply\

        //token name convention is "name Fractional Ownership Token" and symbol is "symbol-FNFT"
        string memory tokenName = string(abi.encodePacked(name, " Fractional Ownership Token"));
        string memory tokenSymbol = string(abi.encodePacked(symbol, "-FNFT"));
        
        ERC20Token newToken = new ERC20Token(tokenName, tokenSymbol, initialSupply);
        nftToTokenMap[nftAddress] = address(newToken);

        emit TokenCreated(nftAddress, address(newToken));
    }
}