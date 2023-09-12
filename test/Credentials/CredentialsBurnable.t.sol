// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "forge-std/Test.sol";

import "src/Credentials/CredentialsBurnable.sol";

contract CredentialsBurnableTest is Test {
    CredentialsBurnable public cb;

    address owner = makeAddr("owner");

    function setUp() public {
        vm.startPrank(owner);
        cb = new CredentialsBurnable(owner, "Credentials", "CRED", "https://cred.com/", 100);
        vm.stopPrank();
    }

    function testOwnerCanMint() public {
        vm.startPrank(owner);
        cb.mint(owner, "1", IERC5484.BurnAuth.OwnerOnly);
        vm.stopPrank();
        assertEq(cb.totalSupply(), 1);
    }

    function testNotOwnerCannotMint() public {
        vm.expectRevert("MAGISTER_ROLE");
        cb.mint(owner, "1", IERC5484.BurnAuth.OwnerOnly);
    }

    function testMintCannotExceedMaxSupply() public {
        vm.startPrank(owner);
        for (uint256 i = 0; i < 100; i++) {
            cb.mint(vm.addr(i + 1), "1", IERC5484.BurnAuth.OwnerOnly);
        }
        assertEq(cb.totalSupply(), 100);
        vm.expectRevert("MAX_SUPPLY");
        cb.mint(owner, "1", IERC5484.BurnAuth.OwnerOnly);
        vm.stopPrank();
    }

    function testOwnerCanMultiMint() public {
        vm.startPrank(owner);
        address[] memory to = new address[](2);
        to[0] = makeAddr("to1");
        to[1] = makeAddr("to2");
        string[] memory uri = new string[](2);
        uri[0] = "1";
        uri[1] = "2";
        IERC5484.BurnAuth[] memory bAuth = new IERC5484.BurnAuth[](2);
        bAuth[0] = IERC5484.BurnAuth.OwnerOnly;
        bAuth[1] = IERC5484.BurnAuth.OwnerOnly;
        cb.multiMint(to, uri, bAuth);
        vm.stopPrank();
        assertEq(cb.totalSupply(), 2);
    }

    function testMultimintCannotExceedMaxSupply() public {
        vm.startPrank(owner);
        for (uint256 i = 0; i < 100; i++) {
            cb.mint(vm.addr(i + 1), "1", IERC5484.BurnAuth.OwnerOnly);
        }
        assertEq(cb.totalSupply(), 100);
        address[] memory to = new address[](2);
        to[0] = makeAddr("to1");
        to[1] = makeAddr("to2");
        string[] memory uri = new string[](2);
        uri[0] = "1";
        uri[1] = "2";
        IERC5484.BurnAuth[] memory bAuth = new IERC5484.BurnAuth[](2);
        bAuth[0] = IERC5484.BurnAuth.OwnerOnly;
        bAuth[1] = IERC5484.BurnAuth.OwnerOnly;
        vm.expectRevert("MAX_SUPPLY");
        cb.multiMint(to, uri, bAuth);
        vm.stopPrank();
    }

    function testMultimintWithToAndUriLengthsDifferent() public {
        vm.startPrank(owner);
        address[] memory to = new address[](2);
        to[0] = owner;
        to[1] = owner;
        string[] memory uri = new string[](1);
        uri[0] = "1";
        IERC5484.BurnAuth[] memory bAuth = new IERC5484.BurnAuth[](2);
        bAuth[0] = IERC5484.BurnAuth.OwnerOnly;
        bAuth[1] = IERC5484.BurnAuth.OwnerOnly;
        vm.expectRevert("LENGTH_MISMATCH");
        cb.multiMint(to, uri, bAuth);
        vm.stopPrank();
    }

    function testMultimintWithToAndBAuthLengthsDifferent() public {
        vm.startPrank(owner);
        address[] memory to = new address[](2);
        to[0] = owner;
        to[1] = owner;
        string[] memory uri = new string[](2);
        uri[0] = "1";
        uri[1] = "2";
        IERC5484.BurnAuth[] memory bAuth = new IERC5484.BurnAuth[](1);
        bAuth[0] = IERC5484.BurnAuth.OwnerOnly;
        vm.expectRevert("LENGTH_MISMATCH");
        cb.multiMint(to, uri, bAuth);
        vm.stopPrank();
    }

    function testMultimintWithUriAndBAuthLengthsDifferent() public {
        vm.startPrank(owner);
        address[] memory to = new address[](2);
        to[0] = owner;
        to[1] = owner;
        string[] memory uri = new string[](1);
        uri[0] = "1";
        IERC5484.BurnAuth[] memory bAuth = new IERC5484.BurnAuth[](2);
        bAuth[0] = IERC5484.BurnAuth.OwnerOnly;
        bAuth[1] = IERC5484.BurnAuth.OwnerOnly;
        vm.expectRevert("LENGTH_MISMATCH");
        cb.multiMint(to, uri, bAuth);
        vm.stopPrank();
    }

    function testNotOwnerCannotMultiMint() public {
        address[] memory to = new address[](2);
        to[0] = owner;
        to[1] = owner;
        string[] memory uri = new string[](2);
        uri[0] = "1";
        uri[1] = "2";
        IERC5484.BurnAuth[] memory bAuth = new IERC5484.BurnAuth[](2);
        bAuth[0] = IERC5484.BurnAuth.OwnerOnly;
        bAuth[1] = IERC5484.BurnAuth.OwnerOnly;
        vm.expectRevert("MAGISTER_ROLE");
        cb.multiMint(to, uri, bAuth);
    }

    function testOwnerCanSetBaseURI() public {
        vm.startPrank(owner);
        cb.setBaseURI("https://example777.com/");
        vm.stopPrank();
        assertEq(cb.baseURI(), "https://example777.com/");
    }

    function testSupportInterface() public {
        assertTrue(cb.supportsInterface(type(IAccessControl).interfaceId));
    }

    function testAdminCanAssignMagisterRole() public {
        vm.startPrank(owner);
        address magister = makeAddr("Cicerone");
        cb.grantRole(cb.MAGISTER_ROLE(), magister);
        vm.stopPrank();
        assertTrue(cb.hasRole(cb.MAGISTER_ROLE(), magister));
    }

    function testAdminCanSetContractURI() public {
        vm.startPrank(owner);
        cb.setContractURI("https://example777.com/");
        vm.stopPrank();
        assertEq(cb.contractURI(), "https://example777.com/");
    }

    function testNonAdminCannotSetContractURI() public {
        vm.startPrank(makeAddr("Sciura"));
        vm.expectRevert("DEFAULT_ADMIN_ROLE");
        cb.setContractURI("https://example777.com/");
        vm.stopPrank();
    }

    function testMintMagister() public {
        vm.startPrank(owner);
        address magister = makeAddr("Cicerone");
        cb.mintMagister(magister, "1", IERC5484.BurnAuth.OwnerOnly);
        vm.stopPrank();
        assertEq(cb.balanceOf(magister), 1);
        assertEq(cb.hasRole(cb.MAGISTER_ROLE(), magister), true);
    }

    function testMintMagisterBurnAndRemint() public {
        vm.startPrank(owner);
        address magister = makeAddr("Cicerone");
        cb.mintMagister(magister, "1", IERC5484.BurnAuth.IssuerOnly);
        vm.stopPrank();
        assertEq(cb.balanceOf(magister), 1);
        assertEq(cb.ownerOf(0), magister);
        assertEq(cb.hasRole(cb.MAGISTER_ROLE(), magister), true);
        vm.startPrank(owner);
        cb.burn(0);
        cb.revokeRole(cb.MAGISTER_ROLE(), magister);
        assertEq(cb.balanceOf(magister), 0);
        assertEq(cb.hasRole(cb.MAGISTER_ROLE(), magister), false);
        vm.startPrank(owner);
        cb.mintMagister(magister, "1", IERC5484.BurnAuth.IssuerOnly);
        vm.stopPrank();
        assertEq(cb.balanceOf(magister), 1);
        assertEq(cb.ownerOf(1), magister);
        assertEq(cb.hasRole(cb.MAGISTER_ROLE(), magister), true);
    }

    function testMintDiscipulusBurnAndRemint() public {
        vm.startPrank(owner);
        address discipulus = makeAddr("Discipulus");
        cb.mint(discipulus, "1", IERC5484.BurnAuth.IssuerOnly);
        vm.stopPrank();
        assertEq(cb.balanceOf(discipulus), 1);
        assertEq(cb.ownerOf(0), discipulus);
        vm.startPrank(owner);
        cb.burn(0);
        assertEq(cb.balanceOf(discipulus), 0);
        vm.startPrank(owner);
        cb.mint(discipulus, "1", IERC5484.BurnAuth.IssuerOnly);
        vm.stopPrank();
        assertEq(cb.balanceOf(discipulus), 1);
        assertEq(cb.ownerOf(1), discipulus);
    }

    function testMintDiscipulusTwoTokenBurnFirstAndRemint() public {
        vm.startPrank(owner);
        address discipulus = makeAddr("Discipulus");
        cb.mint(discipulus, "1", IERC5484.BurnAuth.IssuerOnly);
        cb.mint(discipulus, "2", IERC5484.BurnAuth.IssuerOnly);
        vm.stopPrank();
        assertEq(cb.balanceOf(discipulus), 2);
        assertEq(cb.ownerOf(0), discipulus);
        assertEq(cb.ownerOf(1), discipulus);
        vm.startPrank(owner);
        cb.burn(0);
        assertEq(cb.balanceOf(discipulus), 1);
        vm.startPrank(owner);
        cb.mint(discipulus, "1", IERC5484.BurnAuth.IssuerOnly);
        vm.stopPrank();
        assertEq(cb.balanceOf(discipulus), 2);
        assertEq(cb.ownerOf(1), discipulus);
        assertEq(cb.ownerOf(2), discipulus);
    }
}
