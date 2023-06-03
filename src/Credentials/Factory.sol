// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "src/Credentials/Credentials.sol";
import "src/Credentials/CredentialsBurnable.sol";
import "src/Karma/KarmaAccessControluint64.sol";

contract CredentialsFactory {
    event KarmaAccessControlCreated(address indexed creator, address indexed karmaAccessControl);

    function createCourse(
        bool isBurnable,
        string memory _name,
        string memory _symbol,
        string memory _bUri,
        uint256 maxSupply
    ) external returns (address, address) {
        Credentials creds;
        if (isBurnable) {
            creds = Credentials(address(new CredentialsBurnable(_name, _symbol, _bUri, maxSupply)));
            creds.transferOwnership(msg.sender);
        } else {
            creds = Credentials(address(new Credentials(_name, _symbol, _bUri, maxSupply)));
            creds.transferOwnership(msg.sender);
        }
        address karmaAccessControl = address(new KarmaAccessControluint64(Credentials(creds), msg.sender));
        emit KarmaAccessControlCreated(msg.sender, address(karmaAccessControl));
        return (address(creds), karmaAccessControl);
    }
}
