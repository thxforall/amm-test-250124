// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.28;

import "./cpmm.sol";

contract Test2CPMM is BaseCPMM {
    constructor(
        address _a,
        address _b
    ) BaseCPMM(_a, _b, "Test2 ABLP Token", "T2ABLP") {
        // 초기 가격 비율 A:B = 5:1, 초기 k = 1,250,000,000,000
        uint initialB = sqrt(1250000000000 / 5); 
        uint initialA = initialB * 5;            

        initialize(initialA, initialB, 5); 
    }

    function checkPriceWarning() internal override {
        uint price = getPrice();
        if (price <= 2.5 * 1e18) {
            emit PriceWarning("Price dropped below 2.5:1", price);
        }
    }
}