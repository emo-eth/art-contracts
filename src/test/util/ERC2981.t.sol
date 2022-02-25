// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import {DSTestPlusPlus} from "../helpers/DSTestPlusPlus.sol";

import {ERC2981} from "../../util/ERC2981.sol";
import {IERC2981} from "oz/interfaces/IERC2981.sol";
import {User} from "../helpers/User.sol";

contract ERC2981Impl is ERC2981 {
    uint256 public maxTokenId;

    constructor(
        address _royaltyAddress,
        uint16 _royaltyRate,
        uint256 _maxTokenId
    ) ERC2981(_royaltyAddress, _royaltyRate) {
        maxTokenId = _maxTokenId;
    }

    function isValidTokenId(uint256 _tokenId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return _tokenId < maxTokenId;
    }

    function supportsInterface(bytes4 interfaceId)
        external
        pure
        override
        returns (bool)
    {
        return interfaceId == type(IERC2981).interfaceId;
    }
}

contract ERC2981Test is DSTestPlusPlus {
    ERC2981 royalty;
    User internal user = new User();

    function setUp() public {
        royalty = new ERC2981Impl(address(this), 100, 100);
    }

    function testConstructorInitializesProperties() public {
        assertEq(address(this), royalty.royaltyAddress());
        assertEq(100, royalty.royaltyRate());
        // test-specific
        assertTrue(royalty.isValidTokenId(99));
        assertFalse(royalty.isValidTokenId(100));
    }

    function testRoyaltyInfo() public {
        (address royaltyAddress, uint256 amount) = royalty.royaltyInfo(0, 100);
        assertEq(address(this), royaltyAddress);
        assertEq(1, amount);
        (, amount) = royalty.royaltyInfo(0, 500);
        assertEq(5, amount);
    }

    function testSetRoyaltyAddress() public {
        assertEq(address(this), royalty.royaltyAddress());
        royalty.setRoyaltyAddress(address(user));
        assertEq(address(user), royalty.royaltyAddress());
    }

    function testSetRoyaltyRate() public {
        assertEq(100, royalty.royaltyRate());
        royalty.setRoyaltyRate(500);
        assertEq(500, royalty.royaltyRate());
    }

    function testOnlyOwnerCanSetRoyaltyAddress() public {
        royalty.transferOwnership(address(user));
        vm.expectRevert("Ownable: caller is not the owner");
        royalty.setRoyaltyAddress(address(user));
    }

    function testOnlyOwnerCanSetRoyaltyRate() public {
        royalty.transferOwnership(address(user));
        vm.expectRevert("Ownable: caller is not the owner");
        royalty.setRoyaltyRate(1);
    }
}
