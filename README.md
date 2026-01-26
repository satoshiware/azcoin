AZCoin Core (Microcurrency Edition)
===================================

AZCoin Core is a Bitcoin Core–derived full node implementation, forked from Bitcoin Core v23.0
(commit `fcf6c8f4eb217763545ede1766831a6b93f583bd`).

This codebase has been modified to support the initial distribution of **microcurrencies**
leading up to their respective hard forks. After the coins are distributed, the
new blockchain can be hard forked so that only standard (non-scripted) bech32 UTXOs
are honored. Bech32 addresses start with a code unique to each microcurrency.

Links
-----

- Satoshiware: https://www.satoshiware.org
- GitHub (Satoshiware org): https://github.com/satoshiware/

Development Philosophy
----------------------

AZCoin Core follows a Bitcoin Core–style engineering philosophy: changes should be
implemented with the same rigor expected for upstream Bitcoin Core, while still
achieving AZCoin-specific functionality and network requirements.

Upstream Project: Bitcoin Core
------------------------------

Bitcoin Core is the upstream project AZCoin Core is derived from.

- Website: https://bitcoincore.org
- Source: https://github.com/bitcoin/bitcoin
- Documentation (mirrored/adapted): see the [`doc/`](./doc) directory in this repo.

What is AZCoin?
---------------

AZCoin is an experimental digital currency and network based on Bitcoin Core’s design.
It uses peer-to-peer networking to validate and relay transactions and blocks without
a central authority. AZCoin Core is the open source software that enables participation
in the AZCoin network (running a full node, validating consensus rules, and providing RPC
interfaces for wallets/services).

> NOTE: This repository contains protocol and consensus changes specific to AZCoin and
> its microcurrency distribution/fork workflow, and therefore is not compatible with
> Bitcoin mainnet.

License
-------

AZCoin Core is released under the terms of the MIT license. See [COPYING](COPYING) for more
information or see https://opensource.org/licenses/MIT.

Credits and Attribution
-----------------------

AZCoin Core is a fork of Bitcoin Core and includes work from the Bitcoin Core developers and
contributors. Where applicable, original copyright notices are retained.

Development Process
-------------------

The default branch is regularly built and tested, but it is not guaranteed to be completely stable.
Release tags are created from release branches to indicate stable releases of AZCoin Core.

The contribution workflow is described in [CONTRIBUTING.md](CONTRIBUTING.md), and useful hints
for developers can be found in [doc/developer-notes.md](doc/developer-notes.md).

Testing
-------

Testing and code review are the bottleneck for development; we get more changes than we can
review and test on short notice. Please be patient and help out by testing other people's
pull requests—this is security-critical software where mistakes can cost real money.

### Automated Testing

Developers are strongly encouraged to write [unit tests](src/test/README.md) for new code, and to
submit new unit tests for old code. Unit tests can be compiled and run
(assuming they weren't disabled in configure) with: `make check`.

Further details on running and extending unit tests can be found in
[/src/test/README.md](/src/test/README.md).

There are also [regression and integration tests](/test), written in Python.
These tests can be run (if the [test dependencies](/test) are installed) with:
`test/functional/test_runner.py`

### Manual Quality Assurance (QA) Testing

Changes should be tested by somebody other than the developer who wrote the code.
This is especially important for large or high-risk changes. It is useful to add a
test plan to the pull request description if testing the changes is not straightforward.

Translations
------------

This repository follows a Bitcoin Core–style translation workflow. See the
[translation process](doc/translation_process.md) for details.
