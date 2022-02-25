// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;
import {Ownable} from "oz/access/Ownable.sol";
import {IERC20} from "oz/interfaces/IERC20.sol";
import {IWithdrawable} from "./IWithdrawable.sol";

///@notice Ownable helper contract to withdraw ether or tokens from the contract address balance
contract Withdrawable is IWithdrawable, Ownable {
    ////////////////////////
    // Withdrawal methods //
    ////////////////////////

    ///@notice Withdraw Ether from contract address. OnlyOwner.
    function withdraw() external override onlyOwner {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    ///@notice Withdraw tokens from contract address. OnlyOwner.
    ///@param _token ERC20 smart contract address
    function withdrawToken(address _token) external override onlyOwner {
        uint256 balance = IERC20(_token).balanceOf(address(this));
        IERC20(_token).transfer(msg.sender, balance);
    }
}
