# Honeypot pipeline IOC package (Avalanche + Polygon)

Indicators of compromise (IOCs), reference decompile, and a lightweight detection heuristic for a **live, industrial-scale honeypot operation** documented across the Avalanche and Polygon networks. As of publication the operator is still active — most recent observed blacklist call: **2026-08-12** (Avalanche); most recent observed drain swap: **2026-08-14** (Avalanche).

This package accompanies the forensic report [**"Inside a 12,000-contract honeypot operation on Avalanche"**](https://prelisted.io/blog/inside-a-12000-contract-honeypot-operation.html) ([Russian version](https://prelisted.io/blog/ru/inside-a-12000-contract-honeypot-operation.html)). Every claim in the report is meant to be independently checkable against the files here.

---

## What's in the package

```
.
├── contracts/
│   ├── avalanche_campaign_1.csv     4,887 contracts (Jul-Oct 2025 targets of avalanche_key_1)
│   ├── avalanche_campaign_2a.csv    5,746 contracts (Apr-May 2026, exact-supply fingerprint)
│   ├── avalanche_campaign_2b.csv    1,585 contracts (Jun 2026 drain targets)
│   └── polygon.csv                    624 contracts (Jul 2025 — Aug 2026)
├── wallets.csv                      8 operator wallets with roles + activity windows
├── funding.json                     2 verified Binance-payout withdrawals that funded the operation
├── template_decompile.sol           Reference decompile of one canonical pipeline contract (Dedaub, solc 0.8.19)
├── detect_pipeline.py               ~150-line Python detection heuristic (stdlib only, no API key required)
├── METHODOLOGY.md                   How each dataset was derived + how to reproduce
├── DISCLOSURE.md                    Disclosure terms, corrections contact, and use-permissions
├── CHANGELOG.md                     Version history
├── SHA256SUMS                       Checksums for every data file
└── LICENSE                          CC0-1.0 (public domain dedication)
```

**Total: 12,842 pipeline contracts across 2 chains, 8 operator wallets, 2 dated CEX-payout attribution events.**

---

## Quick start

### Check a single contract

```bash
python3 detect_pipeline.py --rpc https://your-avalanche-rpc-endpoint \
                           --address 0x8014d960ecb05142b023d36dbe34a481e8b21c80
```

Output:
```json
{
  "contract_address": "0x8014d960ecb05142b023d36dbe34a481e8b21c80",
  "is_pipeline": true,
  "manager_matched": "avalanche_key_1",
  "selector_triad_present": true,
  "runtime_size_bytes": 8428,
  "runtime_size_matches_canonical": true
}
```

### Batch-check the whole avalanche_campaign_2a list

```bash
python3 detect_pipeline.py --rpc https://your-avalanche-rpc-endpoint \
                           --address-file <(tail -n +2 contracts/avalanche_campaign_2a.csv | cut -d, -f2)
```

The script has zero external dependencies (standard library only) and works against any EVM-compatible JSON-RPC endpoint — no API key required.

---

## Key operator wallets (quick reference)

| Address | Chain | Role |
|---|---|---|
| `0xce54c175880ff4edaa5d80b2dc66dda0e34a36ac` | Avalanche | hardcoded manager (key #1) — baked into 65% of sampled campaign_2a contracts and 100% of sampled campaign_1 contracts |
| `0x6b8942200b01b140db3c9053d74216fe3b710f9e` | Avalanche | hardcoded manager (key #2) + primary drain executor (10,054 successful drain swaps) |
| `0xbfd4a51c9f4c5b8109bdd462c8a57a5d268be3d0` | Polygon | hardcoded manager + drain executor (single-key architecture on polygon) |
| `0xeec6d5994b7ed166e5cf7f5444d4bf0aaebce92d` | multichain | **shared cross-chain collector** — receives drained proceeds from BOTH avalanche address_b AND the polygon manager. Definitive cross-chain identity link. |

Full 8-row dossier including deployer wallets and last-observed-activity dates is in `wallets.csv`.

---

## Two Binance customer withdrawals worth reviewing (compliance context)

Both operational wallets that bootstrap the Avalanche campaign were funded within a 2-minute window on **2025-07-22** through Binance's public payout-batching wallets. Full details (timestamps, transaction hashes, recipient addresses, amounts, from-labels) in `funding.json`.

We do not claim both withdrawals came from a single Binance customer — that determination requires Binance's internal payout records. But the pattern creates a specific verifiable attribution point that one internal query would resolve. **Binance itself is not accused of anything; a customer used their service.**

---

## Detection heuristic in one sentence

Any EVM contract whose runtime bytecode contains any of the three known hardcoded manager addresses (see `detect_pipeline.py::KNOWN_MANAGERS`) as a `PUSH20` constant — OR whose runtime bytecode contains all three custom function selectors `proof(uint256)` (`0x16e3b09c`), `Execute(address)` (`0xf3294c13`), `Approved(address)` (`0x5d91bd0c`) — is almost certainly a fork of the honeypot template documented in `template_decompile.sol`.

---

## Reproducing this package

See `METHODOLOGY.md` for the exact derivation steps for each CSV. All primary data was pulled from public block-explorer APIs (Etherscan V2 across chains) and public RPC endpoints. Anyone with a free Etherscan V2 API key and a public Avalanche/Polygon RPC endpoint can rebuild every CSV in this package from scratch and reach the same address counts.

---

## Terms of use

Released under **CC0-1.0** (public domain dedication) — see `LICENSE`. You are free to use, redistribute, and build on this data without restriction. Attribution is appreciated but not required. Corrections and additions welcome — see `DISCLOSURE.md` for how to report them.
