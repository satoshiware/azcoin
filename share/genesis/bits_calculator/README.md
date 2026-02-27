# Bits Calculator
Python 3 script for calculating the bits (compact form) for the desired difficulty (or hashrate) of a genesis block.

### Options
    Usage: bits_calculator.py [options]
    
    Options:
      -h, --help            show this help message and exit
      -t TIME, --time=TIME  time between blocks (seconds)
      -r HASHRATE, --hashrate=HASHRATE
                            starting hashrate (h/s)

### Defaults
    -t (time)       = 600 seconds
    -r (hashrate)   = (2**32)/600

### Examples
Find the difficulty bits for Deseret Money's genesis block with a hashrate of 9.1983 Gh/s
    
    python bits_calculator.py -t 120 -r $((9.1983 * 1000000000) # linux bash command
    
    output: 
        time: 120 seconds (time between blocks)
        bits: 0x1c00ff00
        target: 0x0000000000ff0000000000000000000000000000000000000000000000000000
        difficulty: 257.0
        hashrate: 9.1983 Gh/s
