// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "forge-std/Test.sol";
import "src/Karma/KarmaAccessControl.sol";

contract KarmaAccessControlTest is Test {
    KarmaAccessControl public karma;
    Credentials public credentials;

    function setUp() public {
        credentials = new Credentials("TEST", "TST", "https://test.com/", 100);
        karma = new KarmaAccessControl(credentials);
    }

    function testHasAccess() public {
        address user = makeAddr("user");
        assertEq(karma.hasAccess(user), false);
        credentials.mint(user, "1");
        assertEq(karma.hasAccess(user), true);
    }

    function testRateUserWithAccess() public {
        address user = makeAddr("user");
        credentials.mint(user, "1");
        assertEq(karma.hasAccess(user), true);
        karma.rate(user, 1);
        assertEq(karma.ratingOf(user), 1);
    }

    function testRateUserWithoutAccess() public {
        address user = makeAddr("user");
        assertEq(karma.hasAccess(user), false);
        vm.expectRevert("KarmaAccessControl: user does not have access");
        karma.rate(user, 1);
    }
}
