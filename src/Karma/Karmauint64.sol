// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "src/Karma/IERC4974uint64.sol";

import "openzeppelin-contracts/contracts/utils/introspection/IERC165.sol";
import "openzeppelin-contracts/contracts/utils/math/Math.sol";

contract Karmauint64 is IERC4974uint64, IERC165 {
    address public operator;
    mapping(address => uint64) public karma;

    modifier onlyOperator() {
        require(this.isOperator(msg.sender), "NOT_OPERATOR");
        _;
    }

    constructor(address _operator) {
        operator = _operator;
    }

    function isOperator(address _operator) external view virtual returns (bool) {
        return _operator == operator;
    }

    function setOperator(address _operator) external override onlyOperator {
        require(_operator != address(0), "ADDRESS_ZERO");
        require(!this.isOperator(_operator), "OPERATOR");
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

    function ratingOf(address _user) public view virtual override returns (uint64) {
        return karma[_user];
    }

    function _roundedSqrt(uint64 _a) internal pure returns (uint64) {
        if (_a == 0) return 0; // handle zero input
        uint64 low = 1;
        uint64 high = _a;
        uint64 sqrtFloor;

        while (low <= high) {
            uint64 mid = (low + high) / 2;
            uint64 midSquared = mid * mid;
            if (midSquared == _a) {
                return mid; // exact square root found
            } else if (midSquared < _a) {
                low = mid + 1;
            } else {
                high = mid - 1;
            }
        }

        sqrtFloor = high; // high will have the floor value of the square root
        uint64 avgSquared = (sqrtFloor * sqrtFloor + (sqrtFloor + 1) * (sqrtFloor + 1)) / 2;

        if (_a >= avgSquared) {
            return sqrtFloor + 1;
        }
        return sqrtFloor;
    }

    function quadraticRatingOf(address _user) external view returns (uint64) {
        uint64 _karma = this.ratingOf(_user);
        return _roundedSqrt(_karma);
    }

    function supportsInterface(bytes4 interfaceID) external pure override returns (bool) {
        return interfaceID == type(IERC4974uint64).interfaceId;
    }

    function _rate(address _user, uint64 _rating) internal {
        karma[_user] = _rating;
        emit Rating(_user, _rating);
    }
}
