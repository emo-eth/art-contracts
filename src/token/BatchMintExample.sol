// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import {ERC1155Extended} from "./ERC1155Extended.sol";
import {BatchMintAllowList} from "../util/BatchMintAllowList.sol";

contract BatchMintExample is ERC1155Extended, BatchMintAllowList {
    function _ensureSupplyAvailableAndIncrementBatch(
        MintQuantities calldata _quantities
    ) internal {
        // will revert on overflow
        if (
            (numMinted[0] + _quantities.quantity0) > MAX_SUPPLY_PER_ID ||
            (numMinted[1] + _quantities.quantity1) > MAX_SUPPLY_PER_ID ||
            (numMinted[2] + _quantities.quantity2) > MAX_SUPPLY_PER_ID
        ) {
            revert MaxSupplyForID();
        }
        // would have reverted above
        unchecked {
            numMinted[0] += _quantities.quantity0;
            numMinted[1] += _quantities.quantity1;
            numMinted[2] += _quantities.quantity2;
        }
    }

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _uri
    )
        ERC1155Extended(
            _name,
            _symbol,
            _uri,
            0.1 ether,
            3, /* numOptions */
            3000, /* maxSupplyPerOption */
            15, /* maxMintsPerWallet */
            1, /* unlockTime */
            0xF57B2c51dED3A29e6891aba85459d600256Cf317 /* openseaProxyAddress */
        )
        BatchMintAllowList(
            3, /* maxAllowListRedemptions */
            0xed2ea62124906818bda99512204fa6beb610c56a9ffead65673043928746a924 /* merkleRoot */
        )
    {}

    function batchMint(MintQuantities calldata _toMint)
        external
        payable
        whenNotPaused
        onlyAfterUnlock
        includesCorrectPayment(
            _toMint.quantity0 + _toMint.quantity1 + _toMint.quantity2
        )
        nonReentrant
    {
        _ensureSupplyAvailableAndIncrementBatch(_toMint);
        _ensureWalletMintsAvailableAndIncrement(
            _toMint.quantity0 + _toMint.quantity1 + _toMint.quantity2
        );
        _mint(msg.sender, 0, _toMint.quantity0, "");
        _mint(msg.sender, 1, _toMint.quantity1, "");
        _mint(msg.sender, 2, _toMint.quantity2, "");
    }

    function batchMintAllowList(
        MintQuantities calldata _toRedeem,
        bytes32[] calldata _proof
    )
        public
        payable
        whenNotPaused
        checkBatchAllowListRedemptions(_toRedeem)
        includesCorrectPayment(
            _toRedeem.quantity0 + _toRedeem.quantity1 + _toRedeem.quantity2
        )
        onlyAllowListed(_proof)
        redeemBatchAllowList(_toRedeem)
        nonReentrant
    {
        _ensureSupplyAvailableAndIncrementBatch(_toRedeem);
        _ensureWalletMintsAvailableAndIncrement(
            _toRedeem.quantity0 + _toRedeem.quantity1 + _toRedeem.quantity2
        );
        _mint(msg.sender, 0, _toRedeem.quantity0, "");
        _mint(msg.sender, 1, _toRedeem.quantity1, "");
        _mint(msg.sender, 2, _toRedeem.quantity2, "");
    }
}
