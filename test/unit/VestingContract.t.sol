// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {DeployVestingContract} from "script/DeployVestingContract.s.sol";
import {VestifyToken} from "src/VestifyToken.sol";
import {VestingContract} from "src/VestingContract.sol";

contract VestingContractTest is Test {
    DeployVestingContract vestingContractDeployer;
    VestingContract vestingContract;
    VestifyToken vestifyToken;
    address BENEFICIARY = makeAddr("beneficiary");

    function setUp() external {
        vestingContractDeployer = new DeployVestingContract();
        (vestingContract, vestifyToken) = vestingContractDeployer.run();
    }

    function testThatCorrectTokenAddressIsStored() public view {
        assert(
            vestingContract.getVestifyTokenContract() == address(vestifyToken)
        );
    }

    function testThatScheduleIsCreatedCorrectly() public {
        uint256 startTimestamp = block.timestamp + (1 * 24 * 60 * 60); //start one day from now
        uint256 endTimestamp = block.timestamp + (7 * 24 * 60 * 60); //start 7 days from now
        uint256 cliffTimestamp = block.timestamp + (4 * 24 * 60 * 60); //start 4 days from now
        uint256 totalAmount = 50e18;

        vm.prank(DEFAULT_SENDER);
        vestingContract.createVestingSchedule(
            BENEFICIARY,
            startTimestamp,
            endTimestamp,
            cliffTimestamp,
            totalAmount
        );

        VestingContract.VestingSchedule
            memory newVestingSchedule = vestingContract.getVestingSchedule(
                BENEFICIARY
            );

        assert(startTimestamp == newVestingSchedule.startTimestamp);
        assert(endTimestamp == newVestingSchedule.endTimestamp);
        assert(cliffTimestamp == newVestingSchedule.cliffTimestamp);
        assert(totalAmount == newVestingSchedule.totalAmount);
    }

    // function testThatRevertHappensWithInvalidStartDate() public {

    // }
}
