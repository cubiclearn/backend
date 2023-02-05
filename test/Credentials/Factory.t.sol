// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "forge-std/Test.sol";
import "src/Credentials/Factory.sol";

contract FactoryTest is Test {
    CredentialsFactory public factory;

    function setUp() public {
        factory = new CredentialsFactory();
    }

    event CredentialsCreated(address indexed creator, address indexed credentials, bool burnable);

    function testCreateCredentials() public {
        vm.expectEmit(true, false, false, true);
        emit CredentialsCreated(address(this), makeAddr("not checked"), false);
        address credentials = factory.createCredentials("Test", "TST", "https://test.com/", 100);
        Credentials c = Credentials(credentials);
        assertEq(c.owner(), address(this));
        assertEq(c.name(), "Test");
        assertEq(c.symbol(), "TST");
    }

    function testCreateCredentialsBurnable() public {
        vm.expectEmit(true, false, false, true);
        emit CredentialsCreated(address(this), makeAddr("not checked"), true);
        address credentials = factory.createCredentialsBurnable("Test", "TST", "https://test.com/", 100);
        CredentialsBurnable c = CredentialsBurnable(credentials);
        assertEq(c.owner(), address(this));
        assertEq(c.name(), "Test");
        assertEq(c.symbol(), "TST");
    }
}
