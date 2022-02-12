// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import {DSTestPlusPlus} from "../helpers/DSTestPlusPlus.sol";
import {OwnerPausable} from "../../util/OwnerPausable.sol";
import {User} from "../helpers/User.sol";

contract OwnerPausableImpl is OwnerPausable {
    function trueWhenPaused() external view whenPaused returns (bool) {
        return true;
    }

    function trueWhenNotPaused() external view whenNotPaused returns (bool) {
        return true;
    }
}

contract OwnerPausableTest is DSTestPlusPlus {
    OwnerPausableImpl pausable;

    User internal user = new User();

    function setUp() public {
        pausable = new OwnerPausableImpl();
    }

    function testPause() public {
        assertFalse(pausable.paused());
        pausable.pause();
        assertTrue(pausable.paused());
    }

    function testUnPause() public {
        pausable.pause();
        assertTrue(pausable.paused());
        pausable.unpause();
        assertFalse(pausable.paused());
    }

    function testOnlyOwnerCanPause() public {
        pausable.transferOwnership(address(user));
        cheats.expectRevert("Ownable: caller is not the owner");
        pausable.pause();
    }

    function testOnlyOwnerCanUnPause() public {
        pausable.pause();
        pausable.transferOwnership(address(user));
        cheats.expectRevert("Ownable: caller is not the owner");
        pausable.unpause();
    }

    function testModifierWhenPaused() public {
        pausable.pause();
        assertTrue(pausable.trueWhenPaused());
        cheats.expectRevert("Pausable: paused");
        pausable.trueWhenNotPaused();
    }

    function testModifierWhenNotPaused() public {
        cheats.expectRevert("Pausable: not paused");
        pausable.trueWhenPaused();
    }
}
