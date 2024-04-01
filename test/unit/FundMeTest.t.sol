// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    DeployFundMe deployFundMe;
    FundMe fundMe;

    address USER = makeAddr("USER");
    uint256 public constant USER_BALANCE = 4e18;

    uint256 public constant ETH_VALUE = 0.1 ether;

    function setUp() external {
        deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
    }

    // tset MiniMum Value Is Accurage
    function testMinimumValueIsAccurate() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    // test Owner Is Message Sender
    function testOwnerIsMessageSender() public view {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    // test version Is Acurate
    function testVersionIsAccurate() public view {
        uint256 version = fundMe.version();
        assertEq(version, 4);
    }

    // test Fund Fails Without Enougheth
    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert();
        fundMe.fund();
    }

    // test Funded Update Data Structure
    function testFundedUpdeteDataStructure() public {
        vm.prank(USER);
        vm.deal(USER, USER_BALANCE);
        fundMe.fund{value: ETH_VALUE}();

        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);

        assertEq(amountFunded, ETH_VALUE);
    }

    // tes add Funder To Array Of Funders
    function testAddsFundersToArrayOfFunders() public funded {
        address funder = fundMe.getFunders(0);
        assertEq(funder, USER);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert();
        // vm.prank(USER);
        fundMe.withdraw();
    }

    // test Withdraw with a single funder
    function testWithdrawWithASingleFunder() public funded {
        // arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );

        console.log(startingFundMeBalance + startingOwnerBalance);
        console.log(endingOwnerBalance);
    }

    // withdraw from multiple fundes
    function testWithdrawFromMultipleFunders() public funded {
      // Arrange
      uint160 numberOfFunders = 10;
      uint160 startingFunderIndex = 2;

      for(uint160 i = startingFunderIndex; i < numberOfFunders; i++){
        hoax(address(i), ETH_VALUE);
        fundMe.fund{value: ETH_VALUE}();
      }

      uint256 startingOwnerBalance = fundMe.getOwner().balance;
      uint256 startingFundMeBalance = address(fundMe).balance;

      // Act
 
      vm.prank(fundMe.getOwner());
      fundMe.withdraw();
      // Assert
    
      assertEq(address(fundMe).balance, 0);
      assertEq(startingFundMeBalance + startingOwnerBalance, fundMe.getOwner().balance);
      
    }

    
    // Cheaper withdrawal
    function testWithdrawFromMultipleFundersCheaper() public funded {
      // Arrange
      uint160 numberOfFunders = 10;
      uint160 startingFunderIndex = 2;
      uint256 funders = numberOfFunders;

      for(uint160 i = startingFunderIndex; i < funders; i++){
        hoax(address(i), ETH_VALUE);
        fundMe.fund{value: ETH_VALUE}();
      }

      uint256 startingOwnerBalance = fundMe.getOwner().balance;
      uint256 startingFundMeBalance = address(fundMe).balance;

      // Act
      vm.prank(fundMe.getOwner());
      fundMe.withdrawCheaper();

      // Assert
    

      assertEq(address(fundMe).balance, 0);
      assertEq(startingFundMeBalance + startingOwnerBalance, fundMe.getOwner().balance);
      
    }

    modifier funded() {
        vm.prank(USER);
        vm.deal(USER, USER_BALANCE);
        fundMe.fund{value: ETH_VALUE}();
        _;
    }
}
