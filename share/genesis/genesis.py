import hashlib
import struct
import sys
import time

from optparse import OptionParser


def main():
    options = get_args()

    input_script = create_input_script(options.timestamp)
    output_script = create_output_script(options.pubkey)
    tx = create_transaction(input_script, output_script, options)

    hash_merkle_root = hashlib.sha256(hashlib.sha256(tx).digest()).digest()
    print_block_info(options, hash_merkle_root)

    block_header = create_block_header(hash_merkle_root, options.time, options.bits, options.nonce)
    genesis_hash, nonce = generate_hash(block_header, options.nonce, options.bits)
    while (announce_found_genesis(genesis_hash, nonce)):
        options.time += options.interval
        options.nonce = 0
        print_block_info(options, hash_merkle_root)
        block_header = create_block_header(hash_merkle_root, options.time, options.bits, options.nonce)
        genesis_hash, nonce = generate_hash(block_header, options.nonce, options.bits)


def get_args():
    parser = OptionParser()
    parser.add_option("-i", "--interval", dest="interval", default=1, type="int", help="amount (seconds) added to time when the nonce rolls over")
    parser.add_option("-t", "--time", dest="time", default=int(time.time()), type="int", help="the (unix) time when the genesisblock is created")
    parser.add_option("-z", "--timestamp", dest="timestamp", default="The Times 03/Jan/2009 Chancellor on brink of second bailout for banks", type="string", help="the pszTimestamp found in the coinbase of the genesisblock")
    parser.add_option("-n", "--nonce", dest="nonce", default=0, type="int", help="the first value of the nonce that will be incremented when searching the genesis hash")
    parser.add_option("-p", "--pubkey", dest="pubkey", default="04678afdb0fe5548271967f1a67130b7105cd6a828e03909a67962e0ea1f61deb649f6bc3f4cef38c4f35504e51ec112de5c384df7ba0b8d578a4c702b6bf11d5f", type="string", help="the pubkey found in the output script")
    parser.add_option("-v", "--value", dest="value", default=5000000000, type="int", help="the value in coins for the output, full value (exp. in bitcoin 5000000000 - To get other coins value: Block Value * 100000000)")
    parser.add_option("-b", "--bits", dest="bits", default=0x1d00ffff, type="int", help="the target in compact representation, associated to a difficulty of 1")

    (options, args) = parser.parse_args()
    return options


def create_input_script(psz_timestamp):
    if len(psz_timestamp) > 91:
        sys.exit('error: timestamp has ' + str(len(psz_timestamp)) + ' characters! It must be 91 characters or less.')
    
    if len(psz_timestamp) < 16:
        sys.exit('error: timestamp has ' + str(len(psz_timestamp)) + ' characters! It must have 16 characters or more.')

    psz_prefix = ""
    if len(psz_timestamp) > 75:  # Use OP_PUSHDATA1 if required
        psz_prefix = '4c'

    return bytes.fromhex('04ffff001d0104' + psz_prefix + hex(len(psz_timestamp))[2:] + psz_timestamp.encode('utf-8').hex())


def create_output_script(pubkey):
    script_len = '41'
    OP_CHECKSIG = 'ac'
    return bytes.fromhex(script_len + pubkey + OP_CHECKSIG)


def create_transaction(input_script, output_script, options):
    return struct.pack(
        '4s 1s 32s 4s 1s ' + str(len(input_script)) + 's 4s 1s 8s 1s 67s 4s',   # format
        struct.pack('I', 1),                                                    # version                   bytes[4]
        b'\x01',                                                                # number of inputs          bytes[1]
        struct.pack('qqqq', 0, 0, 0, 0),                                        # previous output           bytes[32]
        struct.pack('I', 0xFFFFFFFF),                                           # previous output idx       bytes[4]
        len(input_script).to_bytes(1, "little"),                                # input script length       bytes[1]
        input_script,                                                           # input script              bytes[input_script_length]
        struct.pack('I', 0xFFFFFFFF),                                           # sequence                  bytes[4]
        b'\x01',                                                                # number of outputs         bytes[1]
        struct.pack('q', options.value),                                        # output value              bytes[8]
        b'\x43',                                                                # output script length      bytes[1]
        output_script,                                                          # output_script             bytes[output_script_length]
        struct.pack('I', 0))                                                    # lock time                 bytes[4]


def create_block_header(hash_merkle_root, generation_time, bits, nonce):
    return struct.pack(
        '4s 32s 32s 4s 4s 4s',                                                  # format
        struct.pack('I', 1),                                                    # version                   bytes[4]
        struct.pack('qqqq', 0, 0, 0, 0),                                        # hash of previous block    bytes[32]
        hash_merkle_root,                                                       # hash of merkle root       bytes[32]
        struct.pack('I', generation_time),                                      # time                      bytes[4]
        struct.pack('I', bits),                                                 # bits                      bytes[4]
        struct.pack('I', nonce))                                                # nonce                     bytes[4]


def generate_hash(data_block, start_nonce, bits):
    print("\nSearching for genesis hash..")
    nonce = start_nonce
    last_updated = time.time()
    target = (bits & 0xffffff) * 2 ** (8 * ((bits >> 24) - 3))  # https://en.bitcoin.it/wiki/Difficulty
    while True:
        block_hash = generate_hashes_from_block(data_block)
        last_updated = calculate_hashrate(nonce, last_updated, target)
        if is_genesis_hash(block_hash, target):
            return block_hash, nonce
        else:
            nonce = nonce + 1
            if nonce > 0xffffffff:
                return b'\x00', 0
            data_block = data_block[0:len(data_block) - 4] + struct.pack('<I', nonce)


def generate_hashes_from_block(data_block):
    return hashlib.sha256(hashlib.sha256(data_block).digest()).digest()[::-1]


def is_genesis_hash(golden_hash, target):
    return int.from_bytes(golden_hash, 'big') < target


def calculate_hashrate(nonce, last_updated, target):
    if nonce % 1000000 == 999999:
        now = time.time()
        hashrate = round(1000000 / (now - last_updated))
        generation_time = round(((0xffff << 208) / target) * 2**32 / hashrate / 3600, 1)
        sys.stdout.write("\r%s hash/s, estimate: %s h, nonce: %s (max = 4294967295)        " %(str(hashrate), str(generation_time), nonce))
        sys.stdout.flush()
        return now
    else:
        return last_updated


def print_block_info(options, hash_merkle_root):
    print("\nalgorithm: SHA256")
    print("merkle hash: " + hash_merkle_root[::-1].hex())
    print("pszTimestamp: " + options.timestamp)
    print("pubkey: " + options.pubkey)
    print("time: " + str(options.time) + " (" + time.ctime(options.time) + ")")
    print("bits: " + str(hex(options.bits)))
    print("value: " + str(options.value))


def announce_found_genesis(genesis_hash, nonce):
    if len(genesis_hash) != 1:
        print("\nGenesis Hash Found!")
        print("nonce: " + str(nonce))
        print("Genesis Hash: " + genesis_hash.hex())
        return False
    else:
        print("\nGenesis Hash NOT Found! Sorry.")
        return True


main()
