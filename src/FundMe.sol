// SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

error FundMe__NotOwner();

contract FundMe {
    // RECEIVE ETH ? 0x694AA1769357215DE4FAC081bf1f309aDC325306
    AggregatorV3Interface private s_dataFeed;
    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 5e18;

    address[] private s_funders;
    mapping(address => uint256) private s_funderToAmountFunded;
    address private immutable i_owner;

    constructor(address dataFeed) {
        s_dataFeed = AggregatorV3Interface(dataFeed);
        i_owner = msg.sender;
    }

    function fund() public payable {
        require(
            msg.value.getConversionRate(s_dataFeed) > MINIMUM_USD,
            "Not enough Eth"
        );
        s_funders.push(msg.sender);
        s_funderToAmountFunded[msg.sender] += msg.value;
    }

    function version() external view returns (uint256) {
        return s_dataFeed.version();
    }

    // WITHDRAW ETH
    function withdraw() public onlyOwner {
        for (
            uint256 fundersIndex;
            fundersIndex < s_funders.length;
            fundersIndex++
        ) {
            address funder = s_funders[fundersIndex];
            s_funderToAmountFunded[funder] = 0;
        }

        (bool callSuccess, ) = payable(msg.sender).call{ value: address(this).balance}("");
        require(callSuccess, "Failed");

        s_funders = new address[](0);
    }

    function withdrawCheaper() public onlyOwner {
        uint256 fundersLength = s_funders.length;
        for (
            uint256 fundersIndex;
            fundersIndex < fundersLength;
            fundersIndex++
        ) {
            address funder = s_funders[fundersIndex];
            s_funderToAmountFunded[funder] = 0;
        }

        (bool callSuccess, ) = payable(msg.sender).call{ value: address(this).balance}("");
        require(callSuccess, "Failed");

        s_funders = new address[](0);
    }

    modifier onlyOwner() {
        if (msg.sender != i_owner) {
            revert FundMe__NotOwner();
        }
        _;
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    /**
     * View / Pure Functions (Getters)
     */

       
    // mapping(address => uint256) s_funderToAmountFunded;
    

    function getFunders(uint256 index) external view returns (address) {
        return s_funders[index];
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }

    function getAddressToAmountFunded(address fundingAdderess) external view returns (uint256 ) {
        return s_funderToAmountFunded[fundingAdderess];
    }
}
