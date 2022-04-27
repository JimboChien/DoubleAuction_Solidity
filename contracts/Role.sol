// SPDX-License-Identifier: MIT
pragma solidity >=0.4.21 <8.10.0;

contract Role {
    struct Participant {
        address addr;
        int256 quantity;
        int256 price;
    }

    struct Result {
        address buyer;
        address seller;
        int256 quantity;
        int256 balance;
    }
}
