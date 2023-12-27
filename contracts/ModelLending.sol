pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ArttributeModel.sol";

contract ModelLending {
    ArttributeModel public arttributeModel;

    struct Lending {
        address owner;
        address borrower;
        uint256 tokenId;
        uint256 startTime;
        uint256 duration;
        bool active;
    }

    Lending[] public lendings;

    event ModelLentOut(uint256 lendingId, address owner, address borrower, uint256 tokenId, uint256 startTime, uint256 duration);
    event ModelReturned(uint256 lendingId, address owner, address borrower, uint256 tokenId, uint256 endTime);

    constructor(ArttributeModel _arttributeModel) {
        arttributeModel = _arttributeModel;
    }

    function lendModel(uint256 tokenId, uint256 duration) external {
        require(arttributeModel.ownerOf(tokenId) == msg.sender, "You must own the model to lend it");
        require(duration > 0, "Duration must be greater than 0");

        arttributeModel.transferFrom(msg.sender, address(this), tokenId);

        lendings.push(Lending({
            owner: msg.sender,
            borrower: address(0),
            tokenId: tokenId,
            startTime: block.timestamp,
            duration: duration,
            active: true
        }));

        uint256 lendingId = lendings.length - 1;
        emit ModelLentOut(lendingId, msg.sender, address(0), tokenId, block.timestamp, duration);
    }

    function borrowModel(uint256 lendingId) external {
        Lending storage lending = lendings[lendingId];
        require(lending.active, "This lending is no longer active");
        require(lending.borrower == address(0), "Model is already borrowed");
        require(lending.owner != msg.sender, "You cannot borrow your own model");

        require(block.timestamp < lending.startTime + lending.duration, "Lending duration expired");

        lending.borrower = msg.sender;
        lending.active = false;

        emit ModelLentOut(lendingId, lending.owner, msg.sender, lending.tokenId, lending.startTime, lending.duration);
    }

    function returnModel(uint256 lendingId) external {
        Lending storage lending = lendings[lendingId];
        require(lending.borrower == msg.sender, "You cannot return a model you didn't borrow");
        require(!lending.active, "Model is still active for borrowing");

        arttributeModel.transferFrom(address(this), msg.sender, lending.tokenId);

        emit ModelReturned(lendingId, lending.owner, msg.sender, lending.tokenId, block.timestamp);
    }

    function getLendingInfo(uint256 lendingId) external view returns (Lending memory) {
        require(lendingId < lendings.length, "Invalid lending ID");
        return lendings[lendingId];
    }

    function getNumLendings() external view returns (uint256) {
        return lendings.length;
    }

}
