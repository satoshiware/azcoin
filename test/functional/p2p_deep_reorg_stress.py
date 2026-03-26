#!/usr/bin/env python3
# Copyright (c) 2026 The Bitcoin Core developers
# Distributed under the MIT software license, see the accompanying
# file COPYING or http://www.opensource.org/licenses/mit-license.php.
"""Stress deep reorg handling with a P2P-announced competing chain.

The test mines a long active chain, then announces a competing branch from a
configurable fork point. The node should request block bodies, validate the
branch, and reorg to the branch tip once cumulative work is higher.
"""

from test_framework.blocktools import create_block, create_coinbase
from test_framework.messages import msg_block, msg_headers
from test_framework.p2p import P2PInterface
from test_framework.test_framework import BitcoinTestFramework
from test_framework.util import assert_equal


class P2PDeepReorgStressTest(BitcoinTestFramework):
    def set_test_params(self):
        self.setup_clean_chain = True
        self.num_nodes = 1

    def add_options(self, parser):
        parser.add_argument(
            "--main-chain-len",
            dest="main_chain_len",
            type=int,
            default=220,
            help="Initial active chain length before announcing a competing branch",
        )
        parser.add_argument(
            "--fork-depth",
            dest="fork_depth",
            type=int,
            default=120,
            help="How deep below the tip the competing chain forks",
        )
        parser.add_argument(
            "--fork-extension",
            dest="fork_extension",
            type=int,
            default=140,
            help="Number of blocks in competing branch from the fork point",
        )

    def build_chain(self, nblocks, prev_hash, prev_height, prev_median_time):
        blocks = []
        for _ in range(nblocks):
            coinbase = create_coinbase(prev_height + 1)
            block_time = prev_median_time + 1
            block = create_block(int(prev_hash, 16), coinbase, block_time)
            block.solve()

            blocks.append(block)
            prev_hash = block.hash
            prev_height += 1
            prev_median_time = block_time
        return blocks

    def run_test(self):
        node = self.nodes[0]
        peer = node.add_p2p_connection(P2PInterface())

        main_chain_len = self.options.main_chain_len
        fork_depth = self.options.fork_depth
        fork_extension = self.options.fork_extension

        assert main_chain_len > 2
        assert 1 <= fork_depth < main_chain_len
        assert fork_extension > fork_depth

        self.log.info(f"Mining active chain of {main_chain_len} blocks")
        addr = node.get_deterministic_priv_key().address
        active_chain_hashes = self.generatetoaddress(node, main_chain_len, addr)
        old_tip_hash = active_chain_hashes[-1]
        old_tip_height = node.getblockcount()
        assert_equal(old_tip_height, main_chain_len)

        fork_point_height = main_chain_len - fork_depth
        fork_point_hash = active_chain_hashes[fork_point_height - 1]
        fork_point_mtp = node.getblockheader(fork_point_hash)["mediantime"] + 1

        self.log.info(
            f"Building competing chain from height {fork_point_height} with {fork_extension} blocks"
        )
        competing_blocks = self.build_chain(
            nblocks=fork_extension,
            prev_hash=fork_point_hash,
            prev_height=fork_point_height,
            prev_median_time=fork_point_mtp,
        )

        self.log.info("Announcing competing chain headers")
        peer.send_message(msg_headers(competing_blocks))

        self.log.info("Waiting for node to request announced block bodies")
        peer.wait_until(lambda: "getdata" in peer.last_message, timeout=10)

        self.log.info("Serving competing chain full blocks")
        for block in competing_blocks:
            peer.send_message(msg_block(block))
        peer.sync_with_ping()

        expected_new_height = fork_point_height + fork_extension
        self.log.info(
            f"Asserting reorg to competing chain tip at height {expected_new_height}"
        )
        assert_equal(node.getblockcount(), expected_new_height)
        assert_equal(node.getbestblockhash(), competing_blocks[-1].hash)
        assert_equal(node.getblock(old_tip_hash)["confirmations"], -1)


if __name__ == '__main__':
    P2PDeepReorgStressTest().main()
