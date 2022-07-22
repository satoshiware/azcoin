/* Description:
		First microcurrency for experimentation! It's useless beyond research and development,
		yet great for testing new "micro" code.
*/

#ifndef BITCOIN_MICROS_MICRO_TESTN_H
#define BITCOIN_MICROS_MICRO_TESTN_H

#define MICROCURRENCY       "testn"
#define BECH32HRP           "tstn"

#define BLOCKREWARD         32          // Bitcoin's Block Reward = 50. Note: to run tests, it must be 50!
#define MAXSUPPLY           13440000    // Bitcoin's Max Supply = 21000000

#define TIMESTAMP           "AZ Republic Jun/17/2022 Diamondbacks use long ball, small ball to thmp Twins in series open"
#define TIME                1655529249
#define NONCE               2444673783

#define MERKLEHASH          "0x0ead7f4713c1dd6a0ac5a824ef8c1282b003fe2e1d1b8a3ffd33296cd6a5983c"
#define GENESISHASH         "0x0000000056c6bab86aa8ec21a78667e5b830165b7cb48970790acc0e5681271b"

// Magic bytes used to identify the communications within this microcurrency community.
#define PCHMESSAGESTART0    0x81
#define PCHMESSAGESTART1    0x9e
#define PCHMESSAGESTART2    0x85
#define PCHMESSAGESTART3    0x1c

// Common to all micros
#define MAXBLOCKSIZE		96000		// Bitcoin's Max Block Size = 4000000

#endif // BITCOIN_MICROS_MICRO_TESTN_H
