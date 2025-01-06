// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.18;
import{Script , console}from "forge-std/Script.sol";

import{FundMe}from "../src/FundMe.sol";

import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

contract FundFundMe is Script{

uint SEND_VALUE= 0.1 ether;

function fundFundMe(address MostRecentlydeploy) public{
    vm.startBroadcast();
    FundMe(payable(MostRecentlydeploy)).fund{value: SEND_VALUE}();
    vm.stopBroadcast();
console.log("Funded FundMe with %s" , SEND_VALUE);
}

function run () external{
    address MostRecentlyDeployed= DevOpsTools. get_most_recent_deployment("FundMe",block.chainid);
    fundFundMe(MostRecentlyDeployed);
}

}


contract WithdrawFundMe is Script{

function withdrawFundMe(address MostRecentlydeploy) public{
    vm.startBroadcast();
    FundMe(payable(MostRecentlydeploy)).Withdraw();
    vm.stopBroadcast();
console.log("Withdraw FundMe balance!");
}

function run () external{
    address MostRecentlyDeployed= DevOpsTools. get_most_recent_deployment("FundMe",block.chainid);
    withdrawFundMe(MostRecentlyDeployed);
}

}



