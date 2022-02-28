// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import {Ownable} from "oz/access/Ownable.sol";
import {MerkleVerifier} from "./MerkleVerifier.sol";

contract VariableAmountAllowList is MerkleVerifier, Ownable {
    bytes32 public variableAmountMerkleRoot;
    mapping(address => uint256) variableAmountAddressRedemptions;

    constructor(bytes32 _variableMerkleRoot) {
        variableAmountMerkleRoot = _variableMerkleRoot;
    }

    error NotAllowListed();
    error MaxRedeemed();

    modifier onlyVariableAmountAllowListed(
        bytes32[] calldata _proof,
        uint256 _maxAmount
    ) {
        if (!isVariableAmountAllowListed(_proof, msg.sender, _maxAmount)) {
            revert NotAllowListed();
        }
        _;
    }

    modifier checkVariableAmountRedeemedAllowList(
        uint256 _amount,
        uint256 _maxRedemptions
    ) {
        if (
            (variableAmountAddressRedemptions[msg.sender] + _amount) >=
            _maxRedemptions
        ) {
            revert MaxRedeemed();
        }
        _;
    }

    modifier effectRedeemVariableAmountAllowList(uint256 _amount) {
        unchecked {
            variableAmountAddressRedemptions[msg.sender] += _amount;
        }
        _;
    }

    function isVariableAmountAllowListed(
        bytes32[] calldata _proof,
        address _address,
        uint256 _maxRedemptions
    ) public view returns (bool) {
        return
            verify(
                _proof,
                variableAmountMerkleRoot,
                keccak256(abi.encodePacked(_address, _maxRedemptions))
            );
    }

    function setVariableAmountMerkleRoot(bytes32 _merkleRoot)
        external
        onlyOwner
    {
        variableAmountMerkleRoot = _merkleRoot;
    }
}
