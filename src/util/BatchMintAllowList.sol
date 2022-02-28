// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;
import {Ownable} from "oz/access/Ownable.sol";
import {MerkleVerifier} from "./MerkleVerifier.sol";
import {IAllowList} from "./IAllowList.sol";

contract BatchMintAllowList is IAllowList, MerkleVerifier, Ownable {
    uint256 public immutable MAX_REDEMPTIONS_PER_ID;
    bytes32 public merkleRoot;

    ///@dev 3 80-bit ints allow plenty of redemptions and are still able to be packed into a single 256-bit word
    struct MintQuantities {
        uint80 quantity0;
        uint80 quantity1;
        uint80 quantity2;
    }

    mapping(address => MintQuantities) public addressRedemptions;

    constructor(uint256 _maxRedemptionsPerId, bytes32 _merkleRoot) {
        MAX_REDEMPTIONS_PER_ID = _maxRedemptionsPerId;
        merkleRoot = _merkleRoot;
    }

    modifier onlyAllowListed(bytes32[] calldata _proof) {
        if (!isAllowListed(_proof, msg.sender)) {
            revert NotAllowListed();
        }
        _;
    }

    modifier checksAndRedeemsBatchAllowListRedemptions(
        MintQuantities calldata _toRedeem
    ) {
        {
            MintQuantities storage allowListRedemptions = addressRedemptions[
                msg.sender
            ];
            // uint80s will revert on overflow
            if (
                (allowListRedemptions.quantity0 + _toRedeem.quantity0) >
                MAX_REDEMPTIONS_PER_ID ||
                (allowListRedemptions.quantity1 + _toRedeem.quantity1) >
                MAX_REDEMPTIONS_PER_ID ||
                (allowListRedemptions.quantity2 + _toRedeem.quantity2) >
                MAX_REDEMPTIONS_PER_ID
            ) {
                revert MaxAllowListRedemptions();
            }

            // overflow would have reverted above
            unchecked {
                allowListRedemptions.quantity0 += _toRedeem.quantity0;
                allowListRedemptions.quantity1 += _toRedeem.quantity1;
                allowListRedemptions.quantity2 += _toRedeem.quantity2;
            }
        }
        _;
    }

    modifier checkBatchAllowListRedemptions(MintQuantities calldata _toRedeem) {
        {
            MintQuantities storage allowListRedemptions = addressRedemptions[
                msg.sender
            ];
            // uint80s will revert on overflow
            if (
                (allowListRedemptions.quantity0 + _toRedeem.quantity0) >
                MAX_REDEMPTIONS_PER_ID ||
                (allowListRedemptions.quantity1 + _toRedeem.quantity1) >
                MAX_REDEMPTIONS_PER_ID ||
                (allowListRedemptions.quantity2 + _toRedeem.quantity2) >
                MAX_REDEMPTIONS_PER_ID
            ) {
                revert MaxAllowListRedemptions();
            }
        }
        _;
    }

    modifier redeemBatchAllowList(MintQuantities calldata _toRedeem) {
        {
            MintQuantities storage allowListRedemptions = addressRedemptions[
                msg.sender
            ];

            // overflow would have reverted above
            unchecked {
                allowListRedemptions.quantity0 += _toRedeem.quantity0;
                allowListRedemptions.quantity1 += _toRedeem.quantity1;
                allowListRedemptions.quantity2 += _toRedeem.quantity2;
            }
        }
        _;
    }

    function isAllowListed(bytes32[] calldata _proof, address _address)
        public
        view
        override
        returns (bool)
    {
        return
            verify(_proof, merkleRoot, keccak256(abi.encodePacked(_address)));
    }

    function setMerkleRoot(bytes32 _merkleRoot) external override onlyOwner {
        _setMerkleRoot(_merkleRoot);
    }

    function _setMerkleRoot(bytes32 _merkleRoot) internal {
        merkleRoot = _merkleRoot;
    }
}
