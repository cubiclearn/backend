// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "./IERC5192.sol";

/**
 * @title Soulbound NFT
 * @author Luca Donno (@donnoh_eth)
 * @notice NFT, Soulbound, ERC721
 * @dev ERC721 Soulbound NFT with the following features:
 *
 *  - Deployer can mint to recipients.
 *  - No transfer capability.
 *  - No unlock capability.
 *  - No burn capability.
 *  - Multiple simultaneous mints.
 *
 */

contract SoulboundNFT is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable, IERC5192 {
    string private _baseURIextended;
    uint256 public immutable MAX_SUPPLY;

    /**
     * @param _name NFT Name
     * @param _symbol NFT Symbol
     * @param _uri Token URI used for metadata
     * @param maxSupply Maximum # of NFTs
     */
    constructor(string memory _name, string memory _symbol, string memory _uri, uint256 maxSupply)
        payable
        ERC721(_name, _symbol)
    {
        _baseURIextended = _uri;
        MAX_SUPPLY = maxSupply;
    }

    function locked(uint256 tokenId) external view override returns (bool) {
        require(_exists(tokenId), "Token does not exist");
        return true;
    }

    /**
     * @dev An external method for the owner to mint Soulbound NFTs. Requires that the minted NFTs will not exceed the `MAX_SUPPLY`.
     */
    function mint(address to, string memory uri) external onlyOwner {
        uint256 ts = totalSupply();
        require(ts + 1 <= MAX_SUPPLY, "Mint would exceed max supply");
        _safeMint(to, ts);
        _setTokenURI(ts, uri);
        emit Locked(ts);
    }

    function multiMint(address[] memory to, string[] memory uri) external onlyOwner {
        uint256 ts = totalSupply();
        require(ts + to.length <= MAX_SUPPLY, "Mint would exceed max supply");
        for (uint256 i = 0; i < to.length; i++) {
            _safeMint(to[i], ts + i);
            _setTokenURI(ts + i, uri[i]);
            emit Locked(ts + i);
        }
    }

    /**
     * @dev Updates the baseURI that will be used to retrieve NFT metadata.
     * @param baseURI_ The baseURI to be used.
     */
    function setBaseURI(string memory baseURI_) external onlyOwner {
        _baseURIextended = baseURI_;
    }

    // Required Overrides

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseURIextended;
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        override (ERC721, ERC721Enumerable)
    {
        require(from == address(0), "token is locked");
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function supportsInterface(bytes4 interfaceId) public view override (ERC721, ERC721Enumerable) returns (bool) {
        return type(IERC5192).interfaceId == interfaceId || super.supportsInterface(interfaceId);
    }

    function _burn(uint256 tokenId) internal override (ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId) public view override (ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }
}
