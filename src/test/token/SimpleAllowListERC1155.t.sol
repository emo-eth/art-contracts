// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import {DSTestPlusPlus} from "../helpers/DSTestPlusPlus.sol";
import {SimpleAllowListERC1155} from "../../token/SimpleAllowListERC1155.sol";
import {User} from "../helpers/User.sol";
import {Consts} from "../helpers/Consts.sol";
import {ReentrantERC1155Receiver} from "../helpers/ReentrantERC1155Receiver.sol";

import {ERC1155Receiver} from "oz/token/ERC1155/utils/ERC1155Receiver.sol";

contract SimpleAllowListERC1155Test is
    DSTestPlusPlus,
    ReentrantERC1155Receiver
{
    SimpleAllowListERC1155 nft;
    User internal user = new User();
    Consts CONSTS = new Consts();
    bytes32[] proof;
    uint256 mintPrice = 0.1 ether;

    string private constant name = "Test";
    string private constant symbol = "TEST";
    string private constant uri1 = "ipfs://1234/{id}";
    string private constant uri2 = "ipfs://5678/{id}";

    function setUp() public {
        nft = new SimpleAllowListERC1155(name, symbol, uri1, 2, 5);
        nft.setMerkleRoot(CONSTS.DEFAULT_ROOT());
        nft.setUnlockTime(0);
        proof = CONSTS.DEFAULT_PROOF();
    }

    function testCanMintAllowList() public {
        nft.mintAllowList{value: mintPrice}(0, proof);
        assertEq(1, nft.balanceOf(address(this), 0));
        assertEq(1, nft.numMinted(0));
    }

    function testRedeemsMintAllowList() public {
        nft.mintAllowList{value: mintPrice}(1, proof);
        nft.mintAllowList{value: mintPrice}(1, proof);
    }

    //canMint(_id)
    function testMaxMintedMintAllowList() public {
        nft.bulkMint(address(this), 0, nft.MAX_SUPPLY_PER_ID());
        vm.expectRevert(errorSig("MaxSupplyForID()"));
        nft.mintAllowList{value: mintPrice}(0, proof);
    }

    //canMint(_id)
    function testAllowListIncrementsSupplyForId() public {
        nft.mintAllowList{value: mintPrice}(0, proof);
        uint256 MAX_SUPPLY = nft.MAX_SUPPLY_PER_ID();
        vm.expectRevert(errorSig("MaxSupplyForID()"));
        nft.bulkMint(address(this), 0, MAX_SUPPLY);
    }

    //includesCorrectPayment
    function testIncorrectPaymentMintAllowList() public {
        vm.expectRevert(errorSig("IncorrectPayment()"));
        nft.mintAllowList{value: 0.11 ether}(0, proof);
    }

    //nonReentrant
    function testReentrantMintAllowList() public {
        reentrant = true;
        vm.expectRevert("REENTRANCY");
        nft.mintAllowList{value: mintPrice}(1, proof);
    }

    //notYetRedeemed
    //redeemsAllowList
    function testRedeemedMintAllowList() public {
        nft.mintAllowList{value: mintPrice}(1, proof);
        nft.mintAllowList{value: mintPrice}(1, proof);
        vm.expectRevert(errorSig("MaxAllowListRedemptions()"));
        nft.mintAllowList{value: mintPrice}(1, proof);
    }

    //onlyAllowListed(_proof)
    function testNotAllowListedMintAllowList() public {
        nft.setMerkleRoot(bytes32(0));
        vm.expectRevert(errorSig("NotAllowListed()"));

        nft.mintAllowList{value: mintPrice}(0, proof);
    }

    //whenNotPaused
    function testPausedMintAllowList() public {
        nft.pause();
        vm.expectRevert("Pausable: paused");
        nft.mintAllowList{value: mintPrice}(0, proof);
    }

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata
    ) external override returns (bytes4) {
        if (reentrant) {
            SimpleAllowListERC1155(msg.sender).mintAllowList{value: mintPrice}(
                0,
                proof
            );
        }
        return 0xf23a6e61;
    }
}
