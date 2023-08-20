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
    }

    Item[] public items;

    event ItemCreated(address owner, uint256 id, string title, string details);

    /**
     * @dev Create an item.
     * @param _title Title of the item.
     * @param _details Details of the item.
     */
    function createItem(string memory _title, string memory _details) public {
        _itemIds.increment();
        uint256 newItemId = _itemIds.current();
        items.push(Item(msg.sender, _title, _details));
        emit ItemCreated(msg.sender, newItemId, _title, _details);
    }

    /**
     * @dev Get the item details.
     * @param _id Id of the item.
     */
    function getItem(uint256 _id) public view returns (Item memory) {
        return items[_id];
    }

    /**
     * @dev Get items by onwner.
     * @param _owner Owner of the item.
     */
    function getItemsByOwner(address _owner) public view returns (Item[] memory) {
        uint256 itemCount = 0;
        for (uint256 i = 0; i < items.length; i++) {
            if (items[i].owner == _owner) {
                itemCount++;
            }
        }
        Item[] memory itemsByOwner = new Item[](itemCount);
        uint256 index = 0;
        for (uint256 i = 0; i < items.length; i++) {
            if (items[i].owner == _owner) {
                itemsByOwner[index] = items[i];
                index++;
            }
        }
        return itemsByOwner;
    }
    
    /**
     * @dev Get all items.
     */
    function getAllItems() public view returns (Item[] memory) {
        return items;
    }

}
