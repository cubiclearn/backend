// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "forge-std/Test.sol";
import "src/Karma/KarmaAccessControluint64.sol";
import "src/Credentials/CredentialsBurnable.sol";
import "src/Credentials/IERC5484.sol";

contract KarmaAccessControluint64Test is Test {
    KarmaAccessControluint64 public karmaCredentials;
    KarmaAccessControluint64 public karmaCredentialsBurnable;
    CredentialsBurnable public credentialsBurnable;
    address public MAGISTER = makeAddr("Cicerone");

    uint64 constant MAGISTER_KARMA = 100;
    uint64 constant DISCIPULUS_KARMA = 10;

    function setUp() public {
        vm.startPrank(MAGISTER);
        credentialsBurnable = new CredentialsBurnable(MAGISTER, "TEST", "TST", "https://test.com/", 100);
        karmaCredentialsBurnable = new KarmaAccessControluint64(credentialsBurnable, MAGISTER_KARMA, DISCIPULUS_KARMA);
        vm.stopPrank();
    }

    function testHasCredentialBurnableAccess() public {
        vm.startPrank(MAGISTER);
        address user = makeAddr("user");
        assertEq(karmaCredentialsBurnable.hasAccess(user), false);
        credentialsBurnable.mint(user, "1", IERC5484.BurnAuth.Neither);
        assertEq(karmaCredentialsBurnable.hasAccess(user), true);
        vm.stopPrank();
    }

    function testRateUserWithCredentialBurnableAccess() public {
        vm.startPrank(MAGISTER);
        address user = makeAddr("user");
        credentialsBurnable.mint(user, "1", IERC5484.BurnAuth.Neither);
        assertEq(karmaCredentialsBurnable.hasAccess(user), true);
        karmaCredentialsBurnable.rate(user, 1);
        assertEq(karmaCredentialsBurnable.ratingOf(user), DISCIPULUS_KARMA + 1);
        vm.stopPrank();
    }

    function testRateMagisterWithCredentialBurnableAccess() public {
        vm.startPrank(MAGISTER);
        credentialsBurnable.mint(MAGISTER, "1", IERC5484.BurnAuth.Neither);
        assertEq(karmaCredentialsBurnable.hasAccess(MAGISTER), true);
        karmaCredentialsBurnable.rate(MAGISTER, 1);
        assertEq(karmaCredentialsBurnable.ratingOf(MAGISTER), MAGISTER_KARMA + 1);
        vm.stopPrank();
    }

    function testRateUserWithoutCredentialBurnableAccess() public {
        vm.startPrank(MAGISTER);
        address user = makeAddr("user");
        assertEq(karmaCredentialsBurnable.hasAccess(user), false);
        vm.expectRevert("NO_CREDENTIALS");
        karmaCredentialsBurnable.rate(user, 1);
        vm.stopPrank();
    }

    function testMultiRateUserWithCredentialBurnableAccess() public {
        vm.startPrank(MAGISTER);
        address[] memory users = new address[](10);
        uint64[] memory ratings = new uint64[](10);
        for (uint64 i = 0; i < 10; i++) {
            users[i] = vm.addr(i + 1);
            credentialsBurnable.mint(users[i], "1", IERC5484.BurnAuth.Neither);
            assertEq(karmaCredentialsBurnable.hasAccess(users[i]), true);
            ratings[i] = i;
        }
        karmaCredentialsBurnable.multiRate(users, ratings);
        for (uint64 i = 0; i < 10; i++) {
            assertEq(karmaCredentialsBurnable.ratingOf(users[i]), DISCIPULUS_KARMA + i);
        }
    }

    function testMultiRateUserWithoutCredentialBurnableAccess() public {
        vm.startPrank(MAGISTER);
        address[] memory users = new address[](10);
        uint64[] memory ratings = new uint64[](10);
        for (uint64 i = 0; i < 10; i++) {
            users[i] = vm.addr(i + 1);
            ratings[i] = i;
        }
        vm.expectRevert("NO_CREDENTIALS");
        karmaCredentialsBurnable.multiRate(users, ratings);
        vm.stopPrank();
    }

    function testMultiRateUserWithLengthMismatch() public {
        vm.startPrank(MAGISTER);
        address[] memory users = new address[](10);
        uint64[] memory ratings = new uint64[](9);
        vm.expectRevert("LENGTH_MISMATCH");
        karmaCredentialsBurnable.multiRate(users, ratings);
        vm.stopPrank();
    }
}
