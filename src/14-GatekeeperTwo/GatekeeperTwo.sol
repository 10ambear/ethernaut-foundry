// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract GatekeeperTwo {
    address public entrant;

    // ok so this one is easy, we need to write an attack function from a contract
    modifier gateOne() {
        require(msg.sender != tx.origin);
        _;
    }

    // Eth yellow paper states: During initialization code execution,
    // EXTCODESIZE on the address should return zero, which is the length of the
    // code of the account while CODESIZE should return the length of the initialization code
    // this means that the attack has to happen inside the ctor to return zero
    modifier gateTwo() {
        uint256 x;
        assembly {
            x := extcodesize(caller())
        }
        require(x == 0);
        _;
    }

    // This is a a super good video explaining how to get past the gate https://www.youtube.com/watch?v=BgFammIHN5s
    // the tldr is it's a bit of math, not too complex
    modifier gateThree(bytes8 _gateKey) {
        unchecked {
            require(uint64(bytes8(keccak256(abi.encodePacked(msg.sender)))) ^ uint64(_gateKey) == uint64(0) - 1);
        }

        _;
    }

    function enter(bytes8 _gateKey) public gateOne gateTwo gateThree(_gateKey) returns (bool) {
        entrant = tx.origin;
        return true;
    }
}
