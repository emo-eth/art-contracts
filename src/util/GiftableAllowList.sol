// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import {Ownable} from "oz/access/Ownable.sol";
import {MerkleVerifier} from "./MerkleVerifier.sol";

contract GiftableAllowList is MerkleVerifier, Ownable {
    uint256 public immutable MAX_GIFT_REDEMPTIONS;
    bytes32 public giftMerkleRoot;
    mapping(address => uint256) addressGiftRedemptions;

    constructor(uint256 _maxGiftRedemptions, bytes32 _giftMerkleRoot) {
        MAX_GIFT_REDEMPTIONS = _maxGiftRedemptions;
        giftMerkleRoot = _giftMerkleRoot;
    }

    error NotGiftAllowListed();
    error MaxGiftsRedeemed();

    modifier onlyGiftAllowListed(bytes32[] calldata _proof) {
        if (!isGiftAllowListed(_proof, msg.sender)) {
            revert NotGiftAllowListed();
        }
        _;
    }

    modifier checksandRedeemsGiftAllowList() {
        if (addressGiftRedemptions[msg.sender] >= MAX_GIFT_REDEMPTIONS) {
            revert MaxGiftsRedeemed();
        }
        unchecked {
            ++addressGiftRedemptions[msg.sender];
        }
        _;
    }

    function isGiftAllowListed(bytes32[] calldata _proof, address _address)
        public
        view
        returns (bool)
    {
        return
            verify(
                _proof,
                giftMerkleRoot,
                keccak256(abi.encodePacked(_address))
            );
    }

    function setGiftMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        _setGiftMerkleRoot(_merkleRoot);
    }

    function _setGiftMerkleRoot(bytes32 _merkleRoot) internal {
        giftMerkleRoot = _merkleRoot;
    }
}
