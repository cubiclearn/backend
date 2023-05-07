// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "forge-std/Test.sol";
import "src/Credentials/Credentials.sol";

contract CredentialsTest is Test {
    Credentials public creds;
    Receiver public receiver;

    address owner = makeAddr("owner");
    address notOwner = makeAddr("notOwner");

    function setUp() public {
        vm.startPrank(owner);
        creds = new Credentials("Credentials", "CREDS", "https://creds.com/", 100);
        receiver = new Receiver();
        vm.stopPrank();
    }

    function testOwnerCanMintToOthers() public {
        vm.prank(owner);
        creds.mint(address(receiver), "1.json");
        assertEq(creds.totalSupply(), 1);
        assertEq(creds.ownerOf(0), address(receiver));
    }

    function testOwnerCanMintToSelf() public {
        vm.prank(owner);
        creds.mint(owner, "1.json");
        assertEq(creds.totalSupply(), 1);
        assertEq(creds.ownerOf(0), owner);
    }

    function testNotOwnerCannotMint() public {
        vm.startPrank(notOwner);
        vm.expectRevert("Ownable: caller is not the owner");
        creds.mint(address(receiver), "1.json");
        vm.stopPrank();
    }

    function testCannotExceedMaxSupply() public {
        vm.startPrank(owner);
        for (uint256 i = 0; i < 100; i++) {
            creds.mint(owner, "1.json");
        }
        vm.expectRevert("Mint would exceed max supply");
        creds.mint(owner, "1.json");
    }

    function testMultiMintCannotExceedMaxSupply() public {
        vm.startPrank(owner);
        address[] memory to = new address[](100);
        for (uint256 i = 0; i < 100; i++) {
            to[i] = owner;
        }
        string[] memory uri = new string[](100);
        for (uint256 i = 0; i < 100; i++) {
            uri[i] = "1.json";
        }
        creds.multiMint(to, uri);
        vm.expectRevert("Mint would exceed max supply");
        creds.multiMint(to, uri);
    }

    function testOwnerCanMultiMint() public {
        vm.prank(owner);
        address[] memory to = new address[](2);
        to[0] = owner;
        to[1] = address(receiver);
        string[] memory uri = new string[](2);
        uri[0] = "1.json";
        uri[1] = "2.json";
        creds.multiMint(to, uri);
        assertEq(creds.totalSupply(), 2);
        assertEq(creds.ownerOf(0), owner);
        assertEq(creds.ownerOf(1), address(receiver));
        assertEq(creds.tokenURI(0), "https://creds.com/1.json");
        assertEq(creds.tokenURI(1), "https://creds.com/2.json");
    }

    function testMultiMintWithDifferentLengths() public {
        address[] memory to = new address[](2);
        to[0] = owner;
        to[1] = address(receiver);
        string[] memory uri = new string[](1);
        uri[0] = "1.json";
        vm.prank(owner);
        vm.expectRevert("to and uri arrays must be the same length");
        creds.multiMint(to, uri);
    }

    event Locked(uint256 tokenId);

    function testLockedEventIsEmitted() public {
        vm.prank(owner);
        vm.expectEmit(false, false, false, true);
        emit Locked(0);
        creds.mint(owner, "1.json");
    }

    function testSetBaseURI() public {
        vm.prank(owner);
        creds.setBaseURI("https://creds2.com/");
        assertEq(creds.baseURI(), "https://creds2.com/");
    }
}

contract Receiver {
    function onERC721Received(address, address, uint256, bytes calldata) external pure returns (bytes4) {
        return 0x150b7a02;
    }

    constructor() {
        // solhint-disable-previous-line no-empty-blocks
    }
}
