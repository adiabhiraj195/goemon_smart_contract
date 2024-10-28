// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "../src/goemon/MultiSigWallet.sol";

contract DeployMyContract is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey); // Starts transaction broadcast

        // Permit2 address if deployed or you can deploy your own
        address[] memory addresses = new address[](3);
        addresses[0] = address(0xF478b3472335129bBDB7fcF4453C4b73C00F4571);
        addresses[1] = address(0xF478b3472335129bBDB7fcF4453C4b73C00F4571);
        addresses[2] = address(0x1111111111111111111111111111111111111111);
        // Deploy MyToken contract
        MultiSigWallet token = new MultiSigWallet(addresses, 2);

        // Print the address of the deployed contract
        console.log("Goemon deployed at:", address(token));

        vm.stopBroadcast();
    }
}
