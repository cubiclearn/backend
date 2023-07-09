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

    function setUp() public {
        credentialsBurnable = new CredentialsBurnable(address(this), "TEST", "TST", "https://test.com/", 100);
        karmaCredentialsBurnable = new KarmaAccessControluint64(credentialsBurnable, address(this));
    }

    function testHasCredentialBurnableAccess() public {
        address user = makeAddr("user");
        assertEq(karmaCredentialsBurnable.hasAccess(user), false);
        credentialsBurnable.mint(user, "1", IERC5484.BurnAuth.Neither);
        assertEq(karmaCredentialsBurnable.hasAccess(user), true);
    }

    function testRateUserWithCredentialBurnableAccess() public {
        address user = makeAddr("user");
        credentialsBurnable.mint(user, "1", IERC5484.BurnAuth.Neither);
        assertEq(karmaCredentialsBurnable.hasAccess(user), true);
        karmaCredentialsBurnable.rate(user, 1);
        assertEq(karmaCredentialsBurnable.ratingOf(user), 1);
    }

    function testRateUserWithoutCredentialBurnableAccess() public {
        address user = makeAddr("user");
        assertEq(karmaCredentialsBurnable.hasAccess(user), false);
        vm.expectRevert("NO_CREDENTIALS");
        karmaCredentialsBurnable.rate(user, 1);
    }
}
