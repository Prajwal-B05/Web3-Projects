// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract MultiSig {
    //State variables
    address[] public owners;
    uint txnID;
    uint public required;
    struct Transaction {
        address destination;
        uint value;
        bool executed;
    }
    mapping(uint => mapping(address => bool)) public confirmations;
    Transaction[] public transactions;

    //Contructor function
    constructor(address[] memory x, uint y) {
        require(x.length >= 0);
        require(y > 0);
        require(y < x.length);
        owners = x;
        {
    }
}
