// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "src/Credentials/Credentials.sol";
import "src/Credentials/CredentialsBurnable.sol";
import "src/Karma/KarmaAccessControluint64.sol";

contract CredentialsFactory {
    event KarmaAccessControlCreated(address indexed creator, address indexed karmaAccessControl);

    function createCourse(
        string memory _name,
        string memory _symbol,
        string memory _bUri,
        uint256 maxSupply,
        uint64 _baseMagisterKarma,
        uint64 _baseDiscipulusKarma
    ) external returns (address, address) {
        CredentialsBurnable creds;
        creds = CredentialsBurnable(address(new CredentialsBurnable(msg.sender, _name, _symbol, _bUri, maxSupply)));
        address karmaAccessControl =
            address(new KarmaAccessControluint64(CredentialsBurnable(creds), _baseMagisterKarma, _baseDiscipulusKarma));
        emit KarmaAccessControlCreated(msg.sender, address(karmaAccessControl));
        return (address(creds), karmaAccessControl);
    }
}
