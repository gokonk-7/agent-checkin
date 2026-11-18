# AgentCheckIn — status & next steps

Last updated: 18 Nov 2026 (WIB). Project: Binance Agent ID Hackathon,
submission 18 Nov – 9 Dec 2026 08:00 UTC.

## Status

- [x] Contract written (Foundry, MIT, open-source) — see `CONTRACT.md`
- [x] Tests written and passing (9 passed, 0 failed) — see `CONTRACT.md`
- [x] Frontend built (`frontend/index.html` + `FRONTEND.md`) — done, tested
  headless (jsdom, 0 JS errors); real wallet interaction untested until deploy
- [ ] Repo pushed to GitHub (user `gokonk-7`) — NOT done, needs user go-ahead
- [ ] Contract deployed to BSC mainnet — **DEPLOY VIA baw GAGAL (18 Nov ~19:02 WIB):
  backend baw menolak contract creation (`"to is required for EVM
  contract-call"`). Paket deploy Remix siap di `remix/` — user deploy
  sendiri dari wallet BSC yang terisi ~0,005 BNB (bukan dari Agentic
  Wallet).** Lihat bagian "Deploy attempt 18 Nov 19:02 WIB" di bawah.
- [ ] Source verified on BscScan — after deploy
- [ ] Hackathon submission sent — NOT done, needs deploy + user go-ahead

## Contract

- `contracts/AgentCheckIn.sol`; constructor takes the Agent ID contract
  address (`0x60b9262456de011f7d15a54cdd8c48baaa8b022f` on BSC mainnet).
- Details, test results, and gas numbers: `CONTRACT.md`.

## Deploy gas estimate

Measured 18 Nov 2026 ~18:55 WIB (contract subagent, deploy to local anvil +
live BSC gas price). Details: `CONTRACT.md`.

- Deploy gas (units, receipt anvil): **690,522 gas**
- BSC gas price at check: **0.05 gwei** (50,000,000 wei; confirmed on 3 RPCs:
  bsc-dataseed, publicnode, defibit; raw `eth_gasPrice` = `0x2faf080`)
- Estimated deploy cost at 0.05 gwei: **0.0000345261 BNB ≈ $0.0203**
  (BNB $589.39 via CoinGecko)
- First `checkIn()` gas (measured on anvil): **142,068 gas ≈ 0.0000071 BNB
  ≈ $0.0042** (at 0.05 gwei)
- Sensitivity (deploy cost): 1 gwei → ~$0.41 · 3 gwei → ~$1.22 ·
  5 gwei → ~$2.03
- WARNING: 0.05 gwei is unusually low vs historical BSC 3–5 gwei. Recheck
  `cast gas-price` immediately before mainnet deploy.

## Deploy attempt 18 Nov 2026 ~19:02 WIB — via baw GAGAL, paket Remix disiapkan

- Saldo wallet `0x60037Bd32176cdC335dd8EB86aCe8b97189D7823` saat dicek:
  **0,000285460968039974 BNB** (turun dari 0,0002906 karena tx MITI revert
  19:00 WIB memakan ~0,00000515 BNB gas + klaim PXIO).
- Harga gas BSC saat dicek: **0,05 gwei** (`0x2faf080`, dikonfirmasi 3 RPC:
  bsc-dataseed, defibit, ninicoin). Biaya deploy di harga itu:
  690.522 × 0,05 gwei = **0,0000345261 BNB** — saldo CUKUP di harga ini
  (batas harga gas maksimum yang masih muat saldo: ~0,41 gwei).
- Sesi baw: **Logged in** (`baw wallet status` = "Status: Logged in",
  `baw wallet balance` = 0,000285 BNB). Catatan: `baw auth verify`
  di versi baw ini BUKAN cek sesi — perintah itu butuh `--qrCodeId`
  (untuk alur login async). Cek sesi yang benar adalah
  `baw wallet status`.
- Validasi creation data: bytecode + constructor arg ter-encode ABI
  (`00000000000000000000000060b92624...`) disimulasikan lewat `eth_call`
  dari wallet — SUKSES, mengembalikan runtime code 2.931 byte
  (constructor tidak revert). Nonce wallet (pending) saat itu: 51.
  Alamat kontrak prediksi kalau deploy dari wallet ini di nonce 51:
  `0x5937cA94e83612e88058cA858E862c7fdc3B37EF` (tidak berlaku lagi
  karena deploy tidak jadi dari wallet ini).
- **Blocker: `baw contract-call preview` (tanpa `--to`, `--value 0`,
  `--inputData <creation data>`) mengembalikan
  `{"success": false, "error": {"code": 2, "name": "SERVICE_ERROR",
  "message": "to is required for EVM contract-call"}}`.**
  Backend baw TIDAK mendukung contract creation. `baw wallet send` juga
  tidak bisa (wajib `--recipient`, tanpa `--data`). `fire.js` juga wajib
  `--to`. Tidak ada improvisasi deployer lain yang dilakukan (sesuai
  instruksi tugas).
