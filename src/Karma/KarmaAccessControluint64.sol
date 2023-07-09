// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "src/Karma/Karmauint64.sol";

import "src/Credentials/CredentialsBurnable.sol";

/// @title Karmauint64 with access restricted to user with credentials
/// @author donnoh.eth
/// @notice This contract is a wrapper around Karmauint64 contract. The Karma operator can be different
/// from the Credentials operator.

contract KarmaAccessControluint64 is Karmauint64 {
    CredentialsBurnable public credentials;

    function isOperator(address _operator) external view override returns (bool) {
        return credentials.hasRole(credentials.MAGISTER_ROLE(), _operator);
    }

    constructor(CredentialsBurnable _credentials, address _operator) Karmauint64(_operator) {
        credentials = _credentials;
    }

    function hasAccess(address _user) public view returns (bool) {
        return credentials.balanceOf(_user) > 0;
    }

    function rate(address _user, uint64 _rating) external override onlyOperator {
        require(hasAccess(_user), "NO_CREDENTIALS");
        super._rate(_user, _rating);
    }
}
