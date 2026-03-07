from optparse import OptionParser

MAX_BITS = 0x1d00ffff

def main():
    options = get_args()
	
    # Calculations
    difficulty = options.hashrate / (2**32 / options.time)
    target = difficulty_to_target(difficulty)
    bits = target_to_bits(target)
    target = bits_to_target(bits)
    difficulty = target_to_difficulty(target)
    hashrate = difficulty * 2**32 / options.time

    # Print Results
    print("\ntime: " + str(options.time) + " seconds (time between blocks)")
    print("bits: " + hex_32bit(bits))
    print("target: " + hex_256bit(target))
    print("difficulty: " + str(difficulty))
    print("hashrate: " + str(options.hashrate / 1000000000) + " Gh/s\n")
    
def get_args():
    parser = OptionParser()
    parser.add_option("-t", "--time", dest="time", default=600, type="int", help="time between blocks (seconds)")
    parser.add_option("-r", "--hashrate", dest="hashrate", default=(2**32)/600, type="int", help="starting hashrate (h/s)")

    (options, args) = parser.parse_args()
    return options


def bits_to_target(bits):
    hexstr = format(bits, 'x') # Convert integer to hex
    first_byte, last_bytes = hexstr[0:2], hexstr[2:]
    first, last = int(first_byte, 16), int(last_bytes, 16) # convert bytes back to int
    return last * 256 ** (first - 3)

    
def target_to_difficulty(target):
    return bits_to_target(MAX_BITS) / target


def difficulty_to_target(difficulty):
    return int(bits_to_target(MAX_BITS) / difficulty)

    
def target_to_bits(target):
    if target == 0:
        return 0
    target = min(target, bits_to_target(MAX_BITS))
    size = int((target.bit_length() + 7) / 8)
    mask64 = 0xffffffffffffffff
    if size <= 3:
        compact = (target & mask64) << (8 * (3 - size))
    else:
        compact = (target >> (8 * (size - 3))) & mask64

    if compact & 0x00800000:
        compact >>= 8
        size += 1
    assert compact == (compact & 0x007fffff)
    assert size < 256
    return compact | size << 24


def hex_256bit(num):
    return "0x" + hex(int(num))[2:].zfill(64)

def hex_32bit(num):
    return "0x" + hex(int(num))[2:].zfill(8)
    
main()