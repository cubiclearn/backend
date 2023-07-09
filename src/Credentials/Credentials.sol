// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "src/Credentials/SBT.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Credentials is SoulboundNFT, Ownable {
    uint256 public immutable MAX_SUPPLY;

    constructor(string memory _name, string memory _symbol, string memory _bUri, uint256 maxSupply)
        payable
        SoulboundNFT(_name, _symbol, _bUri)
    {
        MAX_SUPPLY = maxSupply;
    }

    function mint(address to, string memory uri) external onlyOwner {
        uint256 ts = totalSupply();
        require(ts + 1 <= MAX_SUPPLY, "MAX_SUPPLY");
        _safeMint(to, ts);
        _setTokenURI(ts, uri);
        emit Locked(ts);
    }

    function multiMint(address[] memory to, string[] memory uri) external onlyOwner {
        uint256 ts = totalSupply();
        require(ts + to.length <= MAX_SUPPLY, "MAX_SUPPLY");
        require(to.length == uri.length, "LENGTH_MISMATCH");
        for (uint256 i = 0; i < to.length; i++) {
            _safeMint(to[i], ts + i);
            _setTokenURI(ts + i, uri[i]);
            emit Locked(ts + i);
        }
    }

    function setBaseURI(string memory _bUri) external onlyOwner {
        _setBaseURI(_bUri);
    }
}
