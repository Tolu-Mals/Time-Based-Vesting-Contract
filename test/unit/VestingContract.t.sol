// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {DeployVestifyToken} from "script/DeployVestifyToken.s.sol";
import {DeployVestingContract} from "script/DeployVestingContract.s.sol";
import {VestifyToken} from "src/VestifyToken.sol";
import {VestingContract} from "src/VestingContract.sol";

contract VestingContractTest is Test {
    function setUp() external {}

    function testThatCorrectTokenAddressIsStored() public view {
        DeployVestifyToken vestifyTokenDeployer = new DeployVestifyToken();
        VestifyToken vestifyToken = new VestifyToken();

        DeployVestingContract VestingContractDeployer = new DeployVestingContract();
        VestingContract VestingContract = new VestingContract(
            address(vestifyToken)
        );

        assert(
            VestingContract.getVestifyTokenContract() == address(vestifyToken)
        );
    }
}
