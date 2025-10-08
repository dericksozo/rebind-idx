// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "sim-idx-generated/Generated.sol";

interface IWatchlistRegistry {
    function isWatched(address wallet) external view returns (bool);
}

/// @title RebindERC20Listener
/// @notice Emits rows for ERC-20 transfers that touch watchlisted addresses on Base Sepolia.
contract RebindERC20Listener is ERC20$OnTransferEvent {
    /// @dev Hard-coded Base Sepolia registry address. Replace with the deployed registry for production use.
    address public constant REGISTRY = 0xE47EA398436E99e1b7639722bB7062F05F9225ae;

    /// @dev Common burn sink used by some tokens in addition to address(0)
    address private constant DEAD = 0x000000000000000000000000000000000000dEaD;

    // Transfer type labels
    string private constant TT_TRANSFER = "TRANSFER";
    string private constant TT_MINT = "MINT";
    string private constant TT_BURN = "BURN";

    // Watchlist side labels
    string private constant WS_FROM = "FROM";
    string private constant WS_TO = "TO";
    string private constant WS_BOTH = "BOTH";

    /// @notice Emitted when a qualifying ERC-20 transfer is observed.
    /// @param chainId The chain identifier where the transfer occurred.
    /// @param token The ERC-20 token contract that emitted the transfer.
    /// @param from The transfer sender.
    /// @param to The transfer recipient.
    /// @param value The transferred amount.
    event RebindTransfer(
        uint64 chainId,
        address token,
        address from,
        address to,
        uint256 value,
        uint256 blockNumber,
        bytes32 txnHash,
        string transferType,
        string watchedSide
    );

    /// @inheritdoc ERC20$OnTransferEvent
    function onTransferEvent(EventContext memory ctx, ERC20$TransferEventParams memory params) external override {
        if (REGISTRY.code.length == 0) {
            return;
        }

        IWatchlistRegistry registry = IWatchlistRegistry(REGISTRY);

        bool watchedFrom = registry.isWatched(params.from);
        bool watchedTo = registry.isWatched(params.to);

        if (watchedFrom || watchedTo) {
            string memory transferType = TT_TRANSFER;
            if (params.from == address(0)) {
                transferType = TT_MINT;
            } else if (params.to == address(0) || params.to == DEAD) {
                transferType = TT_BURN;
            }
            string memory watchedSide = watchedFrom && watchedTo ? WS_BOTH : (watchedFrom ? WS_FROM : WS_TO);
            emit RebindTransfer(
                uint64(block.chainid),
                ctx.txn.call.callee(),
                params.from,
                params.to,
                params.value,
                block.number,
                ctx.txn.hash(),
                transferType,
                watchedSide
            );
        }
    }
}