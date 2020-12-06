# Balancer Pool Deployer

A simple contract to allow single transaction deployment of Balancer pools (both standard and smart) where performing a delegatecall to interact with [Balancer's BActions contract](https://github.com/balancer-labs/bactions-proxy) is not possible.

The contract's implementation is identical to the BActions contract while transferring ownership over any created pools to `msg.sender`.

## Usage

### Prerequisites

Before running any command, make sure to install dependencies:

```sh
$ yarn install
```

### Compile

Compile the smart contracts with Hardhat:

```sh
$ yarn compile
```

### TypeChain

Compile the smart contracts and generate TypeChain artifacts:

```sh
$ yarn build
```

### Lint Solidity

Lint the Solidity code:

```sh
$ yarn lint:sol
```

### Lint TypeScript

Lint the TypeScript code:

```sh
$ yarn lint:ts
```

### Clean

Delete the smart contract artifacts, the coverage reports and the Hardhat cache:

```sh
$ yarn clean
```
