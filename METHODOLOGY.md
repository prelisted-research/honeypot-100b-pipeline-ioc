# Methodology

How each dataset in this package was derived, and how to reproduce it from public sources. No private data, no proprietary APIs — everything below can be rebuilt by any independent researcher with a free Etherscan V2 API key and any public Avalanche/Polygon RPC endpoint.

---

## contracts/avalanche_campaign_2a.csv (5,746 rows)

**Derivation:** exact-supply fingerprint match on the Avalanche network.

1. Enumerate contracts whose on-chain `totalSupply()` returns the exact 30-digit constant `100,018,746,193,931,376,489,308,801,730`. This constant is the "trailing digits" of the 100-billion round base plus the fixed 18.7M drain amount that Address B mints on every `proof()` call — an engineering choice that made every contract in the campaign drainable with the same fixed mint quantity.
2. Filter to contracts deployed within the two-week Apr–May 2026 window.
3. Verify identical solc `0.8.19` runtime bytecode across the set (~8,428 bytes / 16,856 hex characters).

**What we verified:**
- All 5,746 share the same `totalSupply()` fingerprint (100% match by definition of the derivation).
- 100 randomly sampled contracts, each retried 5 times: 65 contain `0xce54c17…` as PUSH20; 35 contain `0x6b89422…` as PUSH20. Zero contracts contain neither — 100% of the sample carries one of the two known hardcoded manager keys.
- Bytecode-diff of 5 canonical campaign_2a vs 5 campaign_2b contracts: byte-identical runtime; same 28 function selectors; no new state variables.

**What we did NOT verify per-row:** whether every single one of the 5,746 contracts contains a hardcoded manager. We sampled; we did not exhaustively check. The `hardcoded_manager_sampled` column reflects this honestly.

---

## contracts/avalanche_campaign_1.csv (4,887 rows)

**Derivation:** all unique `to` addresses of successful `Execute(address)` calls (methodId `0xf3294c13`) initiated by `0xce54c175…` (avalanche_key_1) between 2025-07-01 and 2025-11-01.

**Verification:** 30 random contracts pulled and checked for `0xce54c17…` as PUSH20 constant in runtime bytecode. **30 of 30 matched** — 100% of the sample carries the hardcoded manager.

---

## contracts/avalanche_campaign_2b.csv (1,585 rows)

**Derivation:** all unique `to` addresses of successful `approve(spender, amount)` calls (methodId `0x095ea7b3`) initiated by `0x6b89422…` (avalanche_key_2) between 2026-06-01 and 2026-07-01, **minus** the set of addresses that the same wallet had already approved during 2026-05-05 → 2026-05-31. This isolates the "new drain targets" that appeared in June, distinct from continued draining of May's campaign_2a set.

**Verification:** bytecode diff of 5 samples against 5 campaign_2a canonicals — byte-identical runtime, same selector triad, no new state variables. **Campaign 2B tokens are architecturally identical to Campaign 2A tokens** — the operator did not add a fee-on-transfer or burn-tax mechanism at the token level; the switched swap-router selector reflects only an operational routing preference.

---

## contracts/polygon.csv (624 rows)

**Derivation:** all unique `to` addresses of successful `approve()` OR `Execute(address)` calls initiated by `0xbfd4a51c…` (polygon manager) across the wallet's full outbound history (13 months, July 2025 – August 2026).

**Verification:** 5 sample contracts pulled and decompiled — all 5 contain `0xbfd4a51c…` hardcoded 10 times each in runtime bytecode (identical PUSH20 pattern to the Avalanche template).

