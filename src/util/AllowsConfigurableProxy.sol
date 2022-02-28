// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;
import {Ownable} from "oz/access/Ownable.sol";
import {ProxyRegistry} from "./ProxyRegistry.sol";
import {IAllowsProxy} from "./IAllowsProxy.sol";

contract AllowsConfigurableProxy is IAllowsProxy, Ownable {
    bool internal isProxyActive_;
    address internal proxyAddress_;

    constructor(address _proxyAddress, bool _isProxyActive) {
        proxyAddress_ = _proxyAddress;
        isProxyActive_ = _isProxyActive;
    }

    function setIsProxyActive(bool _isProxyActive) external onlyOwner {
        isProxyActive_ = _isProxyActive;
    }

    function setProxyAddress(address _proxyAddress) public onlyOwner {
        proxyAddress_ = _proxyAddress;
    }

    function proxyAddress() public view returns (address) {
        return proxyAddress_;
    }

    function isProxyActive() public view returns (bool) {
        return isProxyActive_;
    }

    function isApprovedForProxy(address _owner, address _operator)
        public
        view
        returns (bool)
    {
        ProxyRegistry proxyRegistry = ProxyRegistry(proxyAddress_);
        if (
            isProxyActive_ &&
            address(proxyRegistry.proxies(_owner)) == _operator
        ) {
            return true;
        }
        return false;
    }
}
