// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title WatchlistRegistry
/// @notice Minimal owner-controlled registry that tracks watched wallet addresses.
contract WatchlistRegistry {
    /// @notice The wallet allowed to manage the registry entries.
    address public immutable owner;

    /// @notice Mapping of wallet address to watchlist membership.
    mapping(address => bool) private _watched;

    /// @notice Error thrown when a non-owner attempts to call an owner-only function.
    error NotOwner();

    /// @notice Emitted every time a wallet is added or removed from the watchlist.
    /// @param wallet The wallet whose watch status changed.
    /// @param watched The new watch status for the wallet.
    event Watch(address indexed wallet, bool watched);

    /// @param _owner The address allowed to manage watchlist membership.
    constructor(address _owner) {
        owner = _owner;
    }

    /// @notice Reverts if the caller is not the registry owner.
    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    /// @notice Returns whether a wallet is currently watched.
    /// @param wallet The address to query.
    /// @return True if the wallet is watched, false otherwise.
    function isWatched(address wallet) external view returns (bool) {
        return _watched[wallet];
    }

    /// @notice Adds or removes a wallet from the watchlist.
    /// @param wallet The wallet to modify.
    /// @param watched The desired watch status for the wallet.
    function setWatched(address wallet, bool watched) external onlyOwner {
        _watched[wallet] = watched;
        emit Watch(wallet, watched);
    }
}
