# backend

![example workflow](https://github.com/cubiclearn/backend/actions/workflows/test.yml/badge.svg)

contracts &amp; tests

[SBTs research and considerations](https://hackmd.io/@donnoh-eth/SBTs).

## usage

- install [foundry](https://github.com/foundry-rs/foundry)
- clone repo
- cd into repo
- run `forge install`
- to build, run `forge build`
- to run tests, run `forge test`
- to check coverage, run `forge coverage`

more info about foundry: [foundry book](https://book.getfoundry.sh/)

## how to use in a local network

- run `anvil`, which creates a local EVM network and copy one of the private keys
- open another terminal and deploy the contract with `forge create --rpc-url http://127.0.0.1:8545 --constructor-args "Soulbound NFT" "SBT" "https://sbt.com/" "100" --private-key <PRIVATE_KEY> src/SBT.sol:SoulboundNFT` or different constructor args
- save the "deployed to" address, which is the address of the contract in the local network
- check that everything's working with `cast call <CONTRACT_ADDRESS> "name()" --rpc-url http://127.0.0.1:8545 | cast --to-ascii` which should output the given name of the contract, in this case "Soulbound NFT"
