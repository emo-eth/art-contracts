// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;
import {Ownable} from "oz/access/Ownable.sol";

/**
@notice Contract with convenience modifiers for ensuring functions cannot be called until after a certain block.timestamp.
Note: miners/validators can misreport block.timestamp, but discrepancies would be in the magnitude of seconds or maybe minutes, not hours or days.
*/
contract VestingToken is Ownable {
    uint256 public vestingPeriod;
    bool public vestingPeriodLocked;
    mapping(uint256 => uint256) public tokenToMintingTime;

    error NotVested();
    error VestingPeriodLocked();

    constructor(uint256 _vestingPeriod) {
        vestingPeriod = _vestingPeriod;
    }

    /**
    @notice will revert if block.timestamp is before vesting cliff
    */
    modifier onlyVested(uint256 _tokenId) {
        if (block.timestamp >= (tokenToMintingTime[_tokenId] + vestingPeriod)) {
            _;
        } else {
            revert NotVested();
        }
    }

    /**
    @dev reverts if vestingPeriod is locked
     */
    modifier whenVestingUnlocked() {
        if (vestingPeriodLocked) {
            revert VestingPeriodLocked();
        } else {
            _;
        }
    }

    function isVested(uint256 _tokenId) public virtual returns (bool) {
        return
            block.timestamp >= (tokenToMintingTime[_tokenId] + vestingPeriod);
    }

    ///@notice set vesting period time. OnlyOwner
    ///@param _vestingPeriod number of seconds to wait before token is vested
    function setVestingPeriod(uint256 _vestingPeriod)
        external
        onlyOwner
        whenVestingUnlocked
    {
        vestingPeriod = _vestingPeriod;
    }

    /**
    @notice get vesting time of a tokenId
    @param _tokenId uint256 tokenId
    @return uint256 time when token is fully vested
     */
    function getVestingTime(uint256 _tokenId) external view returns (uint256) {
        return tokenToMintingTime[_tokenId] + vestingPeriod;
    }

    /**
    @notice lock the vestingPeriod property, disallowing changing it going forward
    */
    function lockVestingPeriod() external onlyOwner {
        vestingPeriodLocked = true;
    }

    function _setVestingStart(uint256 _tokenId, uint256 _timestamp) internal {
        tokenToMintingTime[_tokenId] = _timestamp;
    }
}
