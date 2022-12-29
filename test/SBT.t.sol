// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/SBT.sol";

contract SbtTest is Test {
    SoulboundNFT public sbt;
    SoulboundNftHarness public sbtHarness;
    Receiver public receiver;

    address owner = address(0x69);
    address notOwner = address(0x42);

    function setUp() public {
        vm.startPrank(owner);
        sbt = new SoulboundNFT("Soulbound NFT", "SBT", "https://sbt.com/", 100);
        sbtHarness = new SoulboundNftHarness("Soulbound NFT", "SBT", "https://sbt.com/", 100);
        receiver = new Receiver();
        vm.stopPrank();
    }

    function testOwnerCanMintToOthers() public {
        vm.prank(owner);
        sbt.mint(address(receiver), "1.json");
        assertEq(sbt.totalSupply(), 1);
        assertEq(sbt.ownerOf(0), address(receiver));
    }

    function testOwnerCanMintToSelf() public {
        vm.prank(owner);
        sbt.mint(owner, "1.json");
        assertEq(sbt.totalSupply(), 1);
        assertEq(sbt.ownerOf(0), owner);
    }

    function testNotOwnerCannotMint() public {
        vm.startPrank(notOwner);
        vm.expectRevert("Ownable: caller is not the owner");
        sbt.mint(address(receiver), "1.json");
        vm.stopPrank();
    }

    function testOwnerCanMultiMint() public {
        vm.prank(owner);
        address[] memory to = new address[](2);
        to[0] = owner;
        to[1] = address(receiver);
        string[] memory uri = new string[](2);
        uri[0] = "1.json";
        uri[1] = "2.json";
        sbt.multiMint(to, uri);
        assertEq(sbt.totalSupply(), 2);
        assertEq(sbt.ownerOf(0), owner);
        assertEq(sbt.ownerOf(1), address(receiver));
        assertEq(sbt.tokenURI(0), "https://sbt.com/1.json");
        assertEq(sbt.tokenURI(1), "https://sbt.com/2.json");
    }

    function testOwnerCannotTransfer() public {
        vm.startPrank(owner);
        sbt.mint(owner, "1.json");
        vm.expectRevert("token is locked");
        sbt.transferFrom(owner, address(receiver), 0);
        vm.stopPrank();
    }

    function testReceiverCannotTransfer() public {
        vm.prank(owner);
        sbt.mint(address(receiver), "1.json");
        vm.startPrank(address(receiver));
        vm.expectRevert("token is locked");
        sbt.transferFrom(address(receiver), owner, 0);
        vm.stopPrank();
    }

    function testCannotExceedMaxSupply() public {
        vm.startPrank(owner);
        for (uint256 i = 0; i < 100; i++) {
            sbt.mint(owner, "1.json");
        }
        vm.expectRevert("Mint would exceed max supply");
        sbt.mint(owner, "1.json");
        vm.stopPrank();
    }

    function testMultiMintCannotExceedMaxSupply() public {
        vm.startPrank(owner);
        address[] memory to = new address[](100);
        string[] memory uri = new string[](100);
        for (uint256 i = 0; i < 100; i++) {
            to[i] = owner;
            uri[i] = "1.json";
        }
        sbt.multiMint(to, uri);
        address[] memory to2 = new address[](1);
        string[] memory uri2 = new string[](1);
        to2[0] = owner;
        uri2[0] = "1.json";
        vm.expectRevert("Mint would exceed max supply");
        sbt.multiMint(to2, uri2);
        vm.stopPrank();
    }

    function testSupportsEIP5192Interface() public {
        assertEq(sbt.supportsInterface(0xb45a3c0e), true);
    }

    function testLocked() public {
        vm.prank(owner);
        sbt.mint(owner, "1.json");
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
        sbt.mint(owner, "1.json");
    }

    function testSetBaseURI() public {
        vm.startPrank(owner);
        assertEq(sbtHarness.exposed_baseURI(), "https://sbt.com/");
        sbtHarness.setBaseURI("https://sbt2.com/");
        assertEq(sbtHarness.exposed_baseURI(), "https://sbt2.com/");
        vm.stopPrank();
    }

    function testTokenURI() public {
        vm.prank(owner);
        sbt.mint(owner, "1.json");
        assertEq(sbt.tokenURI(0), "https://sbt.com/1.json");
    }

    function testBurn() public {
        vm.startPrank(owner);
        sbtHarness.mint(owner, "1.json");
        assertEq(sbtHarness.totalSupply(), 1);
        vm.expectRevert("token is locked");
        sbtHarness.exposed_burn(0);
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

    function exposed_burn(uint256 tokenId) public {
        _burn(tokenId);
    }
}
