// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

interface IAllowsProxyFromRegistry {
    function isProxyActive() external view returns (bool);

    function proxyAddress() external view returns (address);

    function isProxyOfOwner(address _owner, address _operator)
        external
        view
        returns (bool);
}
