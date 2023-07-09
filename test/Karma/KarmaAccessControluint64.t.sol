// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "forge-std/Test.sol";
import "src/Karma/KarmaAccessControluint64.sol";
import "src/Credentials/Credentials.sol";
import "src/Credentials/CredentialsBurnable.sol";
import "src/Credentials/IERC5484.sol";

contract KarmaAccessControluint64Test is Test {
    KarmaAccessControluint64 public karmaCredentials;
    KarmaAccessControluint64 public karmaCredentialsBurnable;
    Credentials public credentials;
    CredentialsBurnable public credentialsBurnable;

    function setUp() public {
        credentials = new Credentials("TEST", "TST", "https://test.com/", 100);
        karmaCredentials = new KarmaAccessControluint64(credentials, address(this));

        credentialsBurnable = new CredentialsBurnable(address(this), "TEST", "TST", "https://test.com/", 100);
        karmaCredentialsBurnable = new KarmaAccessControluint64(credentialsBurnable, address(this));
    }

    function testHasCredentialAccess() public {
        address user = makeAddr("user");
        assertEq(karmaCredentials.hasAccess(user), false);
        credentials.mint(user, "1");
        assertEq(karmaCredentials.hasAccess(user), true);
    }

    function testRateUserWithCredentialAccess() public {
        address user = makeAddr("user");
        credentials.mint(user, "1");
        assertEq(karmaCredentials.hasAccess(user), true);
        karmaCredentials.rate(user, 1);
        assertEq(karmaCredentials.ratingOf(user), 1);
    }

    function testRateUserWithoutCredentialAccess() public {
        address user = makeAddr("user");
        assertEq(karmaCredentials.hasAccess(user), false);
        vm.expectRevert("KarmaAccessControluint64: user does not have access");
        karmaCredentials.rate(user, 1);
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
}
