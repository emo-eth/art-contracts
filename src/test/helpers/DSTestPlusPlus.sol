// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;
import {DSTestPlus} from "sm/test/utils/DSTestPlus.sol";
import {stdCheats, Vm} from "std/stdlib.sol";

contract DSTestPlusPlus is DSTestPlus, stdCheats {
    Vm internal constant vm = vm_std_cheats;

    function errorSig(string memory signature)
        public
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSignature(signature);
    }
}
