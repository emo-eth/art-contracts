// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import "sm/test/utils/DSTestPlus.sol";

import {AllowsProxyFromImmutableRegistry} from "../../util/AllowsProxyFromImmutableRegistry.sol";
import {ProxyRegistry, OwnableDelegateProxy} from "../../util/ProxyRegistry.sol";
import {User} from "../helpers/User.sol";

contract TestProxyRegistry is ProxyRegistry {
    function createProxy(address _owner, address _operator) external {
        proxies[_owner] = OwnableDelegateProxy(_operator);
    }
}

contract AllowsProxyFromImmutableRegistryTest is DSTestPlus {
    AllowsProxyFromImmutableRegistry test;
    TestProxyRegistry proxyRegistry;
    User user = new User();

    function setUp() public {
        proxyRegistry = new TestProxyRegistry();
        test = new AllowsProxyFromImmutableRegistry(
            address(proxyRegistry),
            true
        );
    }

    function testConstructorInitializesProperties() public {
        assertTrue(test.isProxyActive());
        assertEq(address(proxyRegistry), test.proxyAddress());
    }

    function testCanSetIsProxyActive() public {
        assertTrue(test.isProxyActive());
        test.setIsProxyActive(false);
        assertFalse(test.isProxyActive());
    }

    function testFailOnlyownerCanSetIsProxyActive() public {
        test.transferOwnership(address(user));
        test.setIsProxyActive(false);
    }

    function testIsProxyOfOwner() public {
        assertFalse(test.isProxyOfOwner(address(user), address(this)));
        proxyRegistry.createProxy(address(user), address(this));
        assertTrue(test.isProxyOfOwner(address(user), address(this)));
        // test returns false when proxy is inactive
        test.setIsProxyActive(false);
        assertFalse(test.isProxyOfOwner(address(user), address(this)));
    }
}
