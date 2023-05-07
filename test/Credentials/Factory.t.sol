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
    event KarmaAccessControlCreated(address indexed creator, address indexed karmaAccessControl);

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

    function testCreateKarmaAccessControl() public {
        address credentials = factory.createCredentials("Test", "TST", "https://test.com/", 100);
        vm.expectEmit(true, false, false, true);
        emit KarmaAccessControlCreated(address(this), makeAddr("not checked"));
        address karmaAccessControl = factory.createKarmaAccessControl(credentials);
        KarmaAccessControluint64 k = KarmaAccessControluint64(karmaAccessControl);
        assertEq(k.operator(), address(this));
        assertEq(address(k.credentials()), credentials);
    }

    function testCreateCourse() public {
        vm.expectEmit(true, false, false, true);
        emit CredentialsCreated(address(this), makeAddr("not checked"), false);
        emit KarmaAccessControlCreated(address(this), makeAddr("not checked"));
        (address credentials, address karmaAccessControl) =
            factory.createCourse(false, "Test", "TST", "https://test.com/", 100);
        Credentials c = Credentials(credentials);
        KarmaAccessControluint64 k = KarmaAccessControluint64(karmaAccessControl);
        assertEq(c.owner(), address(this));
        assertEq(c.name(), "Test");
        assertEq(c.symbol(), "TST");
        assertEq(k.operator(), address(this));
        assertEq(address(k.credentials()), credentials);
    }

    function testCreateCourseBurnable() public {
        vm.expectEmit(true, false, false, true);
        emit CredentialsCreated(address(this), makeAddr("not checked"), true);
        emit KarmaAccessControlCreated(address(this), makeAddr("not checked"));
        (address credentials, address karmaAccessControl) =
            factory.createCourse(true, "Test", "TST", "https://test.com/", 100);
        CredentialsBurnable c = CredentialsBurnable(credentials);
        KarmaAccessControluint64 k = KarmaAccessControluint64(karmaAccessControl);
        assertEq(c.owner(), address(this));
        assertEq(c.name(), "Test");
        assertEq(c.symbol(), "TST");
        assertEq(k.operator(), address(this));
        assertEq(address(k.credentials()), credentials);
    }
}
