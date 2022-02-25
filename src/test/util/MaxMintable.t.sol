// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import {DSTestPlusPlus} from "../helpers/DsTestPlusPlus.sol";
import {MaxMintable} from "../../util/MaxMintable.sol";
import {User} from "../helpers/User.sol";

contract MaxMintableImpl is MaxMintable {
    constructor(uint256 _maxMintable) MaxMintable(_maxMintable) {}

    function checkAndIncrement(uint256 _quantity) public {
        _ensureWalletMintsAvailableAndIncrement(_quantity);
    }
}

contract MaxMintableTest is DSTestPlusPlus {
    MaxMintableImpl list;
    User internal user = new User();
    bytes32[] proof;
    bytes32 root;

    function setUp() public {
        list = new MaxMintableImpl(2);
    }

    function testConstructorInitializesPropertiesBatchMint() public {
        list = new MaxMintableImpl(2);
        assertEq(2, list.maxMintsPerWallet());
    }

    function testUpdateMaxMints() public {
        list.setMaxMintsPerWallet(5);
        assertEq(5, list.maxMintsPerWallet());
    }

    function testOnlyOwnerCanSetMaxMints() public {
        list.transferOwnership(address(user));
        vm.expectRevert("Ownable: caller is not the owner");
        list.setMaxMintsPerWallet(5);
    }

    function testCanRedeemUpToMax() public {
        list.checkAndIncrement(1);
        list.checkAndIncrement(1);
        // works with batch too
        vm.prank(address(1));
        list.checkAndIncrement(2);
    }

    function testRedeemingMoreThanMaxReverts() public {
        list.checkAndIncrement(1);
        list.checkAndIncrement(1);
        vm.expectRevert(abi.encodeWithSignature("MaxMintedForWallet()"));
        list.checkAndIncrement(1);
        vm.startPrank(address(1));
        vm.expectRevert(abi.encodeWithSignature("MaxMintedForWallet()"));
        list.checkAndIncrement(3);
        vm.stopPrank();
    }
}
