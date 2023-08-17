// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ArttributePayments {
    mapping(address => uint256) public balances;

    function payItemOwner(address _artist) public payable {
        require(msg.value > 0, "No amount sent");
        balances[_artist] += msg.value;
    }

    function withdrawFunds(uint256 _amount) public {
        require(balances[msg.sender] >= _amount, "Not enough balance");
        balances[msg.sender] -= _amount;
        payable(msg.sender).transfer(_amount);
    }

}
