// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "sm/test/utils/DSTestPlus.sol";

import {AllowsImmutableProxy} from "../../util/AllowsImmutableProxy.sol";
import {ProxyRegistry, OwnableDelegateProxy} from "../../util/ProxyRegistry.sol";
import {User} from "../helpers/User.sol";

contract TestProxyRegistry is ProxyRegistry {
    function setProxyApprovalForAll(address _owner, address _operator)
        external
    {
        proxies[_owner] = OwnableDelegateProxy(_operator);
    }
}

contract AllowsImmutableProxyTest is DSTestPlus {
    AllowsImmutableProxy test;
    TestProxyRegistry proxyRegistry;
    User user = new User();

    function setUp() public {
        proxyRegistry = new TestProxyRegistry();
        test = new AllowsImmutableProxy(address(proxyRegistry), true);
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

    function testIsApprovedForProxy() public {
        assertFalse(test.isApprovedForProxy(address(user), address(this)));
        proxyRegistry.setProxyApprovalForAll(address(user), address(this));
        assertTrue(test.isApprovedForProxy(address(user), address(this)));
        // test returns false when proxy is inactive
        test.setIsProxyActive(false);
        assertFalse(test.isApprovedForProxy(address(user), address(this)));
    }
}
