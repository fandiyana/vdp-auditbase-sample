// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title Vault - scan-trigger sample for read-only VDP testing
/// Intentionally contains a few textbook issues so a scan has something to report.
contract Vault {
    address public owner;
    mapping(address => uint256) public balances;

    constructor() {
        owner = msg.sender;
    }

    // missing zero-address check
    function setOwner(address newOwner) external {
        require(msg.sender == owner, "not owner");
        owner = newOwner;
    }

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    // reentrancy: state updated after the external call
    function withdraw(uint256 amount) external {
        require(balances[msg.sender] >= amount, "insufficient");
        (bool ok, ) = msg.sender.call{value: amount}("");
        require(ok, "transfer failed");
        balances[msg.sender] -= amount;
    }

    // unchecked send result
    function payout(address to, uint256 amount) external {
        require(msg.sender == owner, "not owner");
        payable(to).send(amount);
    }

    // division before multiplication, no zero check
    function share(uint256 a, uint256 b) external pure returns (uint256) {
        return (a / b) * 1000;
    }

    // tx.origin authorization
    function privileged(address target) external {
        require(tx.origin == owner, "not owner");
        Vault(target).deposit{value: 0}();
    }

    // missing zero-address check
    function setOwnerUnchecked(address newOwner) external {
        owner = newOwner;
    }

    function balanceOf(address who) external view returns (uint256) {
        return balances[who];
    }
}
