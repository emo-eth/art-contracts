// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;
import {DSTestPlus} from "sm/test/utils/DSTestPlus.sol";
import {CheatCodes} from "./CheatCodes.sol";

contract DSTestPlusPlus is DSTestPlus {
    CheatCodes internal constant cheats = CheatCodes(HEVM_ADDRESS);

    function errorSig(string memory signature)
        public
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSignature(signature);
    }
}
