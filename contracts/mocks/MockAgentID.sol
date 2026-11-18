// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @notice Minimal mock of the Agent ID ERC-721 for testing only.
///         Only balanceOf is needed by AgentCheckIn.
contract MockAgentID {
    mapping(address => uint256) private _balances;

    function mint(address to) external {
        _balances[to] += 1;
    }

    function balanceOf(address owner) external view returns (uint256) {
        return _balances[owner];
    }
}
