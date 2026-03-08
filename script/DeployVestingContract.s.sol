// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {VestingContract} from "src/VestingContract.sol";
import {VestifyToken} from "src/VestifyToken.sol";
import {DeployVestifyToken} from "script/DeployVestifyToken.s.sol";

contract DeployVestingContract is Script {
    function run()
        public
        returns (VestingContract vestingContract, VestifyToken vestifyToken)
    {
        DeployVestifyToken vestifyTokenDeployer = new DeployVestifyToken();
        vestifyToken = vestifyTokenDeployer.run();

        vm.startBroadcast();
        vestingContract = new VestingContract(address(vestifyToken));
        vm.stopBroadcast();

        return (vestingContract, vestifyToken);
    }
}
