// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "src/Credentials.sol";
import "src/CredentialsBurnable.sol";

contract CredentialsFactory {
    event CredentialsCreated(address indexed creator, address indexed credentials, bool burnable);

    function createCredentials(string memory _name, string memory _symbol, string memory _bUri, uint256 maxSupply)
        external
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
    ) external returns (address) {
        CredentialsBurnable credentials = new CredentialsBurnable(_name, _symbol, _bUri, maxSupply);
        credentials.transferOwnership(msg.sender);
        emit CredentialsCreated(msg.sender, address(credentials), true);
        return address(credentials);
    }
}
