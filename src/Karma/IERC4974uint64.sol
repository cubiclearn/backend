// SPDX-License-Identifier: CC0

pragma solidity ^0.8.0;

/// @title EIP-4974 Ratings with uint64 ratings
/// @dev Interface for a contract that assigns ratings to addresses.
///  Note: the EIP-165 identifier for this interface is #######.
///  Must initialize contracts with an `operator` address that is not `address(0)`.
interface IERC4974uint64 {
    /// @dev Emits when operator changes.
    ///  MUST emit when `operator` changes by any mechanism.
    ///  MUST ONLY emit by `setOperator`.
    event NewOperator(address indexed _operator);

    /// @dev Emits when operator issues a rating.
    ///  MUST emit when rating is assigned by any mechanism.
    ///  MUST ONLY emit by `rate`.
    event Rating(address _rated, uint64 _rating);

    /// @dev Emits when operator removes a rating.
    ///  MUST emit when rating is removed by any mechanism.
    ///  MUST ONLY emit by `remove`.
    event Removal(address _removed);

    /// @notice Appoint operator authority.
    /// @dev MUST throw unless `msg.sender` is `operator`.
    ///  MUST throw if `operator` address is either already current `operator`
    ///  or is the zero address.
    ///  MUST emit an `Appointment` event.
    /// @param _operator New operator of the smart contract.
    function setOperator(address _operator) external;

    /// @notice Rate an address.
    ///  MUST emit a Rating event with each successful call.
    /// @param _rated Address to be rated.
    /// @param _rating Total EXP tokens to reallocate.
    function rate(address _rated, uint64 _rating) external;

    /// @notice Remove a rating from an address.
    ///  MUST emit a Remove event with each successful call.
    /// @param _removed Address to be removed.
    function removeRating(address _removed) external;

    /// @notice Return a rated address' rating.
    /// @dev MUST register each time `Rating` emits.
    ///  SHOULD throw for queries about the zero address.
    /// @param _rated An address for whom to query rating.
    /// @return uint64 The rating assigned.
    function ratingOf(address _rated) external view returns (uint64);
}
