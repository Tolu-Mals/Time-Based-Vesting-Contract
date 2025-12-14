// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/access/Ownable.sol";

contract VestingContract is Ownable {
    // Types
    struct VestingSchedule {
        address user;
        uint256 startTimestamp;
        uint256 endTimestamp;
        uint256 cliffTimestamp;
        uint256 totalAmount;
        uint256 releasedAmount;
    }

    // State variables
    uint256 vestifyTokenBalance;
    VestingSchedule[] private s_vestingScheduleList;
    mapping(address => uint256) s_addressToVestingIdxPlusOne;

    constructor() Ownable(msg.sender) {}

    function createVestingSchedule(
        address user,
        uint256 startTimestamp,
        uint256 endTimestamp,
        uint256 cliffTimestamp,
        uint256 totalAmount,
        uint256 releasedAmount
    ) external payable onlyOwner {
        VestingSchedule newVestingSchedule = VestingSchedule({
            user,
            startTimestamp, 
            endTimestamp,
            cliffTimestamp,
            totalAmount,
            releasedAmount
        });

       s_addressToVestingIdxPlusOne[user] = s_vestingScheduleList.length + 1;
       s_vestingScheduleList.push(newVestingSchedule);
    }
}
