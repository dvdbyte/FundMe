// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundMe} from "../../src/FundMe.sol";
import {FundFundMe,  WithdrawFundMe} from "../../script/Interactions.s.sol";

contract IntegrationsTest is Test {
   FundMe fundMe;

   address USER = makeAddr("USER");

  function setUp() external {
    DeployFundMe deployFundMe = new DeployFundMe();
    fundMe = deployFundMe.run();
  }

    function testUserCanFundInteractions () public {
    
      FundFundMe fundFundMe = new FundFundMe();
      fundFundMe.fundFundMe(address(fundMe));

      address funder = fundMe.getFunders(0);
      assert(funder == USER);
   
      console.log("FundMe Balance Before Withrawal %s", address(fundMe).balance);
      WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
      withdrawFundMe.withdrawFundMe(address(fundMe));

      assert(address(fundMe).balance == 0);
      console.log("FundMe Balance After Withdrawal %s", address(fundMe).balance);
    }
}