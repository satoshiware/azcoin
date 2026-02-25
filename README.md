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
| Max Block Size             | 25 KB base (100 KB possible)   |
| Divisibility               | 8 decimal places               |

## Genesis & Evolution
- Launched February 14, 2023 as "AZ Money" (tied to Arizona statehood anniversary).
- Originally planned as Arizona's microcurrency with a 5-year hard fork to lock supply.
- Repurposed to **AZCoin** — now global and untethered from any single region ("AZ" = A-to-Z universal scope).
- Proof-of-Existence: Original AZ Money whitepaper embedded in Bitcoin blockchain (TXID: `b5f53d6462f748de3bf17ef479b2855d1af67c90045f6ab6187062fb724f9c17`, block 776679, Feb 15, 2023).

---

AZCoin is experimental software. Participate at your own risk. It aims to catalyze honest, decentralized banking and sound local monies worldwide — accelerating Bitcoin adoption while preventing power consolidation.

## Compile & Release Checklist
1. **Merge changes** into master branch
2. **Update assumevalid** (critical for faster initial block download/sync; do this for **every release**):
    - Select a **buried** block that is safely in the past
    - Get the block hash: `azcoin-cli getblockhash <height>`
    - In `/src/kernel/chainparams.cpp`, update the line:
      ```cpp
      consensus.defaultAssumeValid = uint256S("0x<your-chosen-safe-block-hash-here>");
3. **Update version number:** Edit configure.ac (update the AC_INIT version argument)
4. **Build binaries:** Use cross-compile.sh utility for builds (linux [x64/arm64] and windows 64)
5. **Tag & release**
6. **Upload assets:**
    - All compiled binaries
    - SHA256SUMS file (generate via sha256sum *.tar.gz *.zip > SHA256SUMS)


