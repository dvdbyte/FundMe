// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script {

   address USER = makeAddr("USER");
   uint256 constant INITIAL_BALANCE = 10 ether;
   uint256 constant SEND_VALUE = 0.1 ether;

  

  function fundFundMe(address mostRecentlyDeployed) public {
    vm.prank(USER);
    vm.deal(USER, INITIAL_BALANCE);
    FundMe(payable(mostRecentlyDeployed)).fund{value: SEND_VALUE}();
    console.log("Funded FundMe with %s", SEND_VALUE);

  }

  function run() external {
      address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
      vm.startBroadcast();
      fundFundMe(mostRecentlyDeployed);
      vm.stopBroadcast();
  }

}

contract WithdrawFundMe is Script {

  function withdrawFundMe (address mostRecentlyDeployed) public {
    vm.startBroadcast();
    FundMe(payable(mostRecentlyDeployed)).withdraw();
    vm.stopBroadcast();
  }


  function run() external {
    address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
    withdrawFundMe(mostRecentlyDeployed);

  }

}