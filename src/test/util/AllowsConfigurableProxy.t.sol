// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "sm/test/utils/DSTestPlus.sol";

import {AllowsProxyFromConfigurableRegistry} from "../../util/AllowsProxyFromConfigurableRegistry.sol";
import {ProxyRegistry, OwnableDelegateProxy} from "../../util/ProxyRegistry.sol";
import {User} from "../helpers/User.sol";

contract TestProxyRegistry is ProxyRegistry {
    function registerProxy(address _owner, address _proxy) external {
        proxies[_owner] = OwnableDelegateProxy(_proxy);
    }
}

contract AllowsProxyFromConfigurableRegistryTest is DSTestPlus {
    AllowsProxyFromConfigurableRegistry test;
    TestProxyRegistry proxyRegistry;
    User user = new User();

    function setUp() public {
        proxyRegistry = new TestProxyRegistry();
        test = new AllowsProxyFromConfigurableRegistry(
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

    function testCanSetProxyAddress() public {
        assertEq(address(proxyRegistry), test.proxyAddress());
        ProxyRegistry newProxy = new TestProxyRegistry();
        test.setProxyAddress(address(newProxy));
        assertEq(address(newProxy), test.proxyAddress());
    }

    function testFailOnlyOwnerCanSetProxyAddress() public {
        test.transferOwnership(address(user));
        test.setProxyAddress(address(user));
    }

    function testIsProxyOfOwner() public {
        assertFalse(test.isProxyOfOwner(address(user), address(this)));
        proxyRegistry.registerProxy(address(user), address(this));
        assertTrue(test.isProxyOfOwner(address(user), address(this)));
        // test returns false when proxy is inactive
        test.setIsProxyActive(false);
        assertFalse(test.isProxyOfOwner(address(user), address(this)));
    }
}
