// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "forge-std/Test.sol";
import "src/Credentials/Factory.sol";

contract FactoryTest is Test {
    CredentialsFactory public factory;

    function setUp() public {
        factory = new CredentialsFactory();
    }

    function testCreateCourse() public {
        (address credentials, address karmaAccessControl) =
            factory.createCourse("Test", "TST", "https://test.com/", 100);
        Credentials c = Credentials(credentials);
        KarmaAccessControluint64 k = KarmaAccessControluint64(karmaAccessControl);
        assertEq(c.owner(), address(this));
        assertEq(c.name(), "Test");
        assertEq(c.symbol(), "TST");
        assertEq(k.operator(), address(this));
        assertEq(address(k.credentials()), credentials);
    }
}
