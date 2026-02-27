# Genesis
Python 3 script for creating the parameters required for a unique SHA256 microcurrency genesis block.

Forked from lhartikk/GenesisH0 @ dcbe9b9

### Options
    Usage: genesis.py [options]
    
    Options:
      -h, --help            show this help message and exit
      -t TIME, --time=TIME  the (unix) time when the genesisblock is created
      -z TIMESTAMP, --timestamp=TIMESTAMP
                            the pszTimestamp found in the coinbase of the
                            genesisblock
      -n NONCE, --nonce=NONCE
                            the first value of the nonce that will be incremented
                            when searching the genesis hash
      -p PUBKEY, --pubkey=PUBKEY
                            the pubkey found in the output script
      -v VALUE, --value=VALUE
                            the value in coins for the output, full value (exp. in
                            bitcoin 5000000000 - To get other coins value: Block
                            Value * 100000000)
      -b BITS, --bits=BITS
                            the target in compact representation, associated to a
                            difficulty of 1


### Defaults
    -t (time)       = int(time.time())
    -z (timestamp)  = "The Times 03/Jan/2009 Chancellor on brink of second bailout for banks"
    -n (nonce)      = 0
    -p (pubkey)     = "04678afdb0fe5548271967f1a67130b7105cd6a828e03909a67962e0ea1f61deb649f6bc3f4cef38c4f35504e51ec112de5c384df7ba0b8d578a4c702b6bf11d5f"
    -v (value)      = 5000000000 (50 * 100000000 = BLOCKREWARD * COIN)
    -b (bits)       = 0x1d00ffff


### Examples
Create the original genesis hash found in Bitcoin
    
    python genesis.py -t 1231006505 -n 2083236893
    
    output: 
        algorithm: SHA256
        merkle hash: 4a5e1e4baab89f3a32518a88c31bc87f618f76673e2cc77ab2127b7afdeda33b
        pszTimestamp: The Times 03/Jan/2009 Chancellor on brink of second bailout for banks
        pubkey: 04678afdb0fe5548271967f1a67130b7105cd6a828e03909a67962e0ea1f61deb649f6bc3f4cef38c4f35504e51ec112de5c384df7ba0b8d578a4c702b6bf11d5f
        time: 1231006505
        bits: 0x1d00ffff
        value: 5000000000
        nonce: 2083236893
        Genesis Hash: 000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f

Create a new microcurrency genesis hash (e.g. Arizona)
    
    python genesis.py -z "AZ Republic Jun/17/2022 Diamondbacks use long ball, small ball to thmp Twins in series open" -t 1655529249 -n 2444673783 -v 3200000000
    
    output:
        algorithm: SHA256
        merkle hash: 0ead7f4713c1dd6a0ac5a824ef8c1282b003fe2e1d1b8a3ffd33296cd6a5983c
        pszTimestamp: AZ Republic Jun/17/2022 Diamondbacks use long ball, small ball to thmp Twins in series open
        pubkey: 04678afdb0fe5548271967f1a67130b7105cd6a828e03909a67962e0ea1f61deb649f6bc3f4cef38c4f35504e51ec112de5c384df7ba0b8d578a4c702b6bf11d5f
        time: 1655529249
        bits: 0x1d00ffff
        value: 3200000000
        nonce: 2444673783
        Genesis Hash: 0000000056c6bab86aa8ec21a78667e5b830165b7cb48970790acc0e5681271b


### Running on Debian 11+
Recommended to run multiple instances simultaneously to find a new genesis faster<br>
Use the "run.sh" script (included in this repository) for managing large quantity of instances
    
    sudo apt-get -y update
    sudo apt-get -y upgrade
    sudo apt-get -y install git-core python3
    git clone https://github.com/satoshiware/genesis
    cd ~/genesis
    python3 genesis.py -z "Local newspaper of the day TODAY'S DATE Something interesting that happened"
