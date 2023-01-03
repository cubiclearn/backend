// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SBT.sol";
import "./IERC5484.sol";

contract SoulboundNFTBurnable is SoulboundNFT, IERC5484 {
    mapping(uint256 => BurnAuth) private _burnAuth;
    mapping(uint256 => address) private _issuer;

    constructor(string memory _name, string memory _symbol, string memory _uri)
        payable
        SoulboundNFT(_name, _symbol, _uri)
    {}

    function burnAuth(uint256 tokenId) external view override returns (BurnAuth) {
        require(_exists(tokenId), "Token does not exist");
        return _burnAuth[tokenId];
    }

    function burn(uint256 tokenId) external {
        require(_exists(tokenId), "Token does not exist");
        address tokenOwner = ownerOf(tokenId);
        if (tokenOwner != msg.sender && msg.sender != _issuer[tokenId]) {
            if (_burnAuth[tokenId] == BurnAuth.OwnerOnly) {
                revert("Only the owner can burn this token");
            } else if (_burnAuth[tokenId] == BurnAuth.IssuerOnly) {
                revert("Only the issuer can burn this token");
            } else if (_burnAuth[tokenId] == BurnAuth.Both) {
                revert("Only the owner or issuer can burn this token");
            } else {
                revert("No one can burn this token");
            }
        }
        super._burn(tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override (SoulboundNFT) returns (bool) {
        return interfaceId == type(IERC5484).interfaceId || super.supportsInterface(interfaceId);
    }

    function _setBurnAuth(uint256 tokenId, BurnAuth auth) internal {
        require(_exists(tokenId), "Token does not exist");
        _burnAuth[tokenId] = auth;
    }

    function _setIssuer(uint256 tokenId, address issuer) internal {
        require(_exists(tokenId), "Token does not exist");
        _issuer[tokenId] = issuer;
    }
}
