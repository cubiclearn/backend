// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
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
 *
 */

contract SoulboundNFT is ERC721, ERC721Enumerable, ERC721URIStorage, IERC5192 {
    string private _baseURIextended;

    modifier onlyAllowed(address from, address to, uint256 tokenId) virtual {
        require(from == address(0), "LOCKED");
        _;
    }

    /**
     * @param _name NFT Name
     * @param _symbol NFT Symbol
     * @param _bUri Token URI used for metadata
     */
    constructor(string memory _name, string memory _symbol, string memory _bUri) ERC721(_name, _symbol) {
        _baseURIextended = _bUri;
    }

    function locked(uint256 tokenId) external view override returns (bool) {
        require(_exists(tokenId), "INEXISTENT");
        return true;
    }

    /**
     * @dev Updates the baseURI that will be used to retrieve NFT metadata.
     * @param baseURI_ The baseURI to be used.
     */
    function _setBaseURI(string memory baseURI_) internal virtual {
        _baseURIextended = baseURI_;
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseURIextended;
    }

    function baseURI() external view returns (string memory) {
        return _baseURI();
    }

    // Required Overrides

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        virtual
        override(ERC721, ERC721Enumerable)
        onlyAllowed(from, to, tokenId)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return type(IERC5192).interfaceId == interfaceId || super.supportsInterface(interfaceId);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }
}
