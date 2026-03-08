// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {VestingContract} from "src/VestingContract.sol";
import {VestifyToken} from "src/VestifyToken.sol";

contract DeployVestingContract is Script {
    uint256 private constant INITIAL_SUPPLY = 1000e18;
    VestifyToken vestifyToken;
    VestingContract vestingContract;

    function run() public returns (VestingContract, VestifyToken) {
        deployToken();

        vm.startBroadcast();
        vestingContract = new VestingContract(address(vestifyToken));
        vm.stopBroadcast();

        return (vestingContract, vestifyToken);
    }

    function deployToken() public {
        vm.startBroadcast();
        vestifyToken = new VestifyToken(INITIAL_SUPPLY);
        vm.stopBroadcast();
    }
}
