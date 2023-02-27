// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GatekeeperOne {
    address public entrant;

    // the person who sends the request cannot be the person who sent the original request
    // if foo sends from contract A to B
    // contractA: msg.sender = foo; tx.origin = foo
    // contractB: msg.sender = A; tx.origin = foo
    modifier gateOne() {
        require(msg.sender != tx.origin);
        _;
    }

    // remaining gas must be a multiple 8191
    modifier gateTwo() {
        require(gasleft() % 8191 == 0);
        _;
    }

    // require 1: This line performs a check on _gateKey to ensure that the first 4 bytes of the 8-byte input parameter
    // match the second 2 bytes. This check is performed by casting the first 4 bytes of _gateKey to a uint32, casting the
    // entire _gateKey to a uint64, and comparing the two values using the == operator. If the check fails, the function will
    // revert with an error message "GatekeeperOne: invalid gateThree part one".

    // require 2: This line performs a check on _gateKey to ensure that the first 4 bytes of the 8-byte input parameter do
    // not match the entire 8-byte value. This check is performed by casting the first 4 bytes of _gateKey to a uint32, casting
    // the entire _gateKey to a uint64, and comparing the two values using the != operator. If the check fails, the function will
    // revert with an error message "GatekeeperOne: invalid gateThree part two".

    // require 3: This line performs a check on _gateKey and the origin address of the transaction to ensure that the first 4
    // bytes of _gateKey match the last 2 bytes of the origin address. This check is performed by casting the first 4 bytes of _gateKey
    // to a uint32, casting the last 2 bytes of the origin address to a uint16, and comparing the two values using the == operator.
    // If the check fails, the function will revert with an error message "GatekeeperOne: invalid gateThree part three".

    modifier gateThree(bytes8 _gateKey) {
        require(uint32(uint64(_gateKey)) == uint16(uint64(_gateKey)), "GatekeeperOne: invalid gateThree part one");
        require(uint32(uint64(_gateKey)) != uint64(_gateKey), "GatekeeperOne: invalid gateThree part two");
        require(uint32(uint64(_gateKey)) == uint16(uint160(tx.origin)), "GatekeeperOne: invalid gateThree part three");
        _;
    }
    //Overall, this function allows a user to enter a gate if they satisfy certain conditions checked
    //by the modifiers gateOne, gateTwo, and gateThree. If the conditions are met, the function sets
    //the value of a state variable entrant to the address of the user who called the function, and returns a boolean value true.

    function enter(bytes8 _gateKey) public gateOne gateTwo gateThree(_gateKey) returns (bool) {
        entrant = tx.origin;
        return true;
    }
}
