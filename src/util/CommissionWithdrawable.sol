// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;
import {Ownable} from "oz/access/Ownable.sol";
import {IWithdrawable} from "./IWithdrawable.sol";

import {SafeTransferLib} from "sm/utils/SafeTransferLib.sol";
import {ERC20} from "sm/tokens/ERC20.sol";

///@notice Ownable helper contract to withdraw ether or tokens from the contract address balance
contract CommissionWithdrawable is IWithdrawable, Ownable {
    address internal immutable commissionPayoutAddress;
    uint256 internal immutable commissionPayoutPerMille;

    error CommissionPayoutAddressIsZeroAddress();
    error CommissionPayoutPerMilleTooLarge();

    constructor(
        address _commissionPayoutAddress,
        uint256 _commissionPayoutPerMille
    ) {
        if (_commissionPayoutAddress == address(0)) {
            revert CommissionPayoutAddressIsZeroAddress();
        }
        if (_commissionPayoutPerMille > 1000) {
            revert CommissionPayoutPerMilleTooLarge();
        }
        commissionPayoutAddress = _commissionPayoutAddress;
        commissionPayoutPerMille = _commissionPayoutPerMille;
    }

    ////////////////////////
    // Withdrawal methods //
    ////////////////////////

    ///@notice Withdraw Ether from contract address. OnlyOwner.
    function withdraw() external override onlyOwner {
        uint256 balance = address(this).balance;
        (
            uint256 ownerShareMinusCommission,
            uint256 commissionFee
        ) = calculateOwnerShareAndCommissionFee(balance);
        SafeTransferLib.safeTransferETH(msg.sender, ownerShareMinusCommission);
        SafeTransferLib.safeTransferETH(commissionPayoutAddress, commissionFee);
    }

    ///@notice Withdraw tokens from contract address. OnlyOwner.
    ///@param _token ERC20 smart contract address
    function withdrawToken(address _token) external override onlyOwner {
        ERC20 token = ERC20(_token);
        uint256 balance = token.balanceOf(address(this));
        (
            uint256 ownerShareMinusCommission,
            uint256 commissionFee
        ) = calculateOwnerShareAndCommissionFee(balance);
        SafeTransferLib.safeTransfer(
            token,
            msg.sender,
            ownerShareMinusCommission
        );
        SafeTransferLib.safeTransfer(
            token,
            commissionPayoutAddress,
            commissionFee
        );
    }

    function calculateOwnerShareAndCommissionFee(uint256 _balance)
        private
        view
        returns (uint256, uint256)
    {
        uint256 commissionFee;
        // commissionPayoutPerMille is max 1000 which is ~2^10; will only overflow if balance is > ~2^246
        if (_balance < 2**246) {
            commissionFee = (_balance * commissionPayoutPerMille) / 1000;
        } else {
            // commission fee may be truncated by up to 999000 units (<2**20) – but only for balances > 2**246
            commissionFee = (_balance / 1000) * commissionPayoutPerMille;
        }
        uint256 ownerShareMinusCommission = _balance - commissionFee;
        return (ownerShareMinusCommission, commissionFee);
    }
}
