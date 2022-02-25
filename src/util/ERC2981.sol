// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;
import {IERC2981} from "oz/interfaces/IERC2981.sol";
import {Ownable} from "oz/access/Ownable.sol";

abstract contract ERC2981 is Ownable, IERC2981 {
    address public royaltyAddress;
    ///@notice this is per ten-thousand, ie, 10000 = 100%
    uint16 public royaltyRate;

    error InvalidID();
    error InvalidRoyaltyRate();

    constructor(address _royaltyAddress, uint16 _royaltyRate) {
        royaltyAddress = _royaltyAddress;
        royaltyRate = _royaltyRate;
    }

    function setRoyaltyAddress(address _royaltyAddress) public onlyOwner {
        royaltyAddress = _royaltyAddress;
    }

    function setRoyaltyRate(uint16 _royaltyRate) public onlyOwner {
        royaltyRate = _royaltyRate;
    }

    function royaltyInfo(uint256 _tokenId, uint256 _salePrice)
        external
        view
        override
        returns (address receiver, uint256 royaltyAmount)
    {
        if (!isValidTokenId(_tokenId)) {
            revert InvalidID();
        }

        return (royaltyAddress, (_salePrice * royaltyRate) / 10000);
    }

    function isValidTokenId(uint256 _tokenId)
        public
        view
        virtual
        returns (bool);
}
