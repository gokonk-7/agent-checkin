// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../contracts/AgentCheckIn.sol";
import "../contracts/mocks/MockAgentID.sol";

contract AgentCheckInTest is Test {
    MockAgentID internal mock;
    AgentCheckIn internal checkin;

    address internal alice = address(0xA11CE);
    address internal bob = address(0xB0B);
    address internal carol = address(0xCA901);
    address internal dave = address(0xDA9E); // non-holder

    // Exact UTC-day boundary: 1_728_000_000 / 86400 = 20000 exactly.
    uint256 internal constant T0 = 1_728_000_000;

    event CheckIn(address indexed user, uint256 streak, uint256 totalCheckIns, uint256 timestamp);

    function setUp() public {
        vm.warp(T0);
        mock = new MockAgentID();
        mock.mint(alice);
        mock.mint(bob);
        mock.mint(carol);
        checkin = new AgentCheckIn(address(mock));
    }

    function test_RevertWhen_NonHolderCheckIn() public {
        vm.prank(dave);
        vm.expectRevert("Not an Agent ID holder");
        checkin.checkIn();
    }

    function test_HolderCanCheckInOnce() public {
        vm.prank(alice);
        checkin.checkIn();
        assertEq(checkin.getStreak(alice), 1);
        assertEq(checkin.getTotalCheckIns(alice), 1);
        assertEq(checkin.getLastCheckIn(alice), T0);
        assertEq(checkin.totalCheckIns(), 1);
        assertEq(checkin.uniqueCheckers(), 1);
    }

    function test_RevertWhen_SecondCheckInSameDay() public {
        vm.prank(alice);
        checkin.checkIn();
        vm.prank(alice);
        vm.expectRevert("Already checked in today");
        checkin.checkIn();
    }

    function test_StreakIncrementsOnConsecutiveDays() public {
        vm.prank(alice);
        checkin.checkIn();
        vm.warp(T0 + 1 days);
        vm.prank(alice);
        checkin.checkIn();
        assertEq(checkin.getStreak(alice), 2);
        vm.warp(T0 + 2 days);
        vm.prank(alice);
        checkin.checkIn();
        assertEq(checkin.getStreak(alice), 3);
        assertEq(checkin.getTotalCheckIns(alice), 3);
    }

    function test_StreakResetsAfterMissedDay() public {
        vm.prank(alice);
        checkin.checkIn();
        assertEq(checkin.getStreak(alice), 1);
        // Skip 2 full days (gap of 3 days from last check-in).
        vm.warp(T0 + 3 days);
        vm.prank(alice);
        checkin.checkIn();
        assertEq(checkin.getStreak(alice), 1);
        assertEq(checkin.getTotalCheckIns(alice), 2);
    }

    function test_EmitsCheckInEvent() public {
        vm.expectEmit(true, false, false, true, address(checkin));
        emit CheckIn(alice, 1, 1, T0);
        vm.prank(alice);
        checkin.checkIn();
    }

    function test_ViewFunctions() public {
        // Before any check-in
        assertTrue(checkin.canCheckIn(alice));
        assertFalse(checkin.canCheckIn(dave)); // non-holder
        assertEq(checkin.getStreak(alice), 0);
        assertEq(checkin.getTotalCheckIns(alice), 0);
        assertEq(checkin.getLastCheckIn(alice), 0);
        assertEq(checkin.totalCheckIns(), 0);
        assertEq(checkin.uniqueCheckers(), 0);

        // After check-in
        vm.prank(alice);
        checkin.checkIn();
        assertFalse(checkin.canCheckIn(alice)); // already today
        assertEq(checkin.getStreak(alice), 1);
        assertEq(checkin.getTotalCheckIns(alice), 1);
        assertEq(checkin.getLastCheckIn(alice), T0);
        assertEq(checkin.totalCheckIns(), 1);
        assertEq(checkin.uniqueCheckers(), 1);

        // Next day: can check in again
        vm.warp(T0 + 1 days);
        assertTrue(checkin.canCheckIn(alice));
    }

    function test_UniqueCheckersCountsDistinctAddresses() public {
        vm.prank(alice);
        checkin.checkIn();
        vm.prank(bob);
        checkin.checkIn();
        vm.prank(carol);
        checkin.checkIn();
        assertEq(checkin.uniqueCheckers(), 3);
        assertEq(checkin.totalCheckIns(), 3);

        // Same users again next day: total rises, unique stays 3.
        vm.warp(T0 + 1 days);
        vm.prank(alice);
        checkin.checkIn();
        vm.prank(bob);
        checkin.checkIn();
        assertEq(checkin.uniqueCheckers(), 3);
        assertEq(checkin.totalCheckIns(), 5);
    }

    function test_RevertWhen_ConstructorZeroAddress() public {
        vm.expectRevert(AgentCheckIn.ZeroAgentId.selector);
        new AgentCheckIn(address(0));
    }
}
