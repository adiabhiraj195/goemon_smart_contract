// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "../src/goemon/GoemonPermit2.sol";

contract DeployMyContract is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey); // Starts transaction broadcast

        address permit2Address = 0x000000000022D473030F116dDEE9F6B43aC78BA3;

        GoemonPermit2 token = new GoemonPermit2(permit2Address);

        console.log("MyContract deployed at:", address(token));

        vm.stopBroadcast();
    }
}
