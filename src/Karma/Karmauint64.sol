// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "src/Karma/IERC4974uint64.sol";

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

contract Karmauint64 is IERC4974uint64, IERC165 {
    address public operator;
    mapping(address => uint64) public karma;

    modifier onlyOperator() {
        require(msg.sender == operator, "Karma: caller is not the operator");
        _;
    }

    constructor() {
        operator = msg.sender;
    }

    function setOperator(address _operator) external override onlyOperator {
        require(_operator != address(0), "Karma: operator is the zero address");
        require(_operator != operator, "Karma: operator is already set");
        operator = _operator;
        emit NewOperator(_operator);
    }

    function renounceOperator() external onlyOperator {
        operator = address(0);
        emit NewOperator(address(0));
    }

    function rate(address _user, uint64 _rating) external virtual override onlyOperator {
        _rate(_user, _rating);
    }

    function removeRating(address _user) external override onlyOperator {
        delete karma[_user];
        emit Removal(_user);
    }

    function ratingOf(address _user) external view override returns (uint64) {
        return karma[_user];
    }

    function quadraticRatingOf(address _user) external view returns (uint64) {
        uint64 _karma = karma[_user];
        return uint64(Math.sqrt(_karma));
    }

    function supportsInterface(bytes4 interfaceID) external pure override returns (bool) {
        return interfaceID == type(IERC4974uint64).interfaceId;
    }

    function _rate(address _user, uint64 _rating) internal {
        karma[_user] = _rating;
        emit Rating(_user, _rating);
    }
}
