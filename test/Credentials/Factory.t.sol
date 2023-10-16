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
            factory.createCourse("Test", "TST", "https://test.com/", "https://test.com/", 0, 0);
        CredentialsBurnable c = CredentialsBurnable(credentials);
        KarmaAccessControluint64 k = KarmaAccessControluint64(karmaAccessControl);
        assertTrue(c.hasRole(c.MAGISTER_ROLE(), address(this)));
        assertTrue(c.hasRole(c.getRoleAdmin(c.MAGISTER_ROLE()), address(this)));
        assertEq(c.name(), "Test");
        assertEq(c.symbol(), "TST");
        assertEq(k.operator(), address(0));
        assertTrue(k.isOperator(address(this)));
        assertEq(address(k.credentials()), credentials);
    }
}
