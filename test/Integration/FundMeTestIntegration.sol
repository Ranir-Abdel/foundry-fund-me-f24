// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import{Test , console} from "forge-std/Test.sol";

import{DeployFundMe} from "../../script/DeployFundMe.s.sol";

import {FundMe} from "../../src/FundMe.sol";

import{ FundFundMe ,WithdrawFundMe } from "../../script/Interaction.s.sol";

contract InteractionTest is Test{
    FundMe public fundMe;
    DeployFundMe deployFundMe;

    uint256 public constant SEND_VALUE= 0.1 ether;
    uint256 public constant STARTING_USER_BALANCE=10 ether;

    address USER=makeAddr("USER");

    function setUp() external {
        deployFundMe = new DeployFundMe();
        fundMe=deployFundMe.run();
        vm.deal(USER,STARTING_USER_BALANCE);
    }

    function testUserCanFundAndOwnerCanWhithdraw() public {
        uint256 preUserBalance = address(USER).balance;
        uint256 preOwnerBalance =address(fundMe. GetOwner()).balance;

        vm.prank(USER);
        fundMe.fund{value:SEND_VALUE}();

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        uint afterUserBalance=address(USER).balance;
        uint256 afterOwnerBalance=address(fundMe. GetOwner()).balance;

        assert(address(fundMe).balance==0);
        assertEq(afterUserBalance+SEND_VALUE,preUserBalance);
        assertEq(preOwnerBalance+SEND_VALUE,afterOwnerBalance);



    }



}