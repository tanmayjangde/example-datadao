// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MusicToken is ERC20 {

    uint256 public tokenCount;

    constructor() ERC20("GOV", "Gov DataDao") {
        _mint(msg.sender, 1000);
    }

    function mint(address to) public {
        tokenCount = tokenCount + 1;
        _mint(to, tokenCount);
    }

}