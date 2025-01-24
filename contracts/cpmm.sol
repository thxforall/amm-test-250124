// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.28;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

abstract contract BaseCPMM is ERC20 {
    ERC20 public token_a;
    ERC20 public token_b;

    uint public constant fee = 999; // 0.1% 수수료
    uint public k;

    event PriceWarning(string message, uint currentPrice);

    constructor(
        address _a,
        address _b,
        string memory name,
        string memory symbol
    ) ERC20(name, symbol) {
        token_a = ERC20(_a);
        token_b = ERC20(_b);
    }

    function initialize(
        uint initialA,
        uint initialB,
        uint lpMultiplier
    ) internal {
        require(
            token_a.allowance(msg.sender, address(this)) >= initialA,
            "Insufficient allowance for token A"
        );
        require(
            token_b.allowance(msg.sender, address(this)) >= initialB,
            "Insufficient allowance for token B"
        );

        token_a.transferFrom(msg.sender, address(this), initialA);
        token_b.transferFrom(msg.sender, address(this), initialB);

        k = initialA * initialB;
        _mint(msg.sender, initialA * lpMultiplier);
    }

    function getBalance() public view returns (uint, uint) {
        return (
            token_a.balanceOf(address(this)),
            token_b.balanceOf(address(this))
        );
    }

    function addLiquidity(address _token, uint _n) public {
        (uint bal_a, uint bal_b) = getBalance();

        bool isA = _token == address(token_a);

        if (isA) {
            uint _m = (_n * bal_b) / bal_a;
            token_a.transferFrom(msg.sender, address(this), _n);
            token_b.transferFrom(msg.sender, address(this), _m);
            uint _x = (totalSupply() * _n) / bal_a;
            _mint(msg.sender, _x);
        } else {
            uint _m = (_n * bal_a) / bal_b;
            token_b.transferFrom(msg.sender, address(this), _n);
            token_a.transferFrom(msg.sender, address(this), _m);
            uint _x = (totalSupply() * _n) / bal_b;
            _mint(msg.sender, _x);
        }
    }

    function withLiquidity(uint _n) public {
        (uint bal_a, uint bal_b) = getBalance();

        uint _a = (_n * bal_a) / totalSupply();
        uint _b = (_n * bal_b) / totalSupply();

        _burn(msg.sender, _n);

        token_a.transfer(msg.sender, _a);
        token_b.transfer(msg.sender, _b);
    }

    function swap(address _token, uint _n) public {
        (uint bal_a, uint bal_b) = getBalance();
        uint k = bal_a * bal_b;

        bool isA = _token == address(token_a);

        if (isA) {
            uint out = ((bal_b - (k / (bal_a + _n))) * fee) / 1000;
            token_a.transferFrom(msg.sender, address(this), _n);
            token_b.transfer(msg.sender, out);
        } else {
            uint out = ((bal_a - (k / (bal_b + _n))) * fee) / 1000;
            token_b.transferFrom(msg.sender, address(this), _n);
            token_a.transfer(msg.sender, out);
        }

        checkPriceWarning();
    }

    function checkPriceWarning() internal virtual;

    function getPrice() public view returns (uint) {
        (uint bal_a, uint bal_b) = getBalance();
        return (bal_a * 1e18) / bal_b;
    }

    function sqrt(uint x) internal pure returns (uint y) {
        uint z = x / 2 + 1;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
}
