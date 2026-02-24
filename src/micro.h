/* Description:
		First microcurrency! Launched and distributed within U.S.A. !
*/

#ifndef BITCOIN_MICROS_MICRO_AZCOIN_H
#define BITCOIN_MICROS_MICRO_AZCOIN_H

#define MICROCURRENCY       "azcoin"
#define BECH32HRP           "az"

#define BLOCKREWARD         15          // Bitcoin's Block Reward = 50. Note: to run tests, it must be 50!
#define MAXSUPPLY           7884000    	// Bitcoin's Max Supply = 21000000

#define HALVINGINTERVAL		262800      // Bitcoin's Subsidy Halving Interval = 210000

#define TIMESTAMP           "BTC BLK: 0000000000000000000021bb823d8518bfa49c6f16bce1545c4977eb829238a9 TXID: b5f53d64..."
#define PUBKEYSCRIPT		"04678afdb0fe5548271967f1a67130b7105cd6a828e03909a67962e0ea1f61deb649f6bc3f4cef38c4f35504e51ec112de5c384df7ba0b8d578a4c702b6bf11d5f"
#define TIME                1676412978
#define DBITS               0x1d00ffff
#define NONCE               1429287480

#define MERKLEHASH          "0xb9ed7f5a0f23a5063818064eb28979ca1a22fdbc38fbeb3726f759d83e82a69a"
#define GENESISHASH         "0x00000000b00ff40d0f986a2314bbacbc003743b4b7062c6221b08256edc1ae94"

// Magic bytes used to identify the communications within this microcurrency community.
#define PCHMESSAGESTART0    0x81
#define PCHMESSAGESTART1    0x9e
#define PCHMESSAGESTART2    0x85
#define PCHMESSAGESTART3    0x1c

// Common to all micros
#define MAXBLOCKSIZE 		100000		// Bitcoin's Max Block Size = 4000000
#define MAXSTANDARDTXWEIGHT 25000

#endif // BITCOIN_MICROS_MICRO_AZCOIN_H

/*
python3 genesis.py -t 1676412978 -z "BTC BLK: 0000000000000000000021bb823d8518bfa49c6f16bce1545c4977eb829238a9 TXID: b5f53d64..." -v 1500000000
algorithm: SHA256
merkle hash: b9ed7f5a0f23a5063818064eb28979ca1a22fdbc38fbeb3726f759d83e82a69a
pszTimestamp: BTC BLK: 0000000000000000000021bb823d8518bfa49c6f16bce1545c4977eb829238a9 TXID: b5f53d64...
pubkey: 04678afdb0fe5548271967f1a67130b7105cd6a828e03909a67962e0ea1f61deb649f6bc3f4cef38c4f35504e51ec112de5c384df7ba0b8d578a4c702b6bf11d5f
time: 1676412978 (Tue Feb 14 15:16:18 2023)
bits: 0x1d00ffff
value: 1500000000
Searching for genesis hash..
1105063 hash/s, estimate: 1.1 h, nonce: 1428999999 (max = 4294967295)
Genesis Hash Found!
nonce: 1429287480
Genesis Hash: 00000000b00ff40d0f986a2314bbacbc003743b4b7062c6221b08256edc1ae94
*/
// Proof of Existence for AZ Money whitepaper TXID: b5f53d6462f748de3bf17ef479b2855d1af67c90045f6ab6187062fb724f9c17
