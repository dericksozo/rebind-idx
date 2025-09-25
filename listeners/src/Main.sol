// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "sim-idx-sol/Simidx.sol";
import "sim-idx-generated/Generated.sol";
import "./RebindERC20Listener.sol";

contract Triggers is BaseTriggers {
    function triggers() external override {
        RebindERC20Listener listener = new RebindERC20Listener();
        addTrigger(
            chainAbi(Chains.BaseSepolia, ERC20$Abi()),
            listener.triggerOnTransferEvent()
        );
    }
}
