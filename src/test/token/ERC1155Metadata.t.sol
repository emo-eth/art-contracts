// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import {DSTestPlusPlus} from "../helpers/DSTestPlusPlus.sol";
import {ERC1155Metadata} from "../../token/ERC1155Metadata.sol";
import {User} from "../helpers/User.sol";

contract ERC1155MetadataTest is DSTestPlusPlus {
    ERC1155Metadata nft;
    User internal user = new User();

    string private constant name = "Test";
    string private constant symbol = "TEST";
    string private constant uri1 = "ipfs://1234/{id}";
    string private constant uri2 = "ipfs://5678/{id}";

    function setUp() public {
        nft = new ERC1155Metadata(name, symbol, uri1);
    }

    function testConstructorInitializesProperties() public {
        assertEq(name, nft.name());
        assertEq(symbol, nft.symbol());
        assertEq(uri1, nft.uri(0));
    }

    function testUpdateUri() public {
        nft.setUri(uri2);
        assertEq(uri2, nft.uri(0));
    }

    function testOnlyOwnerCanUpdateUri() public {
        nft.transferOwnership(address(user));
        vm.expectRevert("Ownable: caller is not the owner");
        nft.setUri(uri2);
    }

    function testCanFreezeMetadata() public {
        nft.freezeMetadata();
        vm.expectRevert(errorSig("MetadataIsFrozen()"));
        nft.setUri("revert pls");
    }

    function testOnlyOwnerCanFreezeUri() public {
        nft.transferOwnership(address(user));
        vm.expectRevert("Ownable: caller is not the owner");
        nft.freezeMetadata();
    }

    function testIsApprovedForAll() public {
        nft.setApprovalForAll(address(this), true);
        assertTrue(nft.isApprovedForAll(address(this), address(this)));
        nft.setApprovalForAll(address(this), false);
        assertFalse(nft.isApprovedForAll(address(this), address(this)));
    }
}
