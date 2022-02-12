// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;
import {ReentrantERC1155Receiver} from "./ReentrantERC1155Receiver.sol";

contract User {}

contract UserPlus is User, ReentrantERC1155Receiver {}
