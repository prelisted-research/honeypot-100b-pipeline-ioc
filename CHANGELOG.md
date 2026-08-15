# Changelog

## v1.0.0 — 2026-08-15

Initial public release, concurrent with the forensic report *"Inside a 12,000-contract honeypot operation on Avalanche."*

### Contents

- `contracts/avalanche_campaign_1.csv` — 4,887 blacklist-target contracts (Jul-Oct 2025)
- `contracts/avalanche_campaign_2a.csv` — 5,746 exact-supply-fingerprint contracts (Apr-May 2026)
- `contracts/avalanche_campaign_2b.csv` — 1,585 June 2026 drain-target contracts
- `contracts/polygon.csv` — 624 pipeline contracts (Jul 2025 – Aug 2026)
- `wallets.csv` — 8 operator wallets with roles and activity windows
- `funding.json` — 2 verified Binance-payout attribution events
- `template_decompile.sol` — reference decompile of one canonical pipeline contract
- `detect_pipeline.py` — Python detection heuristic (stdlib only)
- `README.md`, `METHODOLOGY.md`, `DISCLOSURE.md`, `LICENSE`, `SHA256SUMS`

### Coverage snapshot (verified 2026-08-15)

- **12,842 pipeline contracts** documented across 2 chains.
- **8 operator wallets** identified: 3 hardcoded managers (2 on Avalanche, 1 on Polygon), 4 deployers, 1 shared cross-chain collector.
- **10,054 successful drain swaps** by the Avalanche drain wallet, consolidating **462.79 AVAX** at the shared collector.
- **Cross-chain identity link** established via calldata ABI-decode: 37 of 42 decoded Polygon drain swaps route proceeds to the same wallet that receives Avalanche drain proceeds.
- **Operation is live** as of publication: most recent observed blacklist call 2026-08-12, most recent observed drain swap 2026-08-14.
