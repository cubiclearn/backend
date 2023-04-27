// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "src/Karma/Karmauint64.sol";

import "src/Credentials/SBT.sol";

/// @title Karmauint64 with access restricted to user with credentials
/// @author donnoh.eth
/// @notice This contract is a wrapper around Karmauint64 contract. The Karma operator can be different
/// from the Credentials operator.

contract KarmaAccessControluint64 is Karmauint64 {
    SoulboundNFT public credentials;

    constructor(SoulboundNFT _credentials) Karmauint64() {
        credentials = _credentials;
    }

    function hasAccess(address _user) public view returns (bool) {
        return credentials.balanceOf(_user) > 0;
    }

    function rate(address _user, uint64 _rating) external override {
        require(hasAccess(_user), "KarmaAccessControluint64: user does not have access");
        super._rate(_user, _rating);
    }
}
