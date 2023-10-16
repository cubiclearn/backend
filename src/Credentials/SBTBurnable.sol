// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./SBT.sol";
import "./IERC5484.sol";

contract SoulboundNFTBurnable is SoulboundNFT, IERC5484 {
    mapping(uint256 => BurnAuth) private _burnAuth;
    mapping(uint256 => address) private _issuer;

    modifier onlyAllowed(address from, address to, uint256 tokenId) override {
        require(from == address(0) || !(to == address(0) && _burnAuth[tokenId] == IERC5484.BurnAuth.Neither));
        _;
    }

    constructor(string memory _name, string memory _symbol, string memory _uri) SoulboundNFT(_name, _symbol, _uri) {}

    function burnAuth(uint256 tokenId) external view override returns (BurnAuth) {
        require(_exists(tokenId), "INEXISTENT");
        return _burnAuth[tokenId];
    }

    function issuerOf(uint256 tokenId) external view returns (address) {
        require(_exists(tokenId), "INEXISTENT");
        return _issuer[tokenId];
    }

    function burn(uint256 tokenId) public {
        require(_exists(tokenId), "INEXISTENT");
        address tokenOwner = ownerOf(tokenId);
        require(
            _burnAuth[tokenId] == BurnAuth.OwnerOnly && msg.sender == tokenOwner
                || _burnAuth[tokenId] == BurnAuth.IssuerOnly && msg.sender == _issuer[tokenId]
                || _burnAuth[tokenId] == BurnAuth.Both && (msg.sender == tokenOwner || msg.sender == _issuer[tokenId]),
            "CANNOT_BURN"
        );
        super._burn(tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(SoulboundNFT) returns (bool) {
        return interfaceId == type(IERC5484).interfaceId || super.supportsInterface(interfaceId);
    }

    function _setBurnAuth(uint256 tokenId, BurnAuth auth) internal {
        require(_exists(tokenId), "INEXISTENT");
        _burnAuth[tokenId] = auth;
    }

    function _setIssuer(uint256 tokenId, address issuer) internal {
        require(_exists(tokenId), "INEXISTENT");
        _issuer[tokenId] = issuer;
    }
}
