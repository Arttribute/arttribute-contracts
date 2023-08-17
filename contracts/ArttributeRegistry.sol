// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";

contract ArttributeRegistry {

    using Counters for Counters.Counter;
    Counters.Counter private _itemIds;

    struct Item {
        address owner;
        string title;
        string details;
        bool isActive;
    }

    mapping(uint256 => Item) public items;

    function createItem(string memory _title, string memory _details) public {
         _itemIds.increment();
        uint256 newItemId = _itemIds.current();
        items[newItemId] = Item(msg.sender, _title, _details, true);
    }

    //get item by id
    function getItem(uint256 _itemId) public view returns (Item memory) {
         return items[_itemId];
    }

    //get item by owner
    function getItemsByOwner(address _owner) public view returns (Item[] memory) {
        uint256 itemCount = _itemIds.current();
        Item[] memory result = new Item[](itemCount);
        uint256 counter = 0;
        for (uint256 i = 1; i <= itemCount; i++) {
            if (items[i].owner == _owner) {
                result[counter] = items[i];
                counter++;
            }
        }
        return result;
    }

}
