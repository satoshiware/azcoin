/* Description:
        Microcurrency Launched and distributed within Utah, a southwestern U.S. state!
*/

#ifndef BITCOIN_MICROS_MICRO_DESERETMONEY_H
#define BITCOIN_MICROS_MICRO_DESERETMONEY_H

#define MICROCURRENCY       "deseretmoney"
#define BECH32HRP           "ut"

#define BLOCKREWARD         7          // Bitcoin's Block Reward = 50. Note: to run tests, it must be 50!
#define MAXSUPPLY           3564225    // Bitcoin's Max Supply = 21000000

#define HALVINGINTERVAL     262800      // Bitcoin's Subsidy Halving Interval = 210000

#define TIMESTAMP           "BTC BLK: 000000000000000000050c443844cd8f5418afcf98d6919f8c4a3fa16422219b TXID: 5043ea3b..."
#define PUBKEYSCRIPT		"04678afdb0fe5548271967f1a67130b7105cd6a828e03909a67962e0ea1f61deb649f6bc3f4cef38c4f35504e51ec112de5c384df7ba0b8d578a4c702b6bf11d5f"
#define TIME                1690242443
#define DBITS               0x1c00ff00
#define NONCE               1960094637

#define MERKLEHASH          "0xf19430c99d84d77f07c9183c802b147ed9e183840e0df93d3d51c9948b7ed076"
#define GENESISHASH         "0x00000000006854af34b85cccb4bb867ae0095aa714fc34a9a7a9ca243897cbc2"

// Magic bytes used to identify the communications within this microcurrency community.
#define PCHMESSAGESTART0    0x81
#define PCHMESSAGESTART1    0x9e
#define PCHMESSAGESTART2    0x85
#define PCHMESSAGESTART3    0x1c

// Common to all micros
#define MAXBLOCKSIZE        100000      // Bitcoin's Max Block Size = 4000000
#define MAXSTANDARDTXWEIGHT 25000

#endif // BITCOIN_MICROS_MICRO_DESERETMONEY_H

/*
python3 genesis.py -t 1690242443 -z "BTC BLK: 000000000000000000050c443844cd8f5418afcf98d6919f8c4a3fa16422219b TXID: 5043ea3b..." -v 700000000 -b 0x1c00ff00 -n 1960094637
algorithm: SHA256
merkle hash: f19430c99d84d77f07c9183c802b147ed9e183840e0df93d3d51c9948b7ed076
pszTimestamp: BTC BLK: 000000000000000000050c443844cd8f5418afcf98d6919f8c4a3fa16422219b TXID: 5043ea3b...
pubkey: 04678afdb0fe5548271967f1a67130b7105cd6a828e03909a67962e0ea1f61deb649f6bc3f4cef38c4f35504e51ec112de5c384df7ba0b8d578a4c702b6bf11d5f
time: 1690242443 (Mon Jul 24 16:47:23 2023)
bits: 0x1c00ff00
value: 700000000

Searching for genesis hash..

Genesis Hash Found!
nonce: 1960094637
Genesis Hash: 00000000006854af34b85cccb4bb867ae0095aa714fc34a9a7a9ca243897cbc2
*/
// Proof of Existence for Deseret Money whitepaper TXID: 5043ea3bd2c2edd0865254df57a610570d3e2a63ab6a64e322ebafe4754d65c6