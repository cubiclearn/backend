// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "forge-std/Script.sol";
import "src/Karma/KarmaAccessControluint64.sol";

contract LocalDeploy is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        new KarmaAccessControluint64(CredentialsBurnable(vm.envAddress("CREDENTIALS")), 0, 0);

        vm.stopBroadcast();
    }
}
