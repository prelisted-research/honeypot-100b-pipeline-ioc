#!/usr/bin/env python3
"""detect_pipeline.py — flag contracts belonging to the honeypot pipeline documented
in this IOC package.

The pipeline uses a small forked honeypot template. Every pipeline contract carries
one of two known hardcoded manager addresses as a PUSH20 constant in its runtime
bytecode, plus a specific triad of custom function selectors (`proof(uint256)`,
`Execute(address)`, `Approved(address)`). Presence of a manager constant is the
strongest single signal; presence of the selector triad is a supporting fingerprint
that catches variants where the operator has substituted a different manager address.

Zero external dependencies (standard library only). Any EVM-compatible RPC endpoint
works — the tool never requires an API key.

Usage (CLI):

    python3 detect_pipeline.py --rpc https://<your-rpc-endpoint> \\
                               --address 0x...

    python3 detect_pipeline.py --rpc https://<your-rpc-endpoint> \\
                               --address-file addresses.txt

Usage (library):

    from detect_pipeline import check_contract
    result = check_contract('https://<your-rpc>', '0x...')
    # -> {'is_pipeline': True, 'manager_matched': 'avalanche_key_1',
    #     'selector_triad_present': True, 'runtime_size_bytes': 8428}
"""
import argparse
import json
import sys
import urllib.request
import urllib.error


# Known hardcoded manager addresses (lowercase hex, no `0x` prefix)
# These are baked directly into the runtime bytecode of every pipeline contract
# using PUSH20. Any contract containing either as a bytecode constant is very
# likely part of the pipeline.
KNOWN_MANAGERS = {
    'ce54c175880ff4edaa5d80b2dc66dda0e34a36ac': 'avalanche_key_1',
    '6b8942200b01b140db3c9053d74216fe3b710f9e': 'avalanche_key_2_and_drain_executor',
    'bfd4a51c9f4c5b8109bdd462c8a57a5d268be3d0': 'polygon_key',
}

# Function selectors that identify the honeypot template. All three are custom
# (not part of the ERC-20 standard) and their PRESENCE together is a strong
# template-fingerprint. `proof(uint256)` is the unlimited mint gate,
# `Execute(address)` is the blacklist function, `Approved(address)` is the
# un-blacklist escape valve.
KIT_SELECTORS = {
    '16e3b09c': 'proof(uint256)',
    'f3294c13': 'Execute(address)',
    '5d91bd0c': 'Approved(address)',
}

# Expected runtime bytecode size for the known-canonical template (bytes).
# Not a hard match — the operator may vary this in future forks — but a size
# close to this alongside the selector triad strongly indicates a kit fork.
CANONICAL_RUNTIME_SIZE = 8428  # +/- a few bytes


def rpc_call(rpc_url, method, params, timeout=30):
    payload = json.dumps({'jsonrpc': '2.0', 'id': 1, 'method': method, 'params': params}).encode()
    req = urllib.request.Request(
        rpc_url, data=payload,
        headers={'Content-Type': 'application/json'}
    )
    with urllib.request.urlopen(req, timeout=timeout) as resp:
        return json.loads(resp.read()).get('result', '')


def check_contract(rpc_url, contract_address):
    """Fetch contract runtime bytecode and check pipeline fingerprints.

    Returns a dict with:
      is_pipeline: bool (True if either a known manager OR the selector triad matches)
      manager_matched: str or None (which known manager, if any)
      selector_triad_present: bool
      runtime_size_bytes: int
      contract_address: str
    """
    code = rpc_call(rpc_url, 'eth_getCode', [contract_address, 'latest'])
    if not code or code == '0x':
        return {
            'contract_address': contract_address,
            'is_pipeline': False,
            'manager_matched': None,
            'selector_triad_present': False,
            'runtime_size_bytes': 0,
            'note': 'no bytecode at this address (EOA or non-existent)',
        }

    code_hex = code.lower().lstrip('0x')
    runtime_size = len(code_hex) // 2

    # Check for any known manager as a PUSH20 constant (0x73 opcode + 20-byte addr)
    manager_matched = None
    for mgr_hex, label in KNOWN_MANAGERS.items():
        if mgr_hex in code_hex:
            manager_matched = label
            break

    # Check for the kit selector triad — all three must be present
    selector_hits = {label: (sel in code_hex) for sel, label in KIT_SELECTORS.items()}
    triad_present = all(selector_hits.values())

    return {
        'contract_address': contract_address,
        'is_pipeline': (manager_matched is not None) or triad_present,
        'manager_matched': manager_matched,
        'selector_triad_present': triad_present,
        'runtime_size_bytes': runtime_size,
        'runtime_size_matches_canonical': (
            abs(runtime_size - CANONICAL_RUNTIME_SIZE) <= 8
        ),
    }


def main():
    parser = argparse.ArgumentParser(
        description='Flag contracts belonging to the documented honeypot pipeline.'
    )
    parser.add_argument('--rpc', required=True,
                        help='JSON-RPC endpoint URL (any EVM-compatible RPC works)')
    parser.add_argument('--address',
                        help='Single contract address to check')
    parser.add_argument('--address-file',
                        help='File with one address per line')
    args = parser.parse_args()

    if not args.address and not args.address_file:
        parser.error('Provide --address or --address-file')

    addresses = []
    if args.address:
        addresses.append(args.address.strip())
    if args.address_file:
        with open(args.address_file) as f:
            addresses.extend(line.strip() for line in f if line.strip().startswith('0x'))

    hits, misses = 0, 0
    for addr in addresses:
        try:
            result = check_contract(args.rpc, addr)
        except (urllib.error.URLError, ValueError, TimeoutError) as e:
            print(json.dumps({'contract_address': addr, 'error': str(e)}))
            continue
        print(json.dumps(result))
        if result['is_pipeline']:
            hits += 1
        else:
            misses += 1

    print(f'\nSummary: {hits} pipeline hit(s), {misses} clean, {len(addresses)} checked.',
          file=sys.stderr)


if __name__ == '__main__':
    main()
