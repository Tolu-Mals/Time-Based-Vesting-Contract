// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {VestifyToken} from "src/VestifyToken.sol";

contract DeployVestifyToken is Script {
    uint256 private constant INITIAL_SUPPLY = 1000e18;
    VestifyToken public vestifyToken;

    function run() public returns (VestifyToken) {
        vm.startBroadcast();
        vestifyToken = new VestifyToken(INITIAL_SUPPLY);
        vm.stopBroadcast();

        return vestifyToken;
    }
}
