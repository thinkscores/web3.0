// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract HelloWorld {
    string h = "hello, world!";

    function getH() public view returns (string memory) {
        return h;
    }
}