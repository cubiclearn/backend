// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/SBT.sol";

contract SbtTest is Test {
    SoulboundNFT public sbt;
    Receiver public receiver;

    address owner = address(0x69);

    function setUp() public {
        vm.startPrank(owner);
        sbt = new SoulboundNFT("Soulbound NFT", "SBT", "https://sbt.com/", 100);
        receiver = new Receiver();
        vm.stopPrank();
    }

    function testMint() public {
        vm.prank(owner);
        sbt.mint(address(receiver));
        assertEq(sbt.totalSupply(), 1);
    }

    function testOwnerTransfer() public {
        vm.startPrank(owner);
        sbt.mint(owner);
        sbt.transferFrom(owner, address(receiver), 0);
        vm.stopPrank();
        assertEq(sbt.totalSupply(), 1);
    }
}

contract Receiver {
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure returns (bytes4) {
        return 0x150b7a02;
    }

    constructor() {
        // solhint-disable-previous-line no-empty-blocks
    }
}

