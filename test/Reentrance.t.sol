pragma solidity ^0.8.10;

import "lib/forge-std/lib/ds-test/src/test.sol";
import "../src/10-Reentrance/ReentranceHack.sol";
import "../src/10-Reentrance/ReentranceFactory.sol";
import "../src/Ethernaut.sol";
import "./utils/vm.sol";

contract ReentranceTest is DSTest {
    Vm vm = Vm(address(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D));
    Ethernaut ethernaut;
    address playerAddress = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266; // this address doesn't mean anything, this is just a placeholder for my own wallet address i.e. a metamask address

    function setUp() public {
        // Setup instance of the Ethernaut contract
        ethernaut = new Ethernaut();
        vm.deal(playerAddress, 3 ether);
    }

    function testReentranceHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        ReentranceFactory reentranceFactory = new ReentranceFactory();
        ethernaut.registerLevel(reentranceFactory);
        vm.startPrank(playerAddress);
        address levelAddress = ethernaut.createLevelInstance{value: 1 ether}(reentranceFactory);
        Reentrance ethernautReentrance = Reentrance(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////

        // Create ReentranceHack contract
        ReentranceHack reentranceHack = new ReentranceHack(levelAddress);

        // Call the attack function to drain the contract
        reentranceHack.attack{value: 0.4 ether}();

        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////

        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}
