// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;
import {Ownable} from "oz/access/Ownable.sol";
import {Pausable} from "oz/security/Pausable.sol";
import {MerkleProofWrapper} from "oz/mocks/MerkleProofWrapper.sol";

contract AllowList is MerkleProofWrapper, Ownable {
    uint256 public immutable MAX_REDEMPTIONS;
    bytes32 public merkleRoot;
    mapping(address => uint256) addressRedemptions;

    error NotAllowListed();
    error MaxAllowListRedemptions();

    constructor(uint256 _maxRedemptions, bytes32 _merkleRoot) {
        MAX_REDEMPTIONS = _maxRedemptions;
        merkleRoot = _merkleRoot;
    }

    modifier onlyAllowListed(bytes32[] calldata proof) {
        if (
            !verify(proof, merkleRoot, keccak256(abi.encodePacked(msg.sender)))
        ) {
            revert NotAllowListed();
        }
        _;
    }

    modifier redeemsAllowList() {
        _;

        unchecked {
            ++addressRedemptions[msg.sender];
        }
    }

    modifier notYetRedeemed() {
        if (addressRedemptions[msg.sender] >= MAX_REDEMPTIONS) {
            revert MaxAllowListRedemptions();
        }
        _;
    }

    function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        _setMerkleRoot(_merkleRoot);
    }

    function _setMerkleRoot(bytes32 _merkleRoot) internal {
        merkleRoot = _merkleRoot;
    }
}
