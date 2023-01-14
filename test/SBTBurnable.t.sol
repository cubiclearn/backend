// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "forge-std/Test.sol";
import "../src/SBTBurnable.sol";
import "../src/IERC5484.sol";

contract SbtBurnableTest is Test {
    SoulboundNFTBurnable public sbtb;
    SoulboundNftBurnableHarness public sbtbHarness;
    Receiver public receiver;

    address public bob = address(0xb0b);

    function setUp() public {
        sbtb = new SoulboundNFTBurnable("Soulbound NFT", "SBT", "https://sbt.com/");
        sbtbHarness = new SoulboundNftBurnableHarness("Soulbound NFT", "SBT", "https://sbt.com/");
        receiver = new Receiver();
        vm.stopPrank();
    }

    function testFuzzIssuer(address issuer) public {
        sbtbHarness.exposed_safeMint(address(receiver), 0);
        sbtbHarness.exposed_setIssuer(0, issuer);
        assertEq(sbtbHarness.issuerOf(0), issuer);
    }

    function testCannotSetIssuerOfNonexistentToken() public {
        vm.expectRevert("Token does not exist");
        sbtbHarness.exposed_setIssuer(0, bob);
    }

    function testCannotGetIssuerOfNonexistentToken() public {
        vm.expectRevert("Token does not exist");
        sbtbHarness.issuerOf(0);
    }

    function testBurnAuth() public {
        sbtbHarness.exposed_safeMint(bob, 0);
        assert(sbtbHarness.burnAuth(0) == IERC5484.BurnAuth.IssuerOnly);
        sbtbHarness.exposed_setBurnAuth(0, IERC5484.BurnAuth.OwnerOnly);
        assert(sbtbHarness.burnAuth(0) == IERC5484.BurnAuth.OwnerOnly);
        sbtbHarness.exposed_setBurnAuth(0, IERC5484.BurnAuth.Both);
        assert(sbtbHarness.burnAuth(0) == IERC5484.BurnAuth.Both);
        sbtbHarness.exposed_setBurnAuth(0, IERC5484.BurnAuth.Neither);
        assert(sbtbHarness.burnAuth(0) == IERC5484.BurnAuth.Neither);
    }

    function testCannotSetBurnAuthOfNonexistentToken() public {
        vm.expectRevert("Token does not exist");
        sbtbHarness.exposed_setBurnAuth(0, IERC5484.BurnAuth.OwnerOnly);
    }

    function testCannotGetBurnAuthOfNonexistentToken() public {
        vm.expectRevert("Token does not exist");
        sbtbHarness.burnAuth(0);
    }

    function testSupportsEIP5484Interface() public {
        assertEq(sbtb.supportsInterface(0x0489b56f), true);
    }

    function testCannotTransferToAddressZero() public {
        sbtbHarness.exposed_safeMint(bob, 0);
        vm.prank(bob);
        vm.expectRevert("ERC721: transfer to the zero address");
        sbtbHarness.transferFrom(bob, address(0), 0);
    }

    function testAuthorizedTokenOwnerCanBurn() public {
        sbtbHarness.exposed_safeMint(bob, 0);
        sbtbHarness.exposed_setBurnAuth(0, IERC5484.BurnAuth.OwnerOnly);
        vm.prank(bob);
        sbtbHarness.burn(0);
        assertEq(sbtbHarness.balanceOf(bob), 0);
    }

    function testAuthorizedTokenIssuerCanBurn() public {
        sbtbHarness.exposed_safeMint(bob, 0);
        sbtbHarness.exposed_setBurnAuth(0, IERC5484.BurnAuth.IssuerOnly);
        sbtbHarness.exposed_setIssuer(0, address(this));
        sbtbHarness.burn(0);
        assertEq(sbtbHarness.balanceOf(bob), 0);
    }

    function testAuthorizedTokenOwnerOrIssuerCanBurn() public {
        sbtbHarness.exposed_safeMint(bob, 0);
        sbtbHarness.exposed_safeMint(bob, 1);
        sbtbHarness.exposed_setBurnAuth(0, IERC5484.BurnAuth.Both);
        sbtbHarness.exposed_setBurnAuth(1, IERC5484.BurnAuth.Both);
        sbtbHarness.exposed_setIssuer(1, address(this));
        vm.prank(bob);
        sbtbHarness.burn(0);
        assertEq(sbtbHarness.balanceOf(bob), 1);
        sbtbHarness.burn(1);
        assertEq(sbtbHarness.balanceOf(bob), 0);
    }

    function testNeitherAuthorizationTokenOwnerCannotBurn() public {
        sbtbHarness.exposed_safeMint(bob, 0);
        sbtbHarness.exposed_setBurnAuth(0, IERC5484.BurnAuth.Neither);
        vm.prank(bob);
        vm.expectRevert("Caller is not authorized to burn this token");
        sbtbHarness.burn(0);
    }

    function testNeitherAuthorizationIssuerCannotBurn() public {
        sbtbHarness.exposed_safeMint(bob, 0);
        sbtbHarness.exposed_setBurnAuth(0, IERC5484.BurnAuth.Neither);
        sbtbHarness.exposed_setIssuer(0, address(this));
        vm.expectRevert("Caller is not authorized to burn this token");
        sbtbHarness.burn(0);
    }

    function testOwnerAuthorizationIssuerCannotBurn() public {
        sbtbHarness.exposed_safeMint(bob, 0);
        sbtbHarness.exposed_setBurnAuth(0, IERC5484.BurnAuth.OwnerOnly);
        sbtbHarness.exposed_setIssuer(0, address(this));
        vm.expectRevert("Caller is not authorized to burn this token");
        sbtbHarness.burn(0);
    }

    function testIssuerAuthorizationTokenOwnerCannotBurn() public {
        sbtbHarness.exposed_safeMint(bob, 0);
        sbtbHarness.exposed_setBurnAuth(0, IERC5484.BurnAuth.IssuerOnly);
        sbtbHarness.exposed_setIssuer(0, address(this));
        vm.expectRevert("Caller is not authorized to burn this token");
        vm.prank(bob);
        sbtbHarness.burn(0);
    }

    function testCannotBurnNonexistentToken() public {
        vm.expectRevert("Token does not exist");
        sbtbHarness.burn(0);
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

contract SoulboundNftBurnableHarness is SoulboundNFTBurnable {
    constructor(string memory name, string memory symbol, string memory baseURI)
        SoulboundNFTBurnable(name, symbol, baseURI)
    {}

    function exposed_setBurnAuth(uint256 tokenId, BurnAuth auth) public {
        _setBurnAuth(tokenId, auth);
    }

    function exposed_setIssuer(uint256 tokenId, address issuer) public {
        _setIssuer(tokenId, issuer);
    }

    function exposed_safeMint(address to, uint256 tokenId) public {
        _safeMint(to, tokenId);
    }
}
