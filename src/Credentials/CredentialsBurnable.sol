// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "src/Credentials/SBTBurnable.sol";
import "openzeppelin-contracts/contracts/access/AccessControl.sol";

contract CredentialsBurnable is SoulboundNFTBurnable, AccessControl {
    bytes32 public constant MAGISTER_ROLE = keccak256("MAGISTER_ROLE");
    uint256 public nextIndex;

    string private contractURI;

    modifier onlyMagister() {
        require(hasRole(MAGISTER_ROLE, msg.sender), "MAGISTER_ROLE");
        _;
    }

    modifier onlyAdmin() {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "DEFAULT_ADMIN_ROLE");
        _;
    }

    constructor(
        address _admin,
        string memory _name,
        string memory _symbol,
        string memory _bUri,
        string memory _contractURI
    ) SoulboundNFTBurnable(_name, _symbol, _bUri) {
        _grantRole(MAGISTER_ROLE, _admin);
        _grantRole(DEFAULT_ADMIN_ROLE, _admin);
        contractURI = _contractURI;
    }

    function mint(address to, string memory uri, BurnAuth bAuth) external onlyMagister {
        uint256 ts = nextIndex++;
        _safeMint(to, ts);
        _setTokenURI(ts, uri);
        _setBurnAuth(ts, bAuth);
        _setIssuer(ts, msg.sender);
        emit Locked(ts);
        emit Issued(msg.sender, to, ts, bAuth);
    }

    function mintMagister(address to, string memory uri, BurnAuth bAuth) external onlyAdmin {
        uint256 ts = nextIndex++;
        _safeMint(to, ts);
        _setTokenURI(ts, uri);
        _setBurnAuth(ts, bAuth);
        _setIssuer(ts, msg.sender);
        _grantRole(MAGISTER_ROLE, to);
        emit Locked(ts);
        emit Issued(msg.sender, to, ts, bAuth);
    }

    // burn magister and remove role
    function burnMagister(uint256 tokenId) external onlyAdmin {
        address owner = ownerOf(tokenId);
        burn(tokenId);
        _revokeRole(MAGISTER_ROLE, owner);
    }

    function multiMint(address[] memory to, string[] memory uri, BurnAuth[] memory bAuth) external onlyMagister {
        uint256 ts = nextIndex;
        nextIndex += to.length;
        require(to.length == uri.length && to.length == bAuth.length, "LENGTH_MISMATCH");
        for (uint256 i = 0; i < to.length; i++) {
            _safeMint(to[i], ts + i);
            _setTokenURI(ts + i, uri[i]);
            _setBurnAuth(ts + i, bAuth[i]);
            _setIssuer(ts + i, msg.sender);
            emit Locked(ts + i);
            emit Issued(msg.sender, to[i], ts + i, bAuth[i]);
        }
    }

    function setBaseURI(string memory _bUri) external onlyAdmin {
        _setBaseURI(_bUri);
    }

    function setContractURI(string memory _contractURI) external onlyAdmin {
        contractURI = _contractURI;
    }

    function getContractURI() external view returns (string memory) {
        string memory _contractURI = contractURI;
        string memory base = _baseURI();

        if (bytes(base).length == 0) {
            return _contractURI;
        }

        if (bytes(_contractURI).length > 0) {
            return string(abi.encodePacked(base, _contractURI));
        }

        return _contractURI;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(AccessControl, SoulboundNFTBurnable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
