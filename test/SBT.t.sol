// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/Credentials/SBT.sol";

contract SbtTest is Test {
    SoulboundNFT public sbt;
    SoulboundNftHarness public sbtHarness;
    Receiver public receiver;

    address owner = address(0x69);
    address notOwner = address(0x42);

    function setUp() public {
        vm.startPrank(owner);
        sbt = new SoulboundNFT("Soulbound NFT", "SBT", "https://sbt.com/");
        sbtHarness = new SoulboundNftHarness("Soulbound NFT", "SBT", "https://sbt.com/");
        receiver = new Receiver();
        vm.stopPrank();
    }

    function testOwnerCannotTransfer() public {
        vm.startPrank(owner);
        sbtHarness.exposed_safeMint(owner, 0);
        vm.expectRevert("token is locked");
        sbtHarness.safeTransferFrom(owner, address(receiver), 0);
    }

    function testReceiverCannotTransfer() public {
        vm.prank(owner);
        sbtHarness.exposed_safeMint(address(receiver), 0);
        vm.startPrank(address(receiver));
        vm.expectRevert("token is locked");
        sbtHarness.safeTransferFrom(address(receiver), owner, 0);
    }

    function testSupportsEIP5192Interface() public {
        assertEq(sbt.supportsInterface(0xb45a3c0e), true);
    }

    function testLocked() public {
        vm.prank(owner);
        sbtHarness.exposed_safeMint(owner, 0);
        assertEq(sbtHarness.locked(0), true);
    }

    function testLockedForNonExistentToken() public {
        vm.expectRevert("Token does not exist");
        sbt.locked(0);
    }

    function testMint() public {
        vm.prank(owner);
        sbtHarness.exposed_safeMint(address(receiver), 0);
        assertEq(sbtHarness.ownerOf(0), address(receiver));
    }

    function testTokenURI() public {
        vm.prank(owner);
        sbtHarness.exposed_safeMint(owner, 0);
        sbtHarness.exposed_setTokenURI(0, "1.json");
        assertEq(sbtHarness.tokenURI(0), "https://sbt.com/1.json");
    }

    function testBurn() public {
        vm.startPrank(owner);
        sbtHarness.exposed_safeMint(owner, 0);
        assertEq(sbtHarness.totalSupply(), 1);
        vm.expectRevert("token is locked");
        sbtHarness.exposed_burn(0);
    }
}

contract Receiver {
    function onERC721Received(address, address, uint256, bytes memory) public pure returns (bytes4) {
        return 0x150b7a02;
    }

    constructor() {
        // solhint-disable-previous-line no-empty-blocks
    }
}

contract SoulboundNftHarness is SoulboundNFT {
    constructor(string memory _name, string memory _symbol, string memory _uri)
        payable
        SoulboundNFT(_name, _symbol, _uri)
    {}

    function exposed_setTokenURI(uint256 tokenId, string memory uri) public {
        _setTokenURI(tokenId, uri);
    }

    function exposed_burn(uint256 tokenId) public {
        _burn(tokenId);
    }

    function exposed_safeMint(address to, uint256 tokenId) public {
        _safeMint(to, tokenId);
    }
}
