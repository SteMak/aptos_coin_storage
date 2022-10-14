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
    - [Repo structure](#repo-structure)
    - [Move.toml](#movetoml)
    - [Module structure](#module-structure)
  - [Code notes](#code-notes)
  - [Getting started](#getting-started)
  - [Functional requirements](#functional-requirements)
    - [Deposit](#deposit)
    - [Withdraw](#withdraw)
    - [Balance](#balance)


## Aptos CLI
[Aptos CLI](https://github.com/aptos-labs/aptos-core/releases?q=CLI) is the primary tool needed for development on the Aptos blockchain

It manages accounts, compiles and publishes blockchain modules, resolves transactions, etc.

### Instalation
Download the binary file from [github release](https://github.com/aptos-labs/aptos-core/releases?q=CLI) and put it to any directory defined in `$PATH`

Use `aptos config set-global-config --config-type VALUE` to choose where profiles info will be stored:
- `Workspace` - in a local directory of each project
- `Global` - in the `HOME` dir

### Account commands
- `aptos init` - create a new on-chain account profile

  Common used option is `PROFILE`

- `aptos account fund-with-faucet --account PROFILE` - fund specified account from a faucet

  Common known error is `411_LENGTH_REQUIRED`

### Move commands
- `aptos move compile` - compile the module depending on `Move.toml` config

  Common used option is `NAMED_ADDRESSES`

- `aptos move publish` - publish the module to blockchain

  Common used options are `NAMED_ADDRESSES` and `PROFILE`

  Common known error is `RESOURCE_NOT_FOUND`

- `aptos move run` - run entry function of the specified module

  Common used options are `FUNCTION_ID`, `TYPE_ARGS`, `ARGS` and `PROFILE`

  Common known errors are `RESOURCE_NOT_FOUND` and `MAX_GAS_UNITS_BELOW_MIN_TRANSACTION_GAS_UNITS`

- `aptos move test` - run tests for the module

  Common used option is `NAMED_ADDRESSES`


## Common used options and errors
### Options
- `Option<PROFILE>` - is needed for defining the profile which is used for a context of the command

  `--profile NAME`

- `Option<NAMED_ADDRESSES>` - is needed for defining addresses that are described in `Move.toml` as `_` (for example, address where a module will be published)

  `--named-addresses NAME=ADDRESS`

- `Option<FUNCTION_ID>` - is needed for defining which exactly `FUNCTION` in which `MODULE` at which `ADDRESS` should be called

  `--function-id 'ADDRESS::MODULE::FUNCTION'`

- `Option<TYPE_ARGS>` - is needed for defining generic `RESOURCE` type located in specified `MODULE` at the `ADDRESS`, it may be used by the function if it process different data types depending on resource (for example, functions processing different coin types)

  `--type-args 'ADDRESS::MODULE::RESOURCE'`

- `Option<FUNCTION_ID>` - is needed for defining function parameters of `TYPE` containing `VALUE`, look help command for a list of all supported types

  `--args 'TYPE:VALUE'`

### Errors
- `Error<RESOURCE_NOT_FOUND>` - it may appear in case if not enough APT is presented on the account: use a faucet to get more `APT Coin`

  `"Error": "API error: API error Error(ResourceNotFound): Resource not found by Address(ADDRESS), Struct tag(TAG) and Ledger version(VERSION)"`

- `Error<MAX_GAS_UNITS_BELOW_MIN_TRANSACTION_GAS_UNITS>` - it may appear in case if the amount of APT presented on the account is enough for the transaction but is lower than minimum Gas units attached to the transaction: use a faucet to get more `APT Coin`

  `"Error": "Simulation failed with status: Transaction Executed and Committed with Error MAX_GAS_UNITS_BELOW_MIN_TRANSACTION_GAS_UNITS"`

- `Error<411_LENGTH_REQUIRED>` - it may happen if you use an outdated Aptos CLI version, it was fixed on `v0.3.7`

  `"Error": "API error: Faucet issue: 411 Length Required"`

- `Error<502_BAD_GATEWAY>` - it happens sometimes, try again

  `"Error": "API error: 502 Bad Gateway"`


## Architecture
### Repo structure
`build/` - dir contains module artifacts

`sources/` - dir contains move modules

`Move.toml` - configuration file

### Move.toml
`[package]` section contains
- `name` identifier - is used when adding the repo as a dependency of another project
- `version` - simple semver identifier
- `upgrade_policy` - may be
  - `immutable` - no code updates allowed
  - `compatible` (is default) - new resources and functions may be added but old ones should be kept

`[addresses]` section contains named addresses that may be used in code
- Common used `aptos_std = "0x1"` or just `std = "0x1"`
- Named address that should be provided as parameter during compilation `NAME = "_"`

`[dependencies]` section may contain local and global deps
- Common used `devnet` version of `aptos-framework`

  `AptosFramework = { git = "https://github.com/aptos-labs/aptos-core.git", subdir = "aptos-move/framework/aptos-framework/", rev = "devnet" }`

- Or just import a local package (may be useful in case of huge project with a lot of modules interacting each other)

  `LOCAL_PACK = { local = "LOCAL_PATH" }`

### Module structure
Module definition is `module ADDRESS::MODULE_NAME { ... }`

In module there are:
- Imports:

  Imports are defined by the `use ADDRESS::MODULE` pattern and the imported modules/functions/structs may be used through the code

- Structs and Resources:
  - Structs are defined by keyword `struct` and may have typed fields

    Structs may be copyable and droppable like simple variables

    Struct may be generated based on generic type `struct NAME<phantom GENERIC>{ ... }`

  - Resources are undroppable and uncopyable structs

    Resources should be moved to storage or destroyed according to module policy before the transaction ends

    It is considered storing resources on user accounts (not in module storage)

- Friends:
  
  Friends are modules whitelisted to run `public(friend)` functions

  `friend ADDRESS::MODULE`

- Functions

  Functions could be
  - `entry` - callable by user outside from blockchain
  - `public` - callable by any other modules
  - `public(friend)` - callable by friend modules
  - `no modifier` - are internal only accessible in the module

  Functions could have generic `type argument`

  `fun FUNCTION<GENERIC>(ARGS: TYPES): RETURN_TYPE { CODE_DEPENDS_ON<GENERIC> }`

Structs, friends and functions may be marked by `#[test_only]`

This means the code is applied only for tests and is not accessible on-chain


## Code notes

## Getting started

## Functional requirements
Module `CoinStorage` should be have
- immutable upgrade policy
- deployable on any address

It should be implemented a mechanism of depositing/withdrawing of any standard coin

It should be possible for anyone who manages user's `signer` object to deposit coins

It should not be possible for anyone except of the user directly to withdraw user funds

### Deposit
Accepts user deposit, creates wrapper resource moving it to caller account

Signature:
- `<CoinType>`: `resource` - resource of coin which will be deposited
- `account`: `&signer` - link to caller signer object
- `amount`: `u64` - amount of coins to deposit

Fail conditions:
- `NotFound(ECOIN_STORE_NOT_PUBLISHED)` - user is not registred in the coin module
- `PermissionDenied(EFROZEN)` - user coin account is frozen
- `InvalidArgument(EINSUFFICIENT_BALANCE)` - user don't have enough funds
  
Return: `void`

### Withdraw
Transfer user deposit back, is callable only by user itself

Signature:
- `<CoinType>`: `resource` - resource of coin which will be withdrawn
- `account`: `&signer` - link to caller signer object
- `amount`: `u64` - amount of coins to withdraw

Fail conditions:
- `NotFound(E_USER_IS_NOT_FOUND)` - user is not registred in the storage
- `InvalidArgument(E_USER_INSUFFICIENT_BALANCE)` - user deposit is too small
- `PermissionDenied(EFROZEN)` - user coin account is frozen
  
Return: `void`

### Balance
Return current user balance

Signature:
- `<CoinType>`: `resource` - resource of coin which will be checked
- `account_addr`: `address` - address of user checked

Fail conditions: `void`
  
Return: `u64` - stored balance
