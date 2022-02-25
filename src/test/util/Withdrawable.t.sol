// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import {DSTestPlusPlus} from "../helpers/DSTestPlusPlus.sol";

import {Withdrawable} from "../../util/Withdrawable.sol";
import {ERC20} from "sm/tokens/ERC20.sol";
import {IERC20} from "oz/interfaces/IERC20.sol";
import {User} from "../helpers/User.sol";

contract WithdrawableImpl is Withdrawable {
    receive() external payable {}
}

contract Token is ERC20 {
    constructor() ERC20("Token", "TOKEN", 18) {
        _mint(msg.sender, 100 * 10**18);
    }

    function mint(uint256 _amount) public {
        _mint(msg.sender, _amount);
    }
}

contract WithdrawableTest is DSTestPlusPlus {
    WithdrawableImpl withdraw;
    Token token;
    User internal user = new User();

    function setUp() public {
        withdraw = new WithdrawableImpl();
        token = new Token();
    }

    function testCanWithdraw() public {
        payable(address(withdraw)).transfer(1 ether);
        uint256 startingBalance = address(this).balance;
        withdraw.withdraw();
        assertGt(address(this).balance, startingBalance);
        assertEq(0, address(withdraw).balance);
    }

    function testCanWithdrawToken() public {
        uint256 amount = 50;
        token.transfer(address(withdraw), amount);
        assertEq(amount, token.balanceOf(address(withdraw)));
        withdraw.withdrawToken(address(token));
        assertEq(0, token.balanceOf(address(withdraw)));
    }

    function testOnlyOwnerCanWithdraw() public {
        withdraw.transferOwnership(address(user));

        payable(address(withdraw)).transfer(1 ether);
        vm.expectRevert("Ownable: caller is not the owner");

        withdraw.withdraw();
    }

    function testOnlyOwnerCanWithdrawToken() public {
        withdraw.transferOwnership(address(user));

        uint256 amount = 50 * 10**18;
        token.mint(amount);
        token.transfer(address(withdraw), amount);
        vm.expectRevert("Ownable: caller is not the owner");

        withdraw.withdrawToken(address(token));
    }

    receive() external payable {}
}
