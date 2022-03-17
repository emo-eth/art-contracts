// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;
import {Ownable} from "oz/access/Ownable.sol";
import {IWithdrawable} from "./IWithdrawable.sol";
import {SafeTransferLib} from "sm/utils/SafeTransferLib.sol";
import {ERC20} from "sm/tokens/ERC20.sol";

///@notice Ownable helper contract to withdraw ether or tokens from the contract address balance
contract Withdrawable is IWithdrawable, Ownable {
    ////////////////////////
    // Withdrawal methods //
    ////////////////////////

    ///@notice Withdraw Ether from contract address. OnlyOwner.
    function withdraw() external override onlyOwner {
        uint256 balance = address(this).balance;
        SafeTransferLib.safeTransferETH(msg.sender, balance);
    }

    ///@notice Withdraw tokens from contract address. OnlyOwner.
    ///@param _token ERC20 smart contract address
    function withdrawToken(address _token) external override onlyOwner {
        ERC20 token = ERC20(_token);
        uint256 balance = ERC20(_token).balanceOf(address(this));
        SafeTransferLib.safeTransfer(token, msg.sender, balance);
    }
}
