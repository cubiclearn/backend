# backend

![example workflow](https://github.com/cubiclearn/backend/actions/workflows/test.yml/badge.svg)

contracts &amp; tests

[SBTs research and considerations](https://hackmd.io/@donnoh-eth/SBTs).

## project structure

```ml
src
├── IERC5192 — "Minimal Soulbound Token Interface"
├── IERC5484 — "Consensual Soulbound Tokens"
├── SBT — "Implementation of IERC5192 extending ERC721"
├── SBTBurnable — "Implementation of IERC5484 extending SBT"
├── Credentials — "Mintable and Ownable SBT"
└── CredentialsBurnable — "Credentials with burn authorization"
test
├── SBT — "SBT tests"
├── SBTBurnable — "SBTBurnable tests"
├── Credentials — "Credentials tests"
└── CredentialsBurnable — "CredentialsBurnable tests"
```

## installation

- install [foundry](https://github.com/foundry-rs/foundry), which installs `forge`, `cast` and `anvil`.
- clone repo.
- cd into repo.
- run `forge install`.
- `pip install pre-commit`.
- `pre-commit install` to install the fmt and gas snapshot pre-commit hook.

## usage

- to build, run `forge build`.
- to run tests, run `forge test`.
- to check coverage, run `forge coverage`.
- to get a list of all the available methods of a contract, run `forge inspect src/Credentials.sol:Credentials methods` or similar.

more info about foundry: [foundry book](https://book.getfoundry.sh/)

## how to use in a local network

- run `anvil`, which creates a local EVM network and copy one of the private keys.
- open another terminal and deploy the contract with `forge create --rpc-url http://127.0.0.1:8545 --constructor-args "Credentials" "CREDS" "https://creds.com/" "100" --private-key <PRIVATE_KEY> src/Credentials.sol:Credentials` or different constructor args.
- save the "deployed to" address, which is the address of the contract in the local network.
- check that everything's working with `cast call <CONTRACT_ADDRESS> "name()" --rpc-url http://127.0.0.1:8545 | cast --to-ascii` which should output the given name of the contract, in this case "Credentials".
