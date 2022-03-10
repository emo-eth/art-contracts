// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import {DSTestPlusPlus} from "../helpers/DSTestPlusPlus.sol";

import {TimeLock} from "../../util/TimeLock.sol";
import {User} from "../helpers/User.sol";

contract TimeLockImpl is TimeLock {
    constructor(uint256 _unlockTime) TimeLock(_unlockTime) {}

    function trueAfterUnlock() external view onlyAfterUnlock returns (bool) {
        return true;
    }
}

contract TimeLockTest is DSTestPlusPlus {
    TimeLockImpl lock;
    User internal user = new User();

    function setUp() public {
        lock = new TimeLockImpl(0);
    }

    function testConstructorInitializesProperties() public {
        lock = new TimeLockImpl(999);
        assertEq(999, lock.unlockTime());
    }

    function testUpdateUnlock() public {
        uint256 timestamp = block.timestamp;
        lock.setUnlockTime(timestamp + 100);
        assertEq(timestamp + 100, lock.unlockTime());
    }

    function testUpdateUnlockOnlyOwner() public {
        lock.transferOwnership(address(user));
        uint256 timestamp = block.timestamp;
        vm.expectRevert("Ownable: caller is not the owner");
        lock.setUnlockTime(timestamp + 100);
    }

    function testOnlyAfterUnlockModifier() public {
        assertTrue(lock.trueAfterUnlock());
        lock.setUnlockTime(block.timestamp + 100);
        vm.expectRevert(errorSig("TimeLocked()"));
        lock.trueAfterUnlock();
    }

    function testIsUnlocked() public {
        assertTrue(lock.isUnlocked());
        lock.setUnlockTime(block.timestamp + 100);
        assertFalse(lock.isUnlocked());
        // simulate time passing
        hevm.warp(block.timestamp + 101);
        assertTrue(lock.isUnlocked());
    }
}
