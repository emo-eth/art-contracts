// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import {DSTestPlusPlus} from "../helpers/DSTestPlusPlus.sol";

import {AllowList} from "../../util/AllowList.sol";
import {User} from "../helpers/User.sol";

contract AllowListImpl is AllowList {
    constructor(uint256 _maxRedemptions, bytes32 _merkleRoot)
        AllowList(_maxRedemptions, _merkleRoot)
    {}

    function redeem(bytes32[] calldata _proof)
        external
        onlyAllowListed(_proof)
    {
        _ensureAllowListRedemptionsAvailableAndIncrement(1);
    }

    function getNumRedemptions(address _address)
        external
        view
        returns (uint256)
    {
        return addressRedemptions[_address];
    }
}

contract AllowListTest is DSTestPlusPlus {
    AllowListImpl list;
    User internal user = new User();
    bytes32[] proof;
    bytes32 root;

    function setUp() public {
        list = new AllowListImpl(2, bytes32(0));
        root = bytes32(
            0x0e3c89b8f8b49ac3672650cebf004f2efec487395927033a7de99f85aec9387c
        );
        list.setMerkleRoot(root);
        ///@notice this proof assumes DAPP_TEST_ADDRESS is its default value, 0xb4c79daB8f259C7Aee6E5b2Aa729821864227e84
        proof = [
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
    }

    function testConstructorInitializesProperties() public {
        list = new AllowListImpl(3, bytes32("1234"));
        assertEq(bytes32("1234"), list.merkleRoot());
        assertEq(3, list.MAX_REDEMPTIONS_PER_ADDRESS());
    }

    function testUpdateRoot() public {
        assertEq(root, list.merkleRoot());
        list.setMerkleRoot(bytes32(0));
        assertEq(bytes32(0), list.merkleRoot());
    }

    function testOnlyOwnerCanUpdateRoot() public {
        list.transferOwnership(address(user));
        vm.expectRevert("Ownable: caller is not the owner");
        list.setMerkleRoot(bytes32(0));
    }

    function testIsAllowListed() public {
        assertTrue(list.isAllowListed(proof, address(this)));
    }

    function testIsAllowListedModifierReverts() public {
        list.setMerkleRoot(0);
        vm.expectRevert(errorSig("NotAllowListed()"));
        list.redeem(proof);
    }

    function testRedeemsModifier() public {
        list.redeem(proof);
        list.redeem(proof);
        vm.expectRevert(errorSig("MaxAllowListRedemptions()"));
        list.redeem(proof);
    }
}
