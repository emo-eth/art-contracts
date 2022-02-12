// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import {DSTestPlusPlus} from "../helpers/DsTestPlusPlus.sol";
import {BatchMintAllowList} from "../../util/BatchMintAllowList.sol";
import {User} from "../helpers/User.sol";

contract BatchMintAllowListImpl is BatchMintAllowList {
    constructor(uint256 _maxRedemptions, bytes32 _merkleRoot)
        BatchMintAllowList(_maxRedemptions, _merkleRoot)
    {}

    function trueIfAllowListed(bytes32[] calldata _proof)
        external
        view
        onlyAllowListed(_proof)
        returns (bool)
    {
        return true;
    }

    function redeem(
        MintQuantities calldata _quantities,
        bytes32[] calldata _proof
    )
        external
        onlyAllowListed(_proof)
        checksAndRedeemsBatchAllowListRedemptions(_quantities)
    {}

    function getNumRedemptions(address _address)
        external
        view
        returns (MintQuantities memory)
    {
        return addressRedemptions[_address];
    }
}

contract BatchMintAllowListTest is DSTestPlusPlus {
    BatchMintAllowListImpl list;
    User internal user = new User();
    bytes32[] proof;
    bytes32 root;

    function setUp() public {
        list = new BatchMintAllowListImpl(2, bytes32(0));
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

    function testConstructorInitializesPropertiesBatchMint() public {
        list = new BatchMintAllowListImpl(3, bytes32("1234"));
        assertEq(bytes32("1234"), list.merkleRoot());
        assertEq(3, list.MAX_REDEMPTIONS_PER_ID());
    }

    function testUpdateRoot() public {
        assertEq(root, list.merkleRoot());
        list.setMerkleRoot(bytes32(0));
        assertEq(bytes32(0), list.merkleRoot());
    }

    function testOnlyOwnerCanUpdateRoot() public {
        list.transferOwnership(address(user));
        cheats.expectRevert("Ownable: caller is not the owner");
        list.setMerkleRoot(bytes32(0));
    }

    function testIsAllowListed() public {
        assertTrue(list.isAllowListed(proof, address(this)));
    }

    function testIsAllowListedModifier() public {
        assertTrue(list.trueIfAllowListed(proof));

        list.setMerkleRoot(0);
        cheats.expectRevert(errorSig("NotAllowListed()"));
        list.trueIfAllowListed(proof);
    }

    function testRedeemsModifier() public {
        list.redeem(BatchMintAllowList.MintQuantities(1, 0, 0), proof);
        list.redeem(BatchMintAllowList.MintQuantities(1, 0, 0), proof);
        assertEq(2, list.getNumRedemptions(address(this)).quantity0);
        list.redeem(BatchMintAllowList.MintQuantities(0, 2, 0), proof);
        assertEq(2, list.getNumRedemptions(address(this)).quantity1);
        list.redeem(BatchMintAllowList.MintQuantities(0, 0, 2), proof);
        assertEq(2, list.getNumRedemptions(address(this)).quantity2);
    }

    function testNotYetRedeemedModifier() public {
        list.redeem(BatchMintAllowList.MintQuantities(1, 0, 0), proof);
        list.redeem(BatchMintAllowList.MintQuantities(1, 0, 0), proof);
        cheats.expectRevert(errorSig("MaxAllowListRedemptions()"));

        list.redeem(BatchMintAllowList.MintQuantities(2, 0, 0), proof);
    }
}
