// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract TestSimple {
    string public message;

    constructor() {
        message = "Hello DAOShop";
    }

    function setMessage(string memory _message) public {
        message = _message;
    }
}