- **Paket deploy Remix disiapkan di `remix/`:** `REMIX.md` (instruksi
  lengkap bahasa Indonesia), `AgentCheckIn.sol` (source satu file),
  `abi.json`, `creation-data.txt` (bytecode + constructor arg, 3.346 byte).
  Compiler untuk Remix/BscScan: **Solidity 0.8.24, optimizer OFF**
  (sesuai `foundry.toml`).
- Deployer Remix boleh wallet BSC mana pun yang user kuasai (bukan harus
  pemegang Agent ID); isi ~0,005 BNB supaya aman sampai 5 gwei.
- Setelah user deploy via Remix dan mengirim alamat kontrak + tx hash +
  block number ke Muse: update `frontend/index.html`
  (`CONTRACT_ADDRESS` + `DEPLOY_BLOCK`), verifikasi source di BscScan,
  verifikasi `canCheckIn(0x60037Bd...)` harus `true` (wallet pegang
  Agent ID: `balanceOf` = 1, dicek on-chain 19:02 WIB).
- BscScan verification BELUM dilakukan (tidak ada kontrak yang ter-deploy).
  Frontend BELUM di-update (masih `CONTRACT_ADDRESS = 0x0...`).

## Funding needed

- Main wallet `0x60037Bd32176cdC335dd8EB86aCe8b97189D7823` (Agent ID hazomi.ai)
  holds only ~0.000286 BNB (18 Nov 2026, per latest record — down from
  0.000296 as PXIO auto-claim keeps drawing gas).
- At the checked 0.05 gwei, the existing balance WOULD cover deploy
  (0.0000345 BNB) + many check-ins — but that price is unusually low.
- At 1 gwei deploy alone costs 0.0006905 BNB (more than the balance); at
  3 gwei 0.0020716 BNB; at 5 gwei 0.0034526 BNB.
- Recommended top-up to be safe: **~0.005 BNB** — covers deploy at up to
  ~5 gwei plus several check-ins. (PXIO auto-claim also draws gas from the
  same wallet, ~0.00001 BNB per claim, so the balance keeps drifting down.)
- Test wallet `0x2151B05fB41fDa0544DBa5B56585346B033E6287` holds 0 BNB mainnet.
- NEVER use or ask for the main wallet's seed/private key.
- Options once funded:
  1. Deploy with a custom tx via `baw` (Binance Agentic Wallet) from the main
     wallet, using the compiled bytecode + constructor arg.
  2. Deploy via Remix (user opens Remix, pastes the contract, deploys from
     their own wallet) — no key sharing.
- Deploy ONLY after the user funds the deployer wallet and confirms.

## Submit prep

- Announcement (official):
  https://www.binance.com/en/support/announcement/detail/95f5dbe0ea674a48a739b59e046648bf
- The announcement does NOT publish a project submission form URL in its
  text. It says: submit project name, website, contract address(es), Agent ID
  usage description, and other required materials during the Submission
  Period; "No registration needed". The only survey link in the announcement
  is the one for the Community Promotion Award (X promo), not for project
  submission.
- One web search result encountered while looking for the form was flagged by
  the system as untrusted and was NOT used.
- Draft submission materials: `SUBMIT.md` (not submitted).
- Before submitting, the parent agent must find the official project
  submission channel (watch Binance Wallet's official channels / the Agentic
  Wallet ecosystem page) and confirm it with the user.
- Submission deadline: 9 Dec 2026 08:00 UTC (15:00 WIB).
- Innovation Award eligibility needs the product live with at least 30 Agent
  ID addresses interacting with the contract during the Submission Period —
  distribution/promotion is required after deploy.

## Next steps (in order)

1. ~~Finish frontend (`frontend/index.html`) using `abi.json`.~~ DONE
   (frontend built + tested headless).
2. **User deploy via Remix** (paket di `remix/REMIX.md`): isi wallet BSC
   yang dikuasai dengan ~0,005 BNB, deploy `AgentCheckIn.sol` dengan
   constructor arg `0x60b9262456de011f7d15a54cdd8c48baaa8b022f`, lalu kirim
   alamat kontrak + tx hash + block number ke Muse.
3. Muse: update frontend (`CONTRACT_ADDRESS` + `DEPLOY_BLOCK`), verifikasi
   source di BscScan, verifikasi `canCheckIn()` on-chain.
4. Push repo to GitHub (user `gokonk-7`) — needs user confirmation.
5. Host the static frontend (e.g. GitHub Pages) so the submission has a live
   website URL.
6. Promote to Agent ID holders (need 30+ interacting addresses for the
   Innovation Award) during the Submission Period.
7. Submit via the official channel once confirmed (see "Submit prep").
