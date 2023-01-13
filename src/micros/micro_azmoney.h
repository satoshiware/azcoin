/* Description:
		First microcurrency! Launched and distributed within Arizona, a southwestern U.S. state.
*/

#ifndef BITCOIN_MICROS_MICRO_AZMONEY_H
#define BITCOIN_MICROS_MICRO_AZMONEY_H

#define MICROCURRENCY       "azmoney"
#define BECH32HRP           "az"

#define BLOCKREWARD         15          // Bitcoin's Block Reward = 50. Note: to run tests, it must be 50!
#define MAXSUPPLY           7637625    	// Bitcoin's Max Supply = 21000000

#define HALVINGINTERVAL		262800      // Bitcoin's Subsidy Halving Interval = 210000

#define TIMESTAMP           "testing........."
#define TIME                1673649471
#define NONCE               1444837278

#define MERKLEHASH          "0x2def380691bdd8102e4eadbe83ad64f8fae3b316499dc1d59e2f76b9dbb9c739"
#define GENESISHASH         "0x00000000b3a5be80d866af31dc487df43680426c73777a4d8d0525c5e74974ee"

// Magic bytes used to identify the communications within this microcurrency community.
#define PCHMESSAGESTART0    0x81
#define PCHMESSAGESTART1    0x9e
#define PCHMESSAGESTART2    0x85
#define PCHMESSAGESTART3    0x1c

// Common to all micros
#define MAXBLOCKSIZE 		100000		// Bitcoin's Max Block Size = 4000000

#endif // BITCOIN_MICROS_MICRO_AZCOIN_H


/*
algorithm: SHA256
merkle hash: 2def380691bdd8102e4eadbe83ad64f8fae3b316499dc1d59e2f76b9dbb9c739
pszTimestamp: testing.........
pubkey: 04678afdb0fe5548271967f1a67130b7105cd6a828e03909a67962e0ea1f61deb649f6bc3f4cef38c4f35504e51ec112de5c384df7ba0b8d578a4c702b6bf11d5f
time: 1673649471 (Fri Jan 13 15:37:51 2023)
bits: 0x1d00ffff
value: 1500000000
Searching for genesis hash..
422893 hash/s, estimate: 2.8 h, nonce: 1443999999 (max = 4294967295)
Genesis Hash Found!
nonce: 1444837278
Genesis Hash: 00000000b3a5be80d866af31dc487df43680426c73777a4d8d0525c5e74974ee
*/