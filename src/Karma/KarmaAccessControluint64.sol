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
    uint64 public immutable BASE_MAGISTER_KARMA;
    uint64 public immutable BASE_DISCIPULUS_KARMA;

    function isOperator(address _operator) external view override returns (bool) {
        return credentials.hasRole(credentials.MAGISTER_ROLE(), _operator);
    }

    constructor(CredentialsBurnable _credentials, uint64 _baseMagisterKarma, uint64 _baseDiscipulusKarma)
        Karmauint64(address(0))
    {
        credentials = _credentials;
        BASE_MAGISTER_KARMA = _baseMagisterKarma;
        BASE_DISCIPULUS_KARMA = _baseDiscipulusKarma;
    }

    function getBaseKarma(address _user) public view returns (uint64) {
        require(hasAccess(_user), "NO_CREDENTIALS");
        if (credentials.hasRole(credentials.MAGISTER_ROLE(), _user)) {
            return BASE_MAGISTER_KARMA;
        }
        return BASE_DISCIPULUS_KARMA;
    }

    function ratingOf(address _user) public view override returns (uint64) {
        require(hasAccess(_user), "NO_CREDENTIALS");
        return getBaseKarma(_user) + super.ratingOf(_user);
    }

    function hasAccess(address _user) public view returns (bool) {
        return credentials.balanceOf(_user) > 0;
    }

    function rate(address _user, uint64 _rating) public override onlyOperator {
        require(hasAccess(_user), "NO_CREDENTIALS");
        uint64 baseKarma = getBaseKarma(_user);
        require(_rating >= baseKarma, "RATING_TOO_LOW");
        super._rate(_user, _rating - baseKarma);
    }

    function multiRate(address[] calldata _users, uint64[] calldata _ratings) external onlyOperator {
        require(_users.length == _ratings.length, "LENGTH_MISMATCH");
        for (uint256 i = 0; i < _users.length; i++) {
            rate(_users[i], _ratings[i]);
        }
    }
}
