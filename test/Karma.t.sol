// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "forge-std/Test.sol";
import "src/Karma/Karma.sol";

contract KarmaTest is Test {
    Karma public karma;

    function setUp() public {
        karma = new Karma();
    }

    function testOperator() public {
        assertEq(karma.operator(), address(this));
    }

    event NewOperator(address indexed _operator);

    function testSetOperator() public {
        address newOperator = makeAddr("new operator");
        vm.expectEmit(true, false, false, false);
        emit NewOperator(newOperator);
        karma.setOperator(newOperator);
        assertEq(karma.operator(), newOperator);
    }

    function testSetOperatorWithZeroAddress() public {
        vm.expectRevert("Karma: operator is the zero address");
        karma.setOperator(address(0));
    }

    function testSetOperatorWithCurrentOperator() public {
        vm.expectRevert("Karma: operator is already set");
        karma.setOperator(address(this));
    }

    function testRenounceOperator() public {
        vm.expectEmit(true, false, false, false);
        emit NewOperator(address(0));
        karma.renounceOperator();
        assertEq(karma.operator(), address(0));
    }

    event Rating(address _rated, int8 _rating);

    function testRate() public {
        address user = makeAddr("user");
        int8 rating = 1;
        vm.expectEmit(true, false, false, false);
        emit Rating(user, rating);
        karma.rate(user, rating);
        assertEq(karma.ratingOf(user), rating);
    }

    event Removal(address _rated);

    function testRemoveRating() public {
        address user = makeAddr("user");
        int8 rating = 1;
        karma.rate(user, rating);
        vm.expectEmit(true, false, false, false);
        emit Removal(user);
        karma.removeRating(user);
        assertEq(karma.ratingOf(user), 0);
    }

    function testSupportsInterface() public {
        assertEq(karma.supportsInterface(type(IERC4974).interfaceId), true);
    }
}
