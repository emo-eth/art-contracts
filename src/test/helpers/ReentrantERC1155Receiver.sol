// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;
import {ERC1155TokenReceiver} from "../../token/ERC1155.sol";
import {ERC1155ExtendedImpl} from "./ERC1155ExtendedImpl.sol";

import {ERC1155Receiver} from "oz/token/ERC1155/utils/ERC1155Receiver.sol";

contract ReentrantERC1155Receiver is ERC1155Receiver {
    bool internal reentrant = false;

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata
    ) external virtual override returns (bytes4) {
        if (reentrant) {
            ERC1155ExtendedImpl(msg.sender).mint{value: 0.1 ether}(0);
        }
        return 0xf23a6e61;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] calldata,
        uint256[] calldata,
        bytes calldata
    ) external pure override returns (bytes4) {
        return 0xbc197c81;
    }
}
