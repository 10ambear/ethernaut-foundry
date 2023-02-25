pragma solidity ^0.8.10;

import "lib/forge-std/lib/ds-test/src/test.sol";
import "../src/07-Force/ForceFactory.sol";
import "../src/07-Force/ForceHack.sol";
import "../src/Ethernaut.sol";
import "./utils/vm.sol";

contract ForceTest is DSTest {
    Vm vm = Vm(address(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D));
    Ethernaut ethernaut;
    address playerAddress = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266; // this address doesn't mean anything, this is just a placeholder for my own wallet address i.e. a metamask address

    function setUp() public {
        // Setup instance of the Ethernaut contract
        ethernaut = new Ethernaut();
        // Deal player address some ether
        vm.deal(playerAddress, 5 ether);
    }

    function testForceHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        ForceFactory forceFactory = new ForceFactory();
        ethernaut.registerLevel(forceFactory);
        vm.startPrank(playerAddress);
        address levelAddress = ethernaut.createLevelInstance(forceFactory);
        Force ethernautForce = Force(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////

        // Create the attacking contract which will self destruct and send ether to the Force contract
        ForceHack forceHack = (new ForceHack){value: 0.1 ether}(payable(levelAddress));

        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////

        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}
