// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import {DSTestPlusPlus} from "../helpers/DSTestPlusPlus.sol";
import {TwoStepOwnable} from "../../util/TwoStepOwnable.sol";
import {User} from "../helpers/User.sol";

contract TwoStepOwnableImpl is TwoStepOwnable {}

contract TwoStepOwnableTest is DSTestPlusPlus {
    TwoStepOwnable ownable;
    User user = new User();

    function setUp() public {
        ownable = new TwoStepOwnableImpl();
    }

    function testTransferOwnershipDoesNotImmediatelyTransferOwnership() public {
        ownable.transferOwnership(address(user));
        assertEq(ownable.owner(), address(this));
    }

    function testTransferOwnershipRejectsZeroAddress() public {
        vm.expectRevert(errorSig("NewOwnerIsZeroAddress()"));
        ownable.transferOwnership(address(0));
    }

    function testClaimOwnership() public {
        ownable.transferOwnership(address(user));
        vm.prank(address(user));
        ownable.claimOwnership();
        assertEq(ownable.owner(), address(user));
    }

    function testTransferOwnershipIsStillOnlyOwner() public {
        ownable.transferOwnership(address(user));
        vm.prank(address(user));
        ownable.claimOwnership();
        // prank is over, back to regular address
        vm.expectRevert("Ownable: caller is not the owner");
        ownable.transferOwnership(address(5));
    }

    function testCancelTransferOwnership() public {
        ownable.transferOwnership(address(user));
        ownable.cancelOwnershipTransfer();
        vm.startPrank(address(user));
        vm.expectRevert(errorSig("NotNextOwner()"));
        ownable.claimOwnership();
    }

    function testNotNextOwner() public {
        ownable.transferOwnership(address(user));
        vm.startPrank(address(5));
        vm.expectRevert(errorSig("NotNextOwner()"));
        ownable.claimOwnership();
    }

    function testOnlyOwnerCanCancelTransferOwnership() public {
        ownable.transferOwnership(address(user));
        vm.prank(address(user));
        ownable.claimOwnership();
        // prank is over
        vm.expectRevert("Ownable: caller is not the owner");
        ownable.cancelOwnershipTransfer();
    }
}
