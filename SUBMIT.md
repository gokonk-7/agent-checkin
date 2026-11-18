# Hackathon submission — DRAFT (not submitted)

Binance Agent ID Hackathon, submission period 18 Nov – 9 Dec 2026 08:00 UTC.
Do NOT submit until the contract is deployed, the source is verified on
BscScan, and the user confirms.

## Project name

AgentCheckIn — Agent ID Daily Check-in

## Website

TBD — static frontend (`frontend/index.html`), to be hosted (e.g. GitHub
Pages after the repo is pushed). No live URL yet.

## Contract address(es)

TBD — not deployed yet. BSC mainnet (chain 56).
Constructor argument (1× address): Agent ID contract
`0x60b9262456de011f7d15a54cdd8c48baaa8b022f`.

## Agent ID usage description

AgentCheckIn is a minimal on-chain daily check-in gated by Agent ID
ownership. `checkIn()` requires the caller to hold an Agent ID
(`balanceOf(msg.sender) > 0` on the SPACE ID Agent ID contract). Each holder
can check in once per UTC day; the contract tracks streaks (consecutive
days), total check-ins, and last check-in per address, and emits a `CheckIn`
event. The frontend verifies Agent ID ownership before enabling the check-in
button and reads streaks, totals, and the leaderboard from the contract.
Only Agent ID holders can appear on the leaderboard. Agent ID is used as
identity and access control at the core of the product — not as a lookup
tool and not for payments.

## Repository (open-source, MIT)

Local: `~/workspace/agent-id-hackathon/checkin/`
GitHub (after push, user `gokonk-7`): TBD — not pushed yet.

## Reward receiving address

`0x60037Bd32176cdC335dd8EB86aCe8b97189D7823` (BSC; Agent ID hazomi.ai)

## Team

Individual — hazomi.ai (Agent ID holder, Binance Agentic Wallet user).

## Other required materials (to attach at submission)

- Deployed contract address + BscScan verification link (after deploy).
- Public GitHub repo link (after push).
- Live website URL (after hosting).
- Short demo / screenshots of the frontend (optional but recommended).

## Submission channel

The official announcement does not publish a project submission form URL.
Confirm the official channel (Binance Wallet official channels / Agentic
Wallet ecosystem page) before submitting. Do not submit through any
unofficial link.
