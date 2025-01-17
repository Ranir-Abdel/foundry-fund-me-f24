// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;


import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "../src/PriceConverter.sol";

error FundMe_NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    mapping(address => uint256) private s_AddressToAmountFunded;
    address[] private s_Funders;

    
    address public  i_owner;
    uint256 public constant MinimumUSD = 5e18;

    AggregatorV3Interface private s_priceFeed;

    constructor(address PriceFeed) {
        i_owner = msg.sender;
        s_priceFeed=AggregatorV3Interface(PriceFeed);
    }

    function fund() public payable {
        require(msg.value.getConversionRate(s_priceFeed) >=MinimumUSD, "You need to spend more ETH!");
        // require(PriceConverter.getConversionRate(msg.value) >= MINIMUM_USD, "You need to spend more ETH!");
        s_AddressToAmountFunded[msg.sender] += msg.value;
        s_Funders.push(msg.sender);
    }

    function GetVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    modifier OnlyOwner() {
        // require(msg.sender == owner);
        if (msg.sender != i_owner) revert FundMe_NotOwner();
        _;
    }

   

    function Withdraw() public OnlyOwner {
        for (uint256 funderIndex = 0; funderIndex < s_Funders.length; funderIndex++) {
            address funder = s_Funders[funderIndex];
            s_AddressToAmountFunded[funder] = 0;
        }
        s_Funders = new address[](0); 
        
        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    function CheaperWhithdraw() public OnlyOwner {
        uint256 FundersLength =s_Funders.length;

       for(uint funderIndex=0;funderIndex < FundersLength;funderIndex=funderIndex+1){
        address funder = s_Funders[funderIndex];
        s_AddressToAmountFunded[funder]=0;
       }
       
       (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");

       
    

    }


   

    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }


    function GetAdressToAmountFunded (address FundingAddress)public view returns(uint) {
        return s_AddressToAmountFunded[FundingAddress];
    }

    function GetFunders(uint index) public view returns(address){
        return s_Funders[index];
    }

    function GetOwner ()external view returns(address) {
        return i_owner;
    }




}



