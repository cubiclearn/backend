// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./SBTBurnable.sol";

contract CredentialsBurnable is SoulboundNFTBurnable, Ownable {
    uint256 public immutable MAX_SUPPLY;

    constructor(string memory _name, string memory _symbol, string memory _bUri, uint256 maxSupply)
        SoulboundNFTBurnable(_name, _symbol, _bUri)
    {
        MAX_SUPPLY = maxSupply;
    }

    function mint(address to, string memory uri, BurnAuth bAuth) external onlyOwner {
        uint256 ts = totalSupply();
        require(ts + 1 <= MAX_SUPPLY, "Mint would exceed max supply");
        _safeMint(to, ts);
        _setTokenURI(ts, uri);
        _setBurnAuth(ts, bAuth);
        _setIssuer(ts, msg.sender);
        emit Locked(ts);
        emit Issued(msg.sender, to, ts, bAuth);
    }

    function multiMint(address[] memory to, string[] memory uri, BurnAuth[] memory bAuth) external onlyOwner {
        uint256 ts = totalSupply();
        require(ts + to.length <= MAX_SUPPLY, "Mint would exceed max supply");
        require(
            to.length == uri.length && to.length == bAuth.length, "to, uri, and bAuth arrays must be the same length"
        );
        for (uint256 i = 0; i < to.length; i++) {
            _safeMint(to[i], ts + i);
            _setTokenURI(ts + i, uri[i]);
            _setBurnAuth(ts + i, bAuth[i]);
            _setIssuer(ts + i, msg.sender);
            emit Locked(ts + i);
            emit Issued(msg.sender, to[i], ts + i, bAuth[i]);
        }
    }

    function setBaseURI(string memory _bUri) external onlyOwner {
        _setBaseURI(_bUri);
    }
}
