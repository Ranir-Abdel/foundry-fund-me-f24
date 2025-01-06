// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.18;

import {Script}from "forge-std/Script.sol";

import {MockV3Aggregator}from "../test/mocks/MockV3Aggregator.sol";



contract HelperConfig is Script{

    struct NetworkConfig {
         address PriceFeed;
        //Eth en $ address;
        }

        MockV3Aggregator  mockPriceFeed;
        

        NetworkConfig public ActiveNetworkConfig;

        uint8 public constant DECIMALS= 8;
        int256 public constant INITIAL_PRICE=2000e8;

    constructor (){
        if (block.chainid==1115511) {
            ActiveNetworkConfig=GetSepoliaEthConfig();
        } else if (block.chainid==1){ActiveNetworkConfig=GetEthMainetConfig ();}
        else {
            ActiveNetworkConfig=GetOrCreateAnvilEthConfig();
        } 
    }

    function GetSepoliaEthConfig() public pure returns(NetworkConfig memory)  {
        NetworkConfig memory SepoliaConfig =NetworkConfig({PriceFeed:0x694AA1769357215DE4FAC081bf1f309aDC325306});
        return SepoliaConfig;
    }

    function GetOrCreateAnvilEthConfig ()public  returns(NetworkConfig memory){
        if (ActiveNetworkConfig.PriceFeed!=address(0)){return ActiveNetworkConfig;}
        vm.startBroadcast();
        mockPriceFeed=new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
        vm.stopBroadcast();
        
        NetworkConfig memory AnvilConfig = NetworkConfig({
            PriceFeed:address(mockPriceFeed)});
            return AnvilConfig;
    }

     function GetEthMainetConfig() public pure returns(NetworkConfig memory)  {
        NetworkConfig memory EthMainetConfig =NetworkConfig({PriceFeed:0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419});
        return EthMainetConfig;
    }




}