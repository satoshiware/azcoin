# AZCoin Core

AZCoin Core is a full node implementation forked from Bitcoin Core v23.0 (commit `fcf6c8f4eb217763545ede1766831a6b93f583bd`). It powers **AZCoin**, a global, free-floating digital asset traded exclusively against satoshis (SATS). AZCoin serves as an **incentive engine** to accelerate the worldwide build-out of interconnected, independent Bitcoin banking infrastructure. AZCoin is not permanent. Once a geopolitical region develops sufficient independent banking infrastructure, AZCoin in that subnetwork is replaced value-for-value by a native microcurrency (via a clean, transparent transition detailed in the respective microcurrency's whitepaper).

## Specifications

| Parameter                  | Value                          |
|----------------------------|--------------------------------|
| Initial Block Reward       | 15 azcoins                     |
| Block Target Spacing       | 120 seconds (2 minutes)        |
| Subsidy Halving Interval   | 262,800 blocks                 |
| Number of Halvings         | 31                             |
| Max Supply                 | ~7,884,000 azcoins             |
| Difficulty Adjustment      | Every 2 days (172,800 seconds) |
| Max Block Size             | 25 KB units (100 KB bytes)     |
| Divisibility               | 8 decimal places               |
| Bech32 HRP (address prefix)| `az`                           |
| Proposed Ticker            | `AZC`                          |
| RPC Port                   | 19332                          |
| P2P Port                   | 19333                          |
| zmqpubrawblock             | 29332                          |
| zmqpubrawtx                | 29333                          |
| zmqpubhashblock            | 29334                          |
| zmqpubhashtx               | 29335                          |
| zmqpubsequence             | 29336                          |
| Network Magic bytes        | `0x81 0x9e 0x85 0x1c`          |

## Genesis & Evolution
- Launched February 14, 2023 as "AZ Money" (tied to Arizona statehood anniversary).
- Originally planned as Arizona's microcurrency with a 5-year hard fork to lock supply.
- Repurposed to **AZCoin** — now global and untethered from any single region ("AZ" = A-to-Z universal scope).
- Proof-of-Existence: Original AZ Money whitepaper embedded in Bitcoin blockchain (TXID: `b5f53d6462f748de3bf17ef479b2855d1af67c90045f6ab6187062fb724f9c17`, block 776679, Feb 15, 2023).

## Genesis Block Details
- **Timestamp** (embedded message):  
  `"BTC BLK: 0000000000000000000021bb823d8518bfa49c6f16bce1545c4977eb829238a9 TXID: b5f53d64..."`
- **Coinbase Pubkey Script** (unspendable):  
  `04678afdb0fe5548271967f1a67130b7105cd6a828e03909a67962e0ea1f6`<br>`1deb649f6bc3f4cef38c4f35504e51ec112de5c384df7ba0b8d578a4c702b6bf11d5f`
- **Genesis Time** (Unix timestamp): 1676412978 (Tue Feb 14 15:16:18 2023 UTC)
- **nBits** (difficulty target): `0x1d00ffff`
- **Nonce** (found via search): 1429287480
- **Merkle Root**: `b9ed7f5a0f23a5063818064eb28979ca1a22fdbc38fbeb3726f759d83e82a69a`
- **Genesis Block Hash**:  
  `00000000b00ff40d0f986a2314bbacbc003743b4b7062c6221b08256edc1ae94`

Values above were found/generated using the /share/genesis script with the following parameters:<br>
`python3 genesis.py -t 1676412978`<br>`-z "BTC BLK: 0000000000000000000021bb823d8518bfa49c6f16bce1545c4977eb829238a9 TXID: b5f53d64..."`<br>`-v 1500000000`

---

AZCoin is experimental software. Participate at your own risk. It aims to catalyze honest, decentralized banking and sound local monies worldwide — accelerating Bitcoin adoption while preventing power consolidation.

## Compile & Release Checklist
### 1. Merge changes into `master`
* Ensure all intended changes are merged.
* Verify the repository builds cleanly from the current `master` tip.

### 2. Update chain parameters
*These values do **not need to be updated every release**, but should be refreshed periodically (e.g., every 3–6 months).*

Update the parameters in: `src/chainparams.cpp`
Look for the section marked: // !!! UPDATE HERE !!!
Follow the commands in the comments in that section to update:
    consensus.nMinimumChainWork
    consensus.defaultAssumeValid
    m_assumed_blockchain_size
    m_assumed_chain_state_size
    Important: If you make any changes in this section, also update the LAST UPDATE comment with the current date. Commit the updated values if changes were made.

### 3. Update version number
Update the version defines at the top of configure.ac for the new release:
	define(_CLIENT_VERSION_MAJOR, 0)
	define(_CLIENT_VERSION_MINOR, 2)
	define(_CLIENT_VERSION_BUILD, 1)
	define(_CLIENT_VERSION_RC, 0)
	define(_CLIENT_VERSION_IS_RELEASE, true)
    _CLIENT_VERSION_RC: 0 for final releases, greater than 0 for release candidates.
    _CLIENT_VERSION_IS_RELEASE: true for official releases, false for release candidates.

### 4. Update CHANGELOG.md
    Open CHANGELOG.md in the root directory.
    Move all items from the [Unreleased] section into a new section for the version you just defined (e.g., [0.2.1] - 2026-03-07).
    Ensure all major bug fixes, new features, and breaking changes are clearly listed for users.

### 5. Build binaries
On a fresh Debian system (or Debian under WSL):
    Prepare script: Copy the cross-compile.sh script to the machine.
    Permissions: Give it executable permission:
    chmod +x cross-compile.sh
    Execute: Run the script as root or with sudo:
    sudo ./cross-compile.sh

The script will build all release binaries for the supported platforms. Verify that the builds complete successfully.

### 6. Tag & Release on GitHub
Once the binaries are built and verified, create the release on GitHub:
    Create Release: Go to the Releases page of your repository and click Create a new release.
    Tagging: Enter the version number as the tag (e.g., v0.2.1) and use the same version for the release name (e.g., Azcoin v0.2.1).
    Description: In the description field, summarize the changes or highlights (you can copy these directly from your updated CHANGELOG.md).
    Upload Assets:
        Drag and drop all compiled binaries.
        Include the SHA256SUMS file (Generate via: sha256sum *.tar.gz *.zip > SHA256SUMS).
    Publish: Click Publish release to finalize the tag and attach the files.