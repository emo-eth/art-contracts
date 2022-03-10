// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import {DSTestPlusPlus} from "../helpers/DSTestPlusPlus.sol";
import {ERC721} from "oz/token/ERC721/ERC721.sol";
import {IERC721} from "oz/interfaces/IERC721.sol";
import {IERC721Receiver} from "oz/interfaces/IERC721Receiver.sol";

import {User} from "../helpers/User.sol";

contract UserPlus is User, IERC721Receiver {
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public pure override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}

contract ERC721Impl is ERC721("test", "test") {
    function mint(address _to, uint256 _id) external {
        _mint(_to, _id);
    }
}

contract ERC1155MetadataTest is DSTestPlusPlus {
    ERC721Impl nft;
    UserPlus internal user = new UserPlus();

    function setUp() public {
        nft = new ERC721Impl();
        nft.mint(address(this), 0);
    }

    function testTransferGas() public {
        nft.transferFrom(address(this), address(user), 0);
    }

    function testSafeTransferGas() public {
        nft.safeTransferFrom(address(this), address(user), 0);
    }
}
