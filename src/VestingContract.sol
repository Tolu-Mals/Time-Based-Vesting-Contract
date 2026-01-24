// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/access/Ownable.sol";
import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";
import {
    AutomationCompatibleInterface
} from "@chainlink-contracts/automation/AutomationCompatible.sol";
import {
    AutomationBase
} from "@chainlink-contracts/automation/AutomationBase.sol";

/**
 * @title Vesting Contract
 * @notice Manages locked and released Vestify tokens
 */
contract VestingContract is
    Ownable,
    AutomationCompatibleInterface,
    AutomationBase
{
    // Types
    struct VestingSchedule {
        address beneficiaryAddress;
        uint256 startTimestamp;
        uint256 lastTimestamp;
        uint256 endTimestamp;
        uint256 cliffTimestamp;
        uint256 totalAmount;
        uint256 releasedAmount;
        uint256 withdrawnAmount;
        uint256 amountPerDay;
    }

    // State variables
    uint256 private vestifyTokenBalance;
    uint256 private constant ONE_DAY_IN_SECONDS = 24 * 60 * 60;
    VestingSchedule[] private s_vestingScheduleList;

    // Errors
    error VestingContract__AmountNotGreaterThanZero();
    error VestingContract__InvalidVestingPeriod();

    constructor() Ownable(msg.sender) {}

    /**
     * @notice Creates a new vesting schedule for a user
     * @param beneficiaryAddress The address of the user receiving the vested tokens
     * @param startTimestamp The timestamp when vesting begins
     * @param endTimestamp The timestamp when vesting ends
     * @param cliffTimestamp The timestamp before which no tokens can be released
     * @param totalAmount The total amount of tokens to be vested
     */
    function createVestingSchedule(
        address beneficiaryAddress,
        uint256 startTimestamp,
        uint256 endTimestamp,
        uint256 cliffTimestamp,
        uint256 totalAmount
    ) external onlyOwner {
        if (totalAmount <= 0)
            revert VestingContract__AmountNotGreaterThanZero();

        if (startTimestamp > cliffTimestamp || cliffTimestamp > endTimestamp)
            revert VestingContract__InvalidVestingPeriod();

        // Transfer vestify tokens from caller to this contract
        IERC20(address(0)).transferFrom(msg.sender, address(this), totalAmount);

        uint256 amountPerDay = totalAmount /
            ((endTimestamp - startTimestamp) / ONE_DAY_IN_SECONDS);

        VestingSchedule memory newVestingSchedule = VestingSchedule({
            beneficiaryAddress: beneficiaryAddress,
            startTimestamp: startTimestamp,
            endTimestamp: endTimestamp,
            cliffTimestamp: cliffTimestamp,
            totalAmount: totalAmount,
            releasedAmount: 0,
            withdrawnAmount: 0,
            lastTimestamp: block.timestamp,
            amountPerDay: amountPerDay
        });

        s_vestingScheduleList.push(newVestingSchedule);
    }

    function checkUpkeep(
        bytes calldata
        // checkData
    )
        external
        view
        override
        cannotExecute
        returns (bool upkeepNeeded, bytes memory performData)
    {
        uint256[] memory idsToProcess = new uint256[](
            s_vestingScheduleList.length
        );
        uint256 count = 0;

        for (uint256 i = 0; i < s_vestingScheduleList.length; i++) {
            VestingSchedule memory vestingSchedule = s_vestingScheduleList[i];

            bool shouldProcessSchedule = (block.timestamp -
                vestingSchedule.lastTimestamp >
                ONE_DAY_IN_SECONDS) &&
                (vestingSchedule.releasedAmount <
                    vestingSchedule.totalAmount) &&
                (block.timestamp < vestingSchedule.endTimestamp);

            if (shouldProcessSchedule) {
                idsToProcess[count] = i;
                count = count + 1;
            }
        }

        //  resize array to match count, since we initialized to length of all vesting schedules
        assembly {
            mstore(idsToProcess, count)
        }

        if (idsToProcess.length > 0) {
            return (true, abi.encode(idsToProcess));
        } else {
            return (false, "");
        }
    }

    function performUpkeep(bytes calldata performData) external override {
        uint256[] memory idsToProcess = abi.decode(performData, (uint256[]));

        for (uint256 i = 0; i < idsToProcess.length; i++) {
            VestingSchedule
                memory currentVestingSchedule = s_vestingScheduleList[
                    idsToProcess[i]
                ];

            uint256 amountToRelease = currentVestingSchedule.amountPerDay;

            if (
                currentVestingSchedule.releasedAmount + amountToRelease >
                currentVestingSchedule.totalAmount
            ) {
                amountToRelease =
                    currentVestingSchedule.totalAmount -
                    currentVestingSchedule.releasedAmount;
            }

            currentVestingSchedule.releasedAmount =
                currentVestingSchedule.releasedAmount +
                amountToRelease;
            currentVestingSchedule.lastTimestamp = block.timestamp;

            s_vestingScheduleList[idsToProcess[i]] = currentVestingSchedule;
        }
    }
}
