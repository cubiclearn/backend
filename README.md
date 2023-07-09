# backend

![example workflow](https://github.com/cubiclearn/backend/actions/workflows/test.yml/badge.svg)

contracts &amp; tests

[SBTs research and considerations](https://hackmd.io/@donnoh-eth/SBTs).

## Installation

- Install [foundry](https://github.com/foundry-rs/foundry).
- Clone repo.
- `cd` into repo.
- Run `forge install`.
- `pip install pre-commit`.
- `pre-commit install` to install the fmt and gas snapshot pre-commit hook.

## Usage

- To build, run `forge build`.
- To run tests, run `forge test`.
- To check coverage, run `forge coverage`.
- To run [slither](https://github.com/crytic/slither), install it and run `slither .`.
- To run [mythril](https://github.com/ConsenSys/mythril), install it and run `myth analyze src/Credentials/Credentials.sol --solc-json mythril.config.json` or similar.
- To get a list of all the available methods of a contract, run `forge inspect src/Credentials/Credentials.sol:Credentials methods` or similar.

more info about foundry: [foundry book](https://book.getfoundry.sh/)

## Local network deployment

- Run `anvil`, which creates a local EVM network.
- Copy one of the private keys and paste it in the `.env` file.
- Open another terminal and run `source .env`.
- Run `forge script script/Credentials.s.sol:LocalDeploy --fork-url $LOCAL_RPC_URL --broadcast`.
