// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;
import {DSTestPlus} from "sm/test/utils/DSTestPlus.sol";
import {Test} from "std/Test.sol";

contract DSTestPlusPlus is DSTestPlus, Test {
    function errorSig(string memory signature)
        public
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSignature(signature);
    }

    function emitArrayBytes(bytes[] memory input) internal {
        for (uint256 i = 0; i < input.length; i++) {
            emit log_bytes(input[i]);
        }
    }
}
