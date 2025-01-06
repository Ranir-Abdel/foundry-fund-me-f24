// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test,console} from "forge-std/Test.sol";

import {FundMe}  from "../../src/FundMe.sol";

import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {   

    DeployFundMe deployFundMe;

    FundMe fundMe;
    address USER =makeAddr("User");
     
    uint constant Starting_Balance=10 ether;
    uint constant Send_Value=5e18;
    uint256 constant Gas_Price=1;

    
    function setUp()external{
        vm.deal(USER,Starting_Balance);
         deployFundMe = new DeployFundMe();
         fundMe=deployFundMe.run();

    }

    function testMinimumDollarIsFive()public view{
        assertEq(fundMe.MinimumUSD(),Send_Value);
    }

    function testOwnerIsMsgSender() public view{
        
        assertEq(fundMe.i_owner(),msg.sender);
    }
 
    function testPriceFeedIsAccurate()public view{
         uint version=fundMe.GetVersion();
         assertEq(version,4);
    }

    function testFundFailsWhithoutEnoughEth()public{
        vm.prank(USER);
        fundMe.fund{value:Starting_Balance} ();// Starting_Balance=10 ether;
        uint AmounthFunded=fundMe.GetAdressToAmountFunded(address(USER));
        assertEq(AmounthFunded, Starting_Balance);
    }

    function testAddFunderToArrayOfFunder ()public {
        vm.prank(USER);
        fundMe.fund{value:Send_Value} ();
        address funder=fundMe.GetFunders(0);
        assertEq(funder,USER);

    }
    modifier Funded(){
        vm.prank(USER);
        fundMe.fund{value:10 ether} ();
        _;

    }

    function testOnlyOwnerCanWhithDraw()public{
        vm.prank(USER);
        fundMe.fund{value:Send_Value}();
        vm.expectRevert();
        vm.prank(USER);//because USER (funder)is not the Owner
        fundMe.Withdraw();
    }

    function testWhithDrawWithSingleFunder() public Funded{
        uint256 StartinOwnerBalance=fundMe.GetOwner().balance;
        uint StartingFundMeBalance=address(fundMe).balance;
        vm.txGasPrice(Gas_Price);
        uint256 GasStart= gasleft();

        vm.prank(fundMe.GetOwner());
        fundMe.Withdraw();
        vm.stopPrank();
        uint GasEnd=gasleft();
        uint256 GasUsed=(GasStart-GasEnd)*tx.gasprice;
        console.log("WithDraw consumed : %d gas",GasUsed);


        uint256 EndingOwnerBalance=fundMe.GetOwner().balance;
        uint EndingFundMeBalance=address(fundMe).balance;
        assertEq(EndingFundMeBalance,0);
        assertEq(StartinOwnerBalance+StartingFundMeBalance,EndingOwnerBalance);

        
    }

    function testWithDrawFromMultipleFunders()public Funded{
        uint160 NumberOfFunders=10;
        uint160 StartingFunderIndex=1;
        for(uint160 i =StartingFunderIndex;i<NumberOfFunders+StartingFunderIndex; i=i+1){
            hoax(address(i),Send_Value);
            fundMe.fund{value:Send_Value}();
        }
        
        uint256 StartingFundMeBalance=address(fundMe).balance;
        uint StartingOwnerBalance=fundMe.GetOwner().balance;

        vm.startPrank(fundMe.GetOwner());
        fundMe.Withdraw();
        vm.stopPrank();
        assert (address (fundMe).balance==0);
        assert(StartingFundMeBalance+StartingOwnerBalance==fundMe.GetOwner().balance);
        
       
    }



    function testWithDrawCheaperFromMultipleFunders()public Funded{
        uint160 NumberOfFunders=10;
        uint160 StartingFunderIndex=1;
        for(uint160 i =StartingFunderIndex;i<NumberOfFunders+StartingFunderIndex; i=i+1){
            hoax(address(i),Send_Value);
            fundMe.fund{value:Send_Value}();
        }
        
        uint256 StartingFundMeBalance=address(fundMe).balance;
        uint StartingOwnerBalance=fundMe.GetOwner().balance;

        vm.startPrank(fundMe.GetOwner());
        fundMe.CheaperWhithdraw();
        vm.stopPrank();
        assert (address (fundMe).balance==0);
        assert(StartingFundMeBalance+StartingOwnerBalance==fundMe.GetOwner().balance);
        
       
    }
 
 
}