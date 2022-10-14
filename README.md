# Aptos Fundable Token storage
The project aims to show `Aptos` features and highlight important security points

- [Aptos Fundable Token storage](#aptos-fundable-token-storage)
  - [Aptos CLI](#aptos-cli)
    - [Instalation](#instalation)
    - [Account commands](#account-commands)
    - [Move commands](#move-commands)
  - [Common used options and errors](#common-used-options-and-errors)
    - [Options](#options)
    - [Errors](#errors)
  - [Architecture](#architecture)
  - [Code notes](#code-notes)
  - [Getting started](#getting-started)
  - [Functional requirements](#functional-requirements)


## Aptos CLI
[Aptos CLI](https://github.com/aptos-labs/aptos-core/releases?q=CLI) is the main tool needed for development on aptos blockchain

It manages accounts, compiles and publishes modules to blockchain, resolve transactions, etc.

### Instalation
Download the binary file from [github release](https://github.com/aptos-labs/aptos-core/releases?q=CLI) and put it to any directory defined in `$PATH`

Use `aptos config set-global-config --config-type VALUE` to chose where profiles info will be stored:
- `Workspace` - in local directory of each project
- `Global` - in `HOME` dir

### Account commands
- `aptos init` - create new on-chain account profile

  Common used option is `PROFILE`

- `aptos account fund-with-faucet --account PROFILE` - fund specified account from faucet

  Common known error is `411_LENGTH_REQUIRED`

### Move commands
- `aptos move compile` - compile module depending on `Move.toml` config

  Common used option is `NAMED_ADDRESSES`

- `aptos move publish` - publish module to blockchain

  Common used options are `NAMED_ADDRESSES` and `PROFILE`

  Common known error is `RESOURCE_NOT_FOUND`

- `aptos move run` - run entry function of specified module

  Common used options are `FUNCTION_ID`, `TYPE_ARGS`, `ARGS` and `PROFILE`

  Common known errors are `RESOURCE_NOT_FOUND` and `MAX_GAS_UNITS_BELOW_MIN_TRANSACTION_GAS_UNITS`

- `aptos move test` - run tests for the module

  Common used option is `NAMED_ADDRESSES`


## Common used options and errors
### Options
- `Option<PROFILE>` - is needed for defining profile which is used for context of the command

  `--profile NAME`

- `Option<NAMED_ADDRESSES>` - is needed for defining addresses that is defined in `Move.toml` as `_` (for example, address where module will be published)

  `--named-addresses NAME=ADDRESS`

- `Option<FUNCTION_ID>` - is needed for defining which exactly `FUNCTION` in which `MODULE` at which `ADDRESS` should be called

  `--function-id 'ADDRESS::MODULE::FUNCTION'`

- `Option<TYPE_ARGS>` - is needed for defining generic `RESOURCE` type located in specified `MODULE` at the `ADDRESS`, it may be used by the function if it process different data types depending on resource (for example, functions processing different coin types)

  `--type-args 'ADDRESS::MODULE::RESOURCE'`

- `Option<FUNCTION_ID>` - is needed for defining function parameters of `TYPE` containing `VALUE`, look help command for list of all supported types

  `--args 'TYPE:VALUE'`

### Errors
- `Error<RESOURCE_NOT_FOUND>` - it may appear in case if not enough APT is presented on the account: use a faucet to get more `APT Coin`

  `"Error": "API error: API error Error(ResourceNotFound): Resource not found by Address(ADDRESS), Struct tag(TAG) and Ledger version(VERSION)"`

- `Error<MAX_GAS_UNITS_BELOW_MIN_TRANSACTION_GAS_UNITS>` - it may appear in case if amount of APT presented on the account is enough for the transaction but is lower then minimum Gas units attached to transaction: use a faucet to get more `APT Coin`

  `"Error": "Simulation failed with status: Transaction Executed and Committed with Error MAX_GAS_UNITS_BELOW_MIN_TRANSACTION_GAS_UNITS"`

- `Error<411_LENGTH_REQUIRED>` - it may happen if you use outdated Aptos CLI version, it was fixed on v0.3.7

  `"Error": "API error: Faucet issue: 411 Length Required"`

- `Error<502_BAD_GATEWAY>` - it happens sometimes, try again

  `"Error": "API error: 502 Bad Gateway"`


## Architecture

## Code notes

## Getting started

## Functional requirements