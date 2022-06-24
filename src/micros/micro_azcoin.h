/* Description:
		First microcurrency! Launched and distributed within Arizona, a southwestern U.S. state.
*/

#ifndef BITCOIN_MICROS_MICRO_AZCOIN_H
#define BITCOIN_MICROS_MICRO_AZCOIN_H

#define MICRONAME           "azcoin"
#define BECH32HRP           "az"

#define BLOCKREWARD         18          // Bitcoin's Block Reward = 50. Note: to run tests, it must be 50!
#define MAXSUPPLY           7560000    	// Bitcoin's Max Supply = 21000000

#define TIMESTAMP           "????????"
#define TIME                ???
#define NONCE               ???

#define MERKLEHASH          "0x????"
#define GENESISHASH         "0x????"

// Magic bytes used to identify the communications within this microcurrency community.
#define PCHMESSAGESTART0    0x??
#define PCHMESSAGESTART1    0x??
#define PCHMESSAGESTART2    0x??
#define PCHMESSAGESTART3    0x??

// Common to all micros
#define MAXBLOCKSIZE 		96000		// Bitcoin's Max Block Size = 4000000

#endif BITCOIN_MICROS_MICRO_AZCOIN_H