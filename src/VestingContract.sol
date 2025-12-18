// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/access/Ownable.sol";
import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";

/**
 * @title Vesting Contract
 * @notice Manages locked and released Vestify tokens
 */
contract VestingContract is Ownable {
    // Types
    struct VestingSchedule {
        address userAddress;
        uint256 startTimestamp;
        uint256 endTimestamp;
        uint256 cliffTimestamp;
        uint256 totalAmount;
        uint256 releasedAmount;
    }

    // State variables
    uint256 private vestifyTokenBalance;
    VestingSchedule[] private s_vestingScheduleList;
    mapping(address => uint256) private s_addressToVestingIdxPlusOne;

    // Errors
    error VestingContract__AmountLessThanZero();
    error VestingContract__InvalidVestingPeriod();

    constructor() Ownable(msg.sender) {}

    /**
     * @notice Creates a new vesting schedule for a user
     * @param user The address of the user receiving the vested tokens
     * @param startTimestamp The timestamp when vesting begins
     * @param endTimestamp The timestamp when vesting ends
     * @param cliffTimestamp The timestamp before which no tokens can be released
     * @param totalAmount The total amount of tokens to be vested
     */
    function createVestingSchedule(
        address userAddress,
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

        VestingSchedule memory newVestingSchedule = VestingSchedule({
            userAddress: userAddress,
            startTimestamp: startTimestamp,
            endTimestamp: endTimestamp,
            cliffTimestamp: cliffTimestamp,
            totalAmount: totalAmount,
            releasedAmount: 0
        });

        s_addressToVestingIdxPlusOne[user] = s_vestingScheduleList.length + 1;
        s_vestingScheduleList.push(newVestingSchedule);
    }
}