**Two boolean columns:**
- `ever_drained_by_mgr` = True iff the manager wallet has ever called `approve()` targeting this contract (which is the precursor to the manager's own drain sequence). Only ~40 of 624 are true — the operator has drained only a small fraction of the pipeline directly.
- `ever_blacklisted_by_mgr` = True iff the manager wallet has ever called `Execute(address)` targeting this contract. Most of the population is true, reflecting broad blacklist coverage.

The gap (many blacklisted but few drained by the manager wallet directly) means the operator uses a "deploy widely + blacklist proactively + drain selectively" model on Polygon, rather than Avalanche's "batch drain everything" approach.

---

## wallets.csv (8 rows)

Manually assembled from the on-chain roles observed in the derivations above. Every wallet's role can be verified directly on-chain:
- Manager keys are verifiable by fetching any pipeline contract's `eth_getCode` and checking for the address as a PUSH20 constant.
- Deployer wallets are verifiable via Etherscan/Snowscan's "Contract Creations" tab.
- Drain executor is verifiable via method-distribution analysis of the wallet's outbound transaction history.
- Cross-chain collector is verifiable via ABI-decoding the `to` parameter of Address B's swap calldata + the Polygon manager's fee-on-transfer swap calldata.

---

## funding.json (2 events)

**Derivation:** raw `txlist` fetch for each recipient wallet, filtered to inbound tx from the two known Binance-labeled payout wallets (Binance 85 and Binance 110 — both carry public "Binance" labels on Avalanche block explorers), matched on the 2025-07-22 timeframe.

**Verified in the raw:**
- Binance 85 → `0xce54c175…` (Address A): 1.996 AVAX at 13:47 UTC, tx `0x887416579723a8edfe907b74a105bb13812b692c9cc1aa4df91273d3771a87a4`.
- Binance 110 → `0x3eb8d668…` (Campaign 1 deployer): 97.996 AVAX at 13:49 UTC, tx `0x5100523d9cf05f9d409ad161c9ab8688b440717f1e11b1b3ce9bc44122feecb1`.

**What is NOT asserted:** that both withdrawals originated from a single Binance customer account. That determination lives inside Binance's internal records, not on-chain. A single query against Binance's payout ledger for the 2025-07-22 13:47–13:49 UTC window would confirm or refute the shared-customer hypothesis.

---

## Reproducibility checklist

To reproduce every file in this package from scratch:

1. Get a free Etherscan V2 API key (`etherscan.io/apis`).
2. Get any public Avalanche RPC endpoint and any public Polygon RPC endpoint. No paid tier required — the read patterns are `eth_getCode` + `eth_call` + basic `txlist`, all supported by free tiers.
3. For each address CSV: re-run the derivation described above using `getcontractcreation`, `txlist` (paginated past the 10K cap by rolling `startblock`), and method-ID filters.
4. Cross-check counts against this package's SHA256SUMS.
5. For contracts_avalanche_campaign_2a specifically: sample 100 addresses, fetch `eth_getCode`, check for `ce54c175…` and `6b89422…` as substring matches in the lowercase bytecode — you should see a 65/35 split with zero neither-nor.

Expected wall-clock time to fully reproduce: **~10 minutes** on a single-thread Python script with 200ms Etherscan throttle.

---

## Explicitly retracted from earlier internal drafts

For the record — three claims that appeared in earlier working notes and were disproved before publication:

- The "Binance 49 upstream chain-of-custody" claim (that `0x9f8c163c…` topped up Binance 85 / 110 with 56,985 AVAX shortly before the operator withdrawals). **Retracted:** no such transfer surfaces in the ±30-day window around July 2025. The upstream leg of the Binance payout chain is not resolvable from public data.
- The "Campaign 2B adds a fee-on-transfer / burn-tax mechanism at the token level" claim. **Retracted:** disproved by bytecode diff. 2B tokens are architecturally identical to 2A.
- The "99.95% dormant" reading of the pipeline (from an early-stage DexScreener + TJ V1 + Pangolin V1 pool survey). **Retracted:** the operator built specifically on LFJ Liquidity Book V2.2 bin pools, which those tools do not reliably index. The pipeline is not dormant — 10,054 successful drain swaps confirm it.
