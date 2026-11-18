# AgentCheckIn — Agent ID Daily Check-in

A minimal on-chain daily check-in for Binance Agent ID holders, built for the
Binance Agent ID Hackathon (submission period 18 Nov – 9 Dec 2026, 60,000 USDC
total rewards).

## What it does

- Any wallet holding an Agent ID (SPACE ID ERC-721, non-transferable) can check
  in once per UTC day.
- The contract tracks each checker's streak (consecutive days), total
  check-ins, and last check-in time.
- A static web page shows your streak, your totals, and a leaderboard of top
  checkers.

## How Agent ID is used

- `checkIn()` requires `balanceOf(msg.sender) > 0` on the Agent ID contract
  (`0x60b9262456de011f7d15a54cdd8c48baaa8b022f`, BNB Chain mainnet).
  Non-holders cannot check in.
- The frontend checks Agent ID ownership before enabling the check-in button.
- Leaderboard and stats are read from the contract; only Agent ID holders can
  appear on it.

## No fees, no token, no admin

- Check-ins cost only BNB Chain gas. There is no token, no fee, and no
  owner/admin function. The contract cannot move user funds.

## Run the tests

Requires [Foundry](https://book.getfoundry.sh/) (`forge`).

```sh
forge install   # fetches the forge-std dependency (see .gitmodules)
forge test
forge build
```

Tests use a mock Agent ID contract (`contracts/mocks/MockAgentID.sol`) so the
real Agent ID contract is never needed for testing.

## Verify / deploy

- Constructor argument: the Agent ID contract address
  (`0x60b9262456de011f7d15a54cdd8c48baaa8b022f` on BNB Chain mainnet).
- ABI: `abi.json`; creation bytecode: `bytecode.txt`.
- Deploy gas estimate and funding needed: see `NOTES.md` and `CONTRACT.md`.
- After deploying, verify the source code on BscScan and make the repository
  public (required by the hackathon rules).

## Frontend

`frontend/index.html` — a single static page (ethers.js via CDN, no backend).
Open it in a browser (or serve it with any static host), connect MetaMask /
Binance Wallet, and check in. The user always confirms the transaction
themselves in their wallet; the page never auto-signs or bypasses confirmation.

## Hackathon safety (red lines)

- No web-based QR code login for Agentic Wallet.
- No bypassing user transaction confirmation.
- No unauthorized asset transfers.
- Contract is open-source (MIT) with no hidden permissions and no owner power
  over user funds.
- No impersonation of the Binance brand.
- No collection of seed phrases, private keys, API secrets, or pairing codes.
- No promise of returns ("passive income" or similar).
- No tool to look up other people's wallets by name.

## Files

- `contracts/AgentCheckIn.sol` — the check-in contract
- `contracts/mocks/MockAgentID.sol` — mock Agent ID for tests
- `test/AgentCheckIn.t.sol` — Foundry tests
- `frontend/index.html` — static frontend
- `abi.json`, `bytecode.txt` — compiled contract ABI and creation bytecode
- `CONTRACT.md` — contract + test + gas report
- `NOTES.md` — status, deploy prep, next steps
- `SUBMIT.md` — draft hackathon submission materials (not submitted)
