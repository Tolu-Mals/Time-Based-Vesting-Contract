// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/token/ERC20/ERC20.sol";

contract VestifyToken is ERC20 {
    //Type Declarations

    // State variables
    address private _owner;
    bytes32 private constant MINT_SELECTOR =
        keccak256("_mint(address,uint256)");
    bytes32 private constant BURN_SELECTOR =
        keccak256("_burn(address,uint256)");

    constructor(uint256 initialSupply) ERC20("Vestify", "VSF") {
        _owner = msg.sender;
        _mint(msg.sender, initialSupply);
    }

    // Errors
    error VestifyToken__OnlyOwnerCanBurn();
    error VestifyToken__OnlyOwnerCanMint();

    // Modifiers
    modifier onlyOwner(bytes32 selector) {
        if (msg.sender != _owner) {
            if (selector == MINT_SELECTOR) {
                revert VestifyToken__OnlyOwnerCanMint();
            } else if (selector == BURN_SELECTOR) {
                revert VestifyToken__OnlyOwnerCanBurn();
            }
        }

        _;
    }

    function _mint(
        address account,
        uint256 value
    ) internal virtual override onlyOwner(MINT_SELECTOR) {
        super._mint(account, value);
    }

    function _burn(
        address account,
        uint256 value
    ) internal virtual override onlyOwner(BURN_SELECTOR) {
        super._burn(account, value);
    }
}
