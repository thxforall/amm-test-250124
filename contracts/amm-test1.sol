// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.28;

import "./cpmm.sol";

contract Test1CPMM is BaseCPMM {
    constructor(
        address _a,
        address _b
    ) BaseCPMM(_a, _b, "Test1 ABLP Token", "T1ABLP") {
        // 초기 가격 비율 A:B = 3:1, 초기 k = 30,000,000,000
        uint initialB = sqrt(30000000000 / 3);
        uint initialA = initialB * 3;

        initialize(initialA, initialB, 10);
    }

    function checkPriceWarning() internal override {}
}
