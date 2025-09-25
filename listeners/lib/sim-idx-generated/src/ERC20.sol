// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "lib/sim-idx-sol/src/Triggers.sol";
import "lib/sim-idx-sol/src/Context.sol";

function ERC20$Abi() pure returns (Abi memory) {
    return Abi("ERC20");
}

struct ERC20$TransferEventParams {
    address from;
    address to;
    uint256 value;
}

abstract contract ERC20$OnTransferEvent {
    function onTransferEvent(EventContext memory ctx, ERC20$TransferEventParams memory params) virtual external;

    function triggerOnTransferEvent() external view returns (Trigger memory) {
        return Trigger({
            abiName: "ERC20",
            selector: bytes32(0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef),
            triggerType: TriggerType.EVENT,
            listenerCodehash: address(this).codehash,
            handlerSelector: this.onTransferEvent.selector
        });
    }
}
