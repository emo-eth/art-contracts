// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import {ERC1155Extended} from "./ERC1155Extended.sol";
import {AllowList} from "../util/AllowList.sol";

contract SimpleAllowListERC1155 is ERC1155Extended, AllowList {
    constructor(
        string memory _name,
        string memory _symbol,
        string memory _uri,
        uint256 _maxRedemptions,
        uint256 _maxMintsPerWallet
    )
        ERC1155Extended(
            _name,
            _symbol,
            _uri,
            0.1 ether,
            3, /* numOptions */
            3000, /* maxSupplyPerOption */
            _maxMintsPerWallet,
            1, /* unlockTime */
            0xF57B2c51dED3A29e6891aba85459d600256Cf317 /* openseaProxyAddress */
        )
        AllowList(
            _maxRedemptions, /* maxAllowListRedemptions */
            0xed2ea62124906818bda99512204fa6beb610c56a9ffead65673043928746a924 /* merkleRoot */
        )
    {}

    function mintAllowList(uint256 _id, bytes32[] calldata _proof)
        public
        payable
        nonReentrant
        whenNotPaused
        includesCorrectPayment(1)
        onlyAllowListed(_proof)
    {
        _ensureSupplyAvailableForIdAndIncrement(_id, 1);
        _ensureWalletMintsAvailableAndIncrement(1);
        _ensureAllowListRedemptionsAvailableAndIncrement(1);
        _mint(msg.sender, _id, 1, "");
    }
}
