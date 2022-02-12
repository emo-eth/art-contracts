// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
import {Ownable} from "oz/access/Ownable.sol";
import {Pausable} from "oz/security/Pausable.sol";

///@notice Ownable pausable contract with pause and unpause methods
contract OwnerPausable is Ownable, Pausable {
    ///@notice pause. OnlyOwner
    function pause() external onlyOwner whenNotPaused {
        _pause();
    }

    ///@notice Unpause. OnlyOwner
    function unpause() external onlyOwner whenPaused {
        _unpause();
    }
}
