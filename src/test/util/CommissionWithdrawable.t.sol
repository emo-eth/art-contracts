// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import {DSTestPlusPlus} from "../helpers/DSTestPlusPlus.sol";

import {CommissionWithdrawable} from "../../util/CommissionWithdrawable.sol";
import {ERC20} from "sm/tokens/ERC20.sol";
import {IERC20} from "oz/interfaces/IERC20.sol";
import {User} from "../helpers/User.sol";

contract PayableUser is User {
    receive() external payable {}
}

contract CommissionWithdrawableImpl is CommissionWithdrawable {
    constructor(address _payout, uint256 _perMille)
        CommissionWithdrawable(_payout, _perMille)
    {}

    function getCommissionPayoutPerMille() public view returns (uint256) {
        return commissionPayoutPerMille;
    }

    function getCommissionPayoutAddress() public view returns (address) {
        return commissionPayoutAddress;
    }

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

contract CommissionWithdrawableTest is DSTestPlusPlus {
    CommissionWithdrawableImpl withdraw;
    Token token;
    PayableUser internal user = new PayableUser();

    function setUp() public {
        withdraw = new CommissionWithdrawableImpl(address(user), 50);
        token = new Token();
    }

    function testConstructorSetsParams() public {
        withdraw = new CommissionWithdrawableImpl(address(1234), 123);
        assertEq(withdraw.getCommissionPayoutPerMille(), 123);
        assertEq(withdraw.getCommissionPayoutAddress(), address(1234));
    }

    function testConstructorEnforcesLimit() public {
        // fine
        withdraw = new CommissionWithdrawableImpl(address(user), 1000);
        // bad
        cheats.expectRevert(errorSig("CommissionPayoutPerMilleTooLarge()"));
        withdraw = new CommissionWithdrawableImpl(address(user), 1001);
        // bad
        cheats.expectRevert(errorSig("CommissionPayoutAddressIsZeroAddress()"));
        withdraw = new CommissionWithdrawableImpl(address(0), 1000);
    }

    function testWithdrawSendsCommission() public {
        payable(address(withdraw)).transfer(1 ether);
        uint256 startingBalance = address(this).balance;
        withdraw.withdraw();
        assertGt(address(this).balance, startingBalance);
        assertEq(0, address(withdraw).balance);
        assertEq(0.05 ether, address(user).balance);
    }

    function testCanWithdrawToken() public {
        uint256 initialBalance = token.balanceOf(address(this));
        uint256 amount = 100;
        token.transfer(address(withdraw), amount);
        assertEq(amount, token.balanceOf(address(withdraw)));
        withdraw.withdrawToken(address(token));
        assertEq(0, token.balanceOf(address(withdraw)));
        assertEq(
            (initialBalance - 100) + (100 * 950) / 1000,
            token.balanceOf(address(this))
        );
        assertEq((100 * 50) / 1000, token.balanceOf(address(user)));
    }

    function testOnlyOwnerCanWithdraw() public {
        withdraw.transferOwnership(address(user));

        payable(address(withdraw)).transfer(1 ether);
        cheats.expectRevert("Ownable: caller is not the owner");

        withdraw.withdraw();
    }

    function testOnlyOwnerCanWithdrawToken() public {
        withdraw.transferOwnership(address(user));

        uint256 amount = 50 * 10**18;
        token.mint(amount);
        token.transfer(address(withdraw), amount);
        cheats.expectRevert("Ownable: caller is not the owner");

        withdraw.withdrawToken(address(token));
    }

    function testBigWithdraw() public {
        uint256 balance = token.balanceOf(address(this));
        uint256 bigBalance = 2**247;
        token.mint(bigBalance - balance);
        token.transfer(address(withdraw), token.balanceOf(address(this)));
        withdraw.withdrawToken(address(token));
        uint256 userBalance = (bigBalance / 1000) * 50;
        emit log_named_uint("expected user", userBalance);
        uint256 actualUser = token.balanceOf(address(user));
        emit log_named_uint("actual user", actualUser);
        assertEq(userBalance, token.balanceOf(address(user)));
        emit log_named_uint("expected test", bigBalance - userBalance);
        emit log_named_uint("actual test", token.balanceOf(address(this)));
        assertEq(bigBalance - userBalance, token.balanceOf(address(this)));
    }

    function testFuzzyWithdraw(uint256 perMille, uint256 balance)
        public
        inRange(perMille, balance)
    {
        withdraw = new CommissionWithdrawableImpl(address(user), perMille);
        payable(address(withdraw)).transfer(balance);
        uint256 preWithdrawBalance = address(this).balance;
        withdraw.withdraw();
        uint256 withdrawnBalance = (address(this).balance -
            preWithdrawBalance) + address(user).balance;
        assertEq(balance, withdrawnBalance);
        assertEq(address(user).balance, (balance * perMille) / 1000);
    }

    modifier inRange(uint256 perMille, uint256 balance) {
        if (perMille > 1000) {
            return;
        }
        if (balance > address(this).balance) {
            return;
        }
        _;
    }

    receive() external payable {}
}
