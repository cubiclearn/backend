// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "src/Karma/Karma.sol";
import "src/Credentials/SBT.sol";

/// @title Karma with access restricted to user with credentials
/// @author donnoh.eth
/// @notice This contract is a wrapper around Karma contract. The Karma operator can be different
/// from the Credentials operator.

contract KarmaAccessControl is Karma {
    SoulboundNFT public credentials;

    constructor(SoulboundNFT _credentials) Karma() {
        credentials = _credentials;
    }

    function hasAccess(address _user) public view returns (bool) {
        return credentials.balanceOf(_user) > 0;
    }

    function rate(address _user, int8 _rating) external override {
        require(hasAccess(_user), "KarmaAccessControl: user does not have access");
        super._rate(_user, _rating);
    }
}
