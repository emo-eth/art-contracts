// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;
import {ERC1155Extended} from "../../token/ERC1155Extended.sol";

contract ERC1155ExtendedImpl is ERC1155Extended {
    constructor(
        string memory _name,
        string memory _symbol,
        string memory _uri,
        uint256 _mintPrice,
        uint256 _numOptions,
        uint256 _maxSupply,
        uint256 _maxMintsPerWallet,
        uint256 _unlockTime,
        address _proxyAddress
    )
        ERC1155Extended(
            _name,
            _symbol,
            _uri,
            _mintPrice,
            _numOptions,
            _maxSupply,
            _maxMintsPerWallet,
            _unlockTime,
            _proxyAddress
        )
    {}

    function mint(uint256 _id)
        external
        payable
        nonReentrant
        whenNotPaused
        onlyAfterUnlock
        includesCorrectPayment(1)
    {
        _ensureSupplyAvailableForIdAndIncrement(_id, 1);
        _ensureWalletMintsAvailableAndIncrement(1);
        _mint(msg.sender, _id, 1, "");
    }
}
