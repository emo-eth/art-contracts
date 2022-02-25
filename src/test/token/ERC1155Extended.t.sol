// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import {DSTestPlusPlus} from "../helpers/DSTestPlusPlus.sol";
import {ERC1155Extended} from "../../token/ERC1155Extended.sol";
import {Consts} from "../helpers/Consts.sol";
import {User} from "../helpers/User.sol";
import {ReentrantERC1155Receiver} from "../helpers/ReentrantERC1155Receiver.sol";
import {ERC1155ExtendedImpl} from "../helpers/ERC1155ExtendedImpl.sol";
import {ERC1155Receiver} from "oz/token/ERC1155/utils/ERC1155Receiver.sol";
import {ERC1155TokenReceiver} from "../../token/ERC1155.sol";
import {ERC165} from "oz/utils/introspection/ERC165.sol";

contract UserPlus is User, ReentrantERC1155Receiver {}

contract ERC1155ExtendedTest is DSTestPlusPlus, ReentrantERC1155Receiver {
    ERC1155ExtendedImpl test;
    Consts CONSTS = new Consts();
    UserPlus user = new UserPlus();
    uint256 mintPrice = 0.1 ether;

    function setUp() public {
        test = new ERC1155ExtendedImpl(
            "Test",
            "TEST",
            "ipfs://12345/{id}",
            mintPrice,
            3,
            100,
            5,
            0,
            address(5)
        );
    }

    function testOwnerCanSetMintPrice() public {
        test.setMintPrice(0.11 ether);
        assertEq(0.11 ether, test.mintPrice());
        test.transferOwnership(address(user));
        cheats.expectRevert("Ownable: caller is not the owner");
        test.setMintPrice(0.111 ether);
    }

    function testOwnerCanBulkMint() public {
        test.bulkMint(address(this), 0, 10);
        assertEq(10, test.balanceOf(address(this), 0));
        assertEq(10, test.numMinted(0));
    }

    function testOnlyOwnerCanBulkMint() public {
        test.transferOwnership(address(user));
        cheats.expectRevert("Ownable: caller is not the owner");
        test.bulkMint(address(this), 0, 10);
    }

    function testMint() public {
        test.mint{value: mintPrice}(0);
        assertEq(1, test.balanceOf(address(this), 0));
        assertEq(1, test.numMinted(0));
    }

    function testMintAfterUnlock() public {
        test.setUnlockTime(100);
        hevm.warp(101);
        test.mint{value: mintPrice}(0);
    }

    function testCanMintMaxId() public {
        test.mint{value: mintPrice}(2);
        assertEq(1, test.balanceOf(address(this), 2));
    }

    function testMintInvalidId() public {
        assertEq(0, address(test).balance);
        cheats.expectRevert(errorSig("InvalidOptionID()"));
        test.mint{value: mintPrice}(3);
        // test invalid mint does not consume ether
        assertEq(0, address(test).balance);
    }

    // canMint(_id)
    function testMintMaxMintedBulk() public {
        test.bulkMint(address(this), 0, 100);
        cheats.expectRevert(errorSig("MaxSupplyForID()"));
        test.mint{value: mintPrice}(0);
    }

    function testFailOverflowBulkMint() public {
        test.bulkMint(address(this), 0, 99);
        uint256 MAX_INT = 2**256 - 1;
        // if unsafe, will overflow and revert – passing this test
        test.bulkMint(address(this), 0, MAX_INT);
    }

    // includesCorrectPayment
    function testMintIncorrectPayment() public {
        cheats.expectRevert(errorSig("IncorrectPayment()"));
        test.mint{value: 0.11 ether}(0);
    }

    // nonReentrant
    function testReentrant() public {
        reentrant = true;
        cheats.expectRevert("REENTRANCY");
        test.mint{value: mintPrice}(1);
    }

    // onlyAfterUnlock
    function testMintBeforeUnlock() public {
        test.setUnlockTime(100);
        cheats.expectRevert(errorSig("TimeLocked()"));
        test.mint{value: mintPrice}(0);
    }

    // whenNotPaused
    function testMintPaused() public {
        test.pause();
        cheats.expectRevert("Pausable: paused");
        test.mint{value: mintPrice}(0);
    }

    // checkWalletNumMinted; incrementsWalletNumMinted
    function testWalletCanMintReverts() public {
        test = new ERC1155ExtendedImpl(
            "Test",
            "TEST",
            "ipfs://12345/{id}",
            mintPrice,
            3,
            100,
            2,
            0,
            address(5)
        );

        test.mint{value: mintPrice}(0);
        test.mint{value: mintPrice}(0);
        cheats.expectRevert(abi.encodeWithSignature("MaxMintedForWallet()"));
        test.mint{value: mintPrice}(0);
    }
}
