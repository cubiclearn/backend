// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "forge-std/Script.sol";
import "src/Credentials/Credentials.sol";
import "src/Karma/KarmaAccessControluint64.sol";

contract LocalDeploy is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        SoulboundNFT creds = new Credentials("Credentials", "CREDS", "https://creds.com/", 100);
        new KarmaAccessControluint64(creds);

        vm.stopBroadcast();
    }
}
