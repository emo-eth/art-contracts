// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

contract Consts {
    uint256 public immutable DEFAULT_REDEMPTIONS = 2;
    bytes32 public immutable DEFAULT_ROOT =
        bytes32(
            0x0e3c89b8f8b49ac3672650cebf004f2efec487395927033a7de99f85aec9387c
        );

    ///@notice this proof assumes DAPP_TEST_ADDRESS is its default value, 0xb4c79daB8f259C7Aee6E5b2Aa729821864227e84
    bytes32[] public _DEFAULT_PROOF = [
        bytes32(
            0x042a8fd902455b847ec9e1fc2b056c101d23fcb859025672809c57e41981b518
        ),
        bytes32(
            0x9280e7972fa86597b2eadadce706966b57123d3c9ec8da4ba4a4ad94da59f6bf
        ),
        bytes32(
            0xfd669bf3d776ba18645619d460a223f8354d8efa5369f99805c2164fd9e63504
        )
    ];

    function DEFAULT_PROOF() public view returns (bytes32[] memory) {
        return _DEFAULT_PROOF;
    }
}
