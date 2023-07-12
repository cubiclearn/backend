// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "forge-std/Script.sol";
import "src/Credentials/Credentials.sol";
import "src/Karma/KarmaAccessControluint64.sol";
import "src/Credentials/Factory.sol";

contract FactoryDeploy is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        new CredentialsFactory();
        vm.stopBroadcast();
    }
}
