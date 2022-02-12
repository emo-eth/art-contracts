// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import {DSTestPlusPlus} from "../helpers/DSTestPlusPlus.sol";
import {GiftableAllowList} from "../../util/GiftableAllowList.sol";
import {User} from "../helpers/User.sol";

contract GiftableAllowListImpl is GiftableAllowList {
    constructor(uint256 _maxGifts, bytes32 _merkleRoot)
        GiftableAllowList(_maxGifts, _merkleRoot)
    {}

    function trueIfGiftAllowListed(bytes32[] calldata _proof)
        external
        view
        onlyGiftAllowListed(_proof)
        returns (bool)
    {
        return true;
    }

    function redeemGift(bytes32[] calldata _proof)
        external
        onlyGiftAllowListed(_proof)
        checksandRedeemsGiftAllowList
    {}

    function getNumGiftRedemptions(address _address)
        external
        view
        returns (uint256)
    {
        return addressGiftRedemptions[_address];
    }
}

contract GiftableAllowListTest is DSTestPlusPlus {
    GiftableAllowListImpl list;
    User internal user = new User();
    bytes32[] proof;
    bytes32 root;

    function setUp() public {
        root = bytes32(
            0x0e3c89b8f8b49ac3672650cebf004f2efec487395927033a7de99f85aec9387c
        );
        list = new GiftableAllowListImpl(2, root);

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
        list = new GiftableAllowListImpl(3, bytes32("1234"));
        assertEq(bytes32("1234"), list.giftMerkleRoot());
        assertEq(3, list.MAX_GIFT_REDEMPTIONS());
    }

    function testUpdateGiftMerkleRoot() public {
        assertEq(root, list.giftMerkleRoot());
        list.setGiftMerkleRoot(bytes32(0));
        assertEq(bytes32(0), list.giftMerkleRoot());
    }

    function testOnlyOwnerCanUpdateRoot() public {
        list.transferOwnership(address(user));
        cheats.expectRevert("Ownable: caller is not the owner");

        list.setGiftMerkleRoot(bytes32(0));
    }

    function testIsAllowListed() public {
        assertTrue(list.isGiftAllowListed(proof, address(this)));
    }

    function testIsGiftAllowListedModifier() public {
        assertTrue(list.trueIfGiftAllowListed(proof));
        list.setGiftMerkleRoot(0);
        cheats.expectRevert(errorSig("NotGiftAllowListed()"));
        list.trueIfGiftAllowListed(proof);
    }

    function testRedeemsModifier() public {
        assertEq(0, list.getNumGiftRedemptions(address(this)));
        list.redeemGift(proof);
        assertEq(1, list.getNumGiftRedemptions(address(this)));
        list.redeemGift(proof);
        assertEq(2, list.getNumGiftRedemptions(address(this)));
    }
}
