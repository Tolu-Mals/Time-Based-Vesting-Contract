// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {DeployVestingContract} from "script/DeployVestingContract.s.sol";
import {VestifyToken} from "src/VestifyToken.sol";
import {VestingContract} from "src/VestingContract.sol";

contract VestingContractTest is Test {
    function setUp() external {}

    function testThatCorrectTokenAddressIsStored() public {
        DeployVestingContract vestingContractDeployer = new DeployVestingContract();
        (
            VestingContract vestingContract,
            VestifyToken vestifyToken
        ) = vestingContractDeployer.run();

        assert(
            vestingContract.getVestifyTokenContract() == address(vestifyToken)
        );
    }
}
