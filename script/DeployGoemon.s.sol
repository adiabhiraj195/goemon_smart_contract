// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "../src/goemon/Goemon.sol";

contract DeployMyContract is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey); // Starts transaction broadcast

        // Permit2 address if deployed or you can deploy your own
        address permit2Address = 0x000000000022D473030F116dDEE9F6B43aC78BA3;
        // Deploy MyToken contract
        Goemon token = new Goemon(permit2Address);

        // Print the address of the deployed contract
        console.log("Goemon deployed at:", address(token));

        vm.stopBroadcast();
    }
}
