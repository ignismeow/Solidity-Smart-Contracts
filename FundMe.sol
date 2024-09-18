// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// Importing PriceConverter library to handle price conversions for funding in USD
import { PriceConverter } from "PriceConverter.sol";

// Main contract for managing funds
contract FundMe {
    // Using PriceConverter for uint256 type to access conversion functions
    using PriceConverter for uint256;

    // Constant for minimum USD funding value (5 USD equivalent in Ether)
    uint256 public constant MINIMUM_USD = 5 * 1e18;

    // Array to store addresses of funders
    address[] public funders;

    // Mapping to track how much each address has funded
    mapping (address funder => uint256 amountFunded) public addressToAmountFunded;

    // Owner of the contract (immutable after deployment)
    address public immutable i_owner;

    // Predefined custom error for access control
    error NotOwner();

    // Constructor setting the owner of the contract to the deployer
    constructor() {
        i_owner = msg.sender;
    }

    // Function to allow funding the contract, requires minimum USD equivalent in ETH
    function fund() public payable {
        // Require that the sent value meets the minimum funding in USD
        require(msg.value.getConversionRate() >= MINIMUM_USD, "Didn't have enough Eth");

        // Add funder to the funders array
        funders.push(msg.sender);

        // Track the amount funded by each address
        addressToAmountFunded[msg.sender] += msg.value;
    }

    // Function to allow only the owner to withdraw funds from the contract
    function withdraw() public OnlyOwner {
        // Reset funded amount for each funder
        for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }

        // Reset the funders array
        funders = new address[](0) ;

        // Withdraw funds using the call method to prevent potential issues with transfer and send
        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    // Modifier to restrict access to certain functions to the owner only
    modifier OnlyOwner() {
        // Check if the caller is the owner, otherwise revert with NotOwner error
        if (msg.sender != i_owner) {
            revert NotOwner();
        }
        _;
    }

    // Fallback function to handle direct ETH transfers without function calls (calls fund())
    receive() external payable {
        fund();
    }

    // Fallback function triggered when the contract is called without matching any function signature
    fallback() external payable {
        fund();
    }
}
