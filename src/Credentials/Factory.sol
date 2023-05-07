// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "src/Credentials/Credentials.sol";
import "src/Credentials/CredentialsBurnable.sol";
import "src/Karma/KarmaAccessControluint64.sol";

contract CredentialsFactory {
    event CredentialsCreated(address indexed creator, address indexed credentials, bool burnable);
    event KarmaAccessControlCreated(address indexed creator, address indexed karmaAccessControl);

    function createCredentials(string memory _name, string memory _symbol, string memory _bUri, uint256 maxSupply)
        public
        returns (address)
    {
        Credentials credentials = new Credentials(_name, _symbol, _bUri, maxSupply);
        credentials.transferOwnership(msg.sender);
        emit CredentialsCreated(msg.sender, address(credentials), false);
        return address(credentials);
    }

    function createCredentialsBurnable(
        string memory _name,
        string memory _symbol,
        string memory _bUri,
        uint256 maxSupply
    ) public returns (address) {
        CredentialsBurnable credentials = new CredentialsBurnable(_name, _symbol, _bUri, maxSupply);
        credentials.transferOwnership(msg.sender);
        emit CredentialsCreated(msg.sender, address(credentials), true);
        return address(credentials);
    }

    function createKarmaAccessControl(address credentials) public returns (address) {
        KarmaAccessControluint64 karmaAccessControl = new KarmaAccessControluint64(Credentials(credentials), msg.sender);
        emit KarmaAccessControlCreated(msg.sender, address(karmaAccessControl));
        return address(karmaAccessControl);
    }

    function createCourse(
        bool isBurnable,
        string memory _name,
        string memory _symbol,
        string memory _bUri,
        uint256 maxSupply
    ) public returns (address, address) {
        Credentials creds;
        if (isBurnable) {
            creds = Credentials(createCredentialsBurnable(_name, _symbol, _bUri, maxSupply));
        } else {
            creds = Credentials(createCredentials(_name, _symbol, _bUri, maxSupply));
        }
        address karmaAccessControl = createKarmaAccessControl(address(creds));
        return (address(creds), karmaAccessControl);
    }
}
