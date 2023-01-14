// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "forge-std/Test.sol";

import "src/CredentialsBurnable.sol";

contract CredentialsBurnableTest is Test {
    CredentialsBurnable public cb;
    CredentialsBurnableHarness public cbh;

    address owner = address(0x69);

    function setUp() public {
        vm.startPrank(owner);
        cb = new CredentialsBurnable("Credentials", "CRED", "https://cred.com/", 100);
        cbh = new CredentialsBurnableHarness("Credentials", "CRED", "https://cred.com/", 100);
        vm.stopPrank();
    }

    function testOwnerCanMint() public {
        vm.startPrank(owner);
        cb.mint(owner, "1", IERC5484.BurnAuth.OwnerOnly);
        vm.stopPrank();
        assertEq(cb.totalSupply(), 1);
    }

    function testNotOwnerCannotMint() public {
        vm.expectRevert("Ownable: caller is not the owner");
        cb.mint(owner, "1", IERC5484.BurnAuth.OwnerOnly);
    }

    function testMintCannotExceedMaxSupply() public {
        vm.startPrank(owner);
        for (uint256 i = 0; i < 100; i++) {
            cb.mint(owner, "1", IERC5484.BurnAuth.OwnerOnly);
        }
        assertEq(cb.totalSupply(), 100);
        vm.expectRevert("Mint would exceed max supply");
        cb.mint(owner, "1", IERC5484.BurnAuth.OwnerOnly);
        vm.stopPrank();
    }

    function testOwnerCanMultiMint() public {
        vm.startPrank(owner);
        address[] memory to = new address[](2);
        to[0] = owner;
        to[1] = owner;
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
            cb.mint(owner, "1", IERC5484.BurnAuth.OwnerOnly);
        }
        assertEq(cb.totalSupply(), 100);
        address[] memory to = new address[](2);
        to[0] = owner;
        to[1] = owner;
        string[] memory uri = new string[](2);
        uri[0] = "1";
        uri[1] = "2";
        IERC5484.BurnAuth[] memory bAuth = new IERC5484.BurnAuth[](2);
        bAuth[0] = IERC5484.BurnAuth.OwnerOnly;
        bAuth[1] = IERC5484.BurnAuth.OwnerOnly;
        vm.expectRevert("Mint would exceed max supply");
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
        vm.expectRevert("to, uri, and bAuth arrays must be the same length");
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
        vm.expectRevert("to, uri, and bAuth arrays must be the same length");
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
        vm.expectRevert("to, uri, and bAuth arrays must be the same length");
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
        vm.expectRevert("Ownable: caller is not the owner");
        cb.multiMint(to, uri, bAuth);
    }

    function testOwnerCanSetBaseURI() public {
        vm.startPrank(owner);
        cbh.setBaseURI("https://example777.com/");
        vm.stopPrank();
        assertEq(cbh.exposed_baseURI(), "https://example777.com/");
    }
}

contract CredentialsBurnableHarness is CredentialsBurnable {
    constructor(string memory name, string memory symbol, string memory baseURI, uint256 maxSupply)
        CredentialsBurnable(name, symbol, baseURI, maxSupply)
    {}

    function exposed_baseURI() public view returns (string memory) {
        return _baseURI();
    }
}
