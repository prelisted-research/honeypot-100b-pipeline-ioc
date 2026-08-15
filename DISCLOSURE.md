# Disclosure

## Purpose

This package documents an active, industrial-scale honeypot operation for the benefit of the security ecosystem. It is intended for:

- **Wallet + safety-scanner vendors** (Rabby, MetaMask, Blockaid, De.Fi, GoPlus, Wallet Guard, honeypot.is, and others) to enrich their transaction-safety signals.
- **DEX and chain-ecosystem security teams** (Ava Labs, LFJ, Polygon Labs) to identify remaining live pools involving pipeline contracts and consider UI-level friction.
- **Exchange trust-and-safety and compliance teams** (Coinbase, Binance, Kraken, and others) to review historical customer activity linked to pipeline addresses and consider preserving relevant records.
- **Threat-intelligence vendors** (Chainalysis, TRM Labs, Elliptic, and others) to ingest the address set into their scoring pipelines and to search other chains for the template signature.
- **Independent researchers** wishing to verify, extend, or falsify the report's findings.

## What this package is not

- It is **not an accusation against any exchange, DEX, or infrastructure provider** whose systems were used by the operator. Every third-party service documented here (Binance's payout wallets, LFJ's router, Trader Joe V1) was used lawfully by an anonymous customer. Naming them is unavoidable for a complete on-chain picture; no wrongdoing on their part is implied.
- It is **not an accusation against the author of the original honeypot template**. The template is a fork of a publicly-available educational artifact published by security researcher Dev Swanson in 2023 to help defenders recognize the pattern. Swanson bears no responsibility for the operator's misuse.
- It is **not a claim to have identified the operator's real-world identity**. On-chain evidence names wallets, not people. The report includes one specific verifiable attribution point (the July 22, 2025 Binance customer withdrawals) that could resolve identity through internal Binance records, but that determination is not made here.
- **Individual addresses appearing in the `avalanche_campaign_1.csv` and Polygon blacklist lists are NOT accused of any wrongdoing.** They are the targets of the operator's `Execute(address)` blacklist calls — meaning the operator prevented them from selling the pipeline tokens. Most are almost certainly innocent buyers who acquired a pipeline token via a DEX aggregator. Downstream users of this data should treat those addresses as suspected victims, not suspects.

## Corrections and additions

The address counts and technical findings in this package were verified against public on-chain data as of **2026-08-15**. If you identify:

- Additional pipeline contracts not in this package (particularly on chains other than Avalanche and Polygon — Ethereum, BNB Chain, Arbitrum, Base, and Optimism are all worth checking for the same template signature),
- Additional operator wallets,
- Additional CEX-attribution points beyond the two documented in `funding.json`,
- Factual errors in the existing data,

please contact the maintainer via the mechanism documented in the top-level GitHub repository. Pull requests welcome. All corrections will be reflected in `CHANGELOG.md` with attribution.

## Responsible-disclosure timeline

Direct outreach to the security teams named in "Purpose" above was initiated on or before the report's public-publication date. This package is released concurrently with the report so that downstream defenders can ingest the address set without delay.

## Terms of use

Data released under **CC0-1.0** (see `LICENSE`) — public domain dedication, no restrictions on use, redistribution, or modification. The detection script `detect_pipeline.py` is released under the same terms.
