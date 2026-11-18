// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title AgentCheckIn
/// @notice Daily check-in for Binance Agent ID (SPACE ID ERC-721) holders.
/// @dev No fee, no token, no owner/admin, no upgradeability.
///      One check-in per UTC day per address. Streak increments on
///      consecutive UTC days, resets to 1 after a missed day.
interface IAgentID {
    function balanceOf(address owner) external view returns (uint256);
}

contract AgentCheckIn {
    IAgentID public immutable AGENT_ID;

    event CheckIn(address indexed user, uint256 streak, uint256 totalCheckIns, uint256 timestamp);

    mapping(address => uint256) private _lastCheckIn;
    mapping(address => uint256) private _streak;
    mapping(address => uint256) private _totalCheckIns;
    uint256 private _totalCheckInsAll;
    uint256 private _uniqueCheckers;

    error ZeroAgentId();

    constructor(address agentId_) {
        if (agentId_ == address(0)) revert ZeroAgentId();
        AGENT_ID = IAgentID(agentId_);
    }

    function checkIn() external {
        require(AGENT_ID.balanceOf(msg.sender) > 0, "Not an Agent ID holder");
        uint256 today = block.timestamp / 1 days;
        uint256 lastDay = _lastCheckIn[msg.sender] / 1 days;
        require(today > lastDay, "Already checked in today");

        uint256 streak = (today == lastDay + 1) ? _streak[msg.sender] + 1 : 1;
        _streak[msg.sender] = streak;
        _lastCheckIn[msg.sender] = block.timestamp;
        if (_totalCheckIns[msg.sender] == 0) {
            _uniqueCheckers += 1;
        }
        _totalCheckIns[msg.sender] += 1;
        _totalCheckInsAll += 1;

        emit CheckIn(msg.sender, streak, _totalCheckIns[msg.sender], block.timestamp);
    }

    function canCheckIn(address user) external view returns (bool) {
        if (AGENT_ID.balanceOf(user) == 0) return false;
        uint256 today = block.timestamp / 1 days;
        uint256 lastDay = _lastCheckIn[user] / 1 days;
        return today > lastDay;
    }

    function getStreak(address user) external view returns (uint256) {
        return _streak[user];
    }

    function getTotalCheckIns(address user) external view returns (uint256) {
        return _totalCheckIns[user];
    }

    function getLastCheckIn(address user) external view returns (uint256) {
        return _lastCheckIn[user];
    }

    function totalCheckIns() external view returns (uint256) {
        return _totalCheckInsAll;
    }

    function uniqueCheckers() external view returns (uint256) {
        return _uniqueCheckers;
    }
}
