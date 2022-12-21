// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/SBT.sol";

contract SbtTest is Test {
    SoulboundNFT public sbt;
    Receiver public receiver;

    address owner = address(0x69);
    address notOwner = address(0x42);

    function setUp() public {
        vm.startPrank(owner);
        sbt = new SoulboundNFT("Soulbound NFT", "SBT", "https://sbt.com/", 100);
        receiver = new Receiver();
        vm.stopPrank();
    }

    function testOwnerCanMintToOthers() public {
        vm.prank(owner);
        sbt.mint(address(receiver));
        assertEq(sbt.totalSupply(), 1);
        assertEq(sbt.ownerOf(0), address(receiver));
    }

    function testOwnerCanMintToSelf() public {
        vm.prank(owner);
        sbt.mint(owner);
        assertEq(sbt.totalSupply(), 1);
        assertEq(sbt.ownerOf(0), owner);
    }

    function testNotOwnerCannotMint() public {
        vm.startPrank(notOwner);
        vm.expectRevert("Ownable: caller is not the owner");
        sbt.mint(address(receiver));
        vm.stopPrank();
    }

    function testOwnerCannotTransfer() public {
        vm.startPrank(owner);
        sbt.mint(owner);
        vm.expectRevert("token is locked");
        sbt.transferFrom(owner, address(receiver), 0);
        vm.stopPrank();
    }

    function testReceiverCannotTransfer() public {
        vm.prank(owner);
        sbt.mint(address(receiver));
        vm.startPrank(address(receiver));
        vm.expectRevert("token is locked");
        sbt.transferFrom(address(receiver), owner, 0);
        vm.stopPrank();
    }

    function testCannotExceedMaxSupply() public {
        vm.startPrank(owner);
        for (uint256 i = 0; i < 100; i++) {
            sbt.mint(owner);
        }
        vm.expectRevert("Mint would exceed max supply");
        sbt.mint(owner);
        vm.stopPrank();
    }

    function testSupportsEIP5192Interface() public {
        assertEq(sbt.supportsInterface(0xb45a3c0e), true);
    }

    function testLocked() public {
        vm.prank(owner);
        sbt.mint(owner);
        assertEq(sbt.locked(0), true);
    }

    function testLockedForNonExistentToken() public {
        vm.expectRevert("Token does not exist");
        sbt.locked(0);
    }

    event Locked(uint256 tokenId);

    function testLockedEventIsEmitted() public {
        vm.prank(owner);
        vm.expectEmit(false, false, false, true);
        emit Locked(0);
        sbt.mint(owner);
    }

    function testSetBaseURI() public {
        vm.startPrank(owner);
        SoulboundNftHarness sbtHarness = new SoulboundNftHarness("Soulbound NFT", "SBT", "https://sbt.com/", 100);
        assertEq(sbtHarness.exposed_baseURI(), "https://sbt.com/");
        sbtHarness.setBaseURI("https://sbt2.com/");
        assertEq(sbtHarness.exposed_baseURI(), "https://sbt2.com/");
        vm.stopPrank();
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

contract SoulboundNftHarness is SoulboundNFT {
    constructor(string memory _name, string memory _symbol, string memory _uri, uint256 maxSupply)
        payable
        SoulboundNFT(_name, _symbol, _uri, maxSupply)
    {}

    function exposed_baseURI() public view returns (string memory) {
        return _baseURI();
    }
}
