# AgentCheckIn — Contract Report

**Tanggal:** Rabu, 18 November 2026 (~18:50–19:00 WIB)
**Chain target deploy:** BNB Smart Chain (BSC, chain ID 56)
**Status:** Kontrak + test selesai, kompilasi sukses, deploy lokal anvil sukses.
**TIDAK ada deploy ke mainnet.** Tidak ada private key user yang dipakai — hanya
private key test default anvil (akun #0, publik & untuk testing lokal saja).

## Ringkasan kontrak

`contracts/AgentCheckIn.sol` — SPDX MIT, Solidity ^0.8.24, Foundry 1.9.0.

- Daily check-in untuk holder Binance Agent ID (SPACE ID ERC-721, non-transferable).
- `constructor(address agentId_)` — disimpan sebagai `immutable AGENT_ID`;
  revert `ZeroAgentId()` kalau alamat nol.
- Gate holder: `AGENT_ID.balanceOf(msg.sender) > 0`, revert `"Not an Agent ID holder"`.
- Satu check-in per hari UTC per address (`block.timestamp / 1 days`).
  Streak +1 kalau hari berurutan, reset ke 1 kalau ada hari bolong.
- Event `CheckIn(address indexed user, uint256 streak, uint256 totalCheckIns, uint256 timestamp)`.
- View: `canCheckIn(address)`, `getStreak(address)`, `getTotalCheckIns(address)`,
  `getLastCheckIn(address)`, `totalCheckIns()`, `uniqueCheckers()`, plus getter
  publik `AGENT_ID()`.
- TANPA fee, TANPA token, TANPA owner/admin, TANPA upgradeability.
  Mematuhi red lines hackathon: tanpa login QR, tanpa bypass konfirmasi tx,
  tanpa transfer tidak sah, tanpa impersonasi Binance, tanpa janji return.
- Mock untuk test: `contracts/mocks/MockAgentID.sol` (`mint` + `balanceOf` saja).

## Fungsi

| Fungsi | Deskripsi |
|---|---|
| `constructor(address agentId_)` | Set immutable AGENT_ID |
| `checkIn()` | Check-in harian (holder only, 1x/hari UTC, update streak) |
| `canCheckIn(address)` | Holder DAN belum check-in hari ini |
| `getStreak(address)` | Streak hari berurutan |
| `getTotalCheckIns(address)` | Total check-in per address |
| `getLastCheckIn(address)` | Timestamp check-in terakhir |
| `totalCheckIns()` | Total check-in global |
| `uniqueCheckers()` | Jumlah address berbeda yang pernah check-in |

## Hasil test — `forge test`

**9 passed, 0 failed, 0 skipped** (1 suite, `test/AgentCheckIn.t.sol`).

| Test | Hasil |
|---|---|
| non-holder revert saat `checkIn` | PASS |
| holder bisa check-in sekali | PASS |
| check-in kedua di hari yang sama revert | PASS |
| streak naik di hari berurutan (`vm.warp` +1 hari) | PASS |
| streak reset ke 1 kalau ada hari bolong (warp +3 hari) | PASS |
| event `CheckIn` ter-emit dengan nilai benar (`vm.expectEmit`) | PASS |
| semua view function mengembalikan nilai benar | PASS |
| `uniqueCheckers` menghitung address berbeda dengan benar | PASS |
| constructor revert kalau alamat nol (tambahan) | PASS |

Catatan test: `vm.warp` memakai `T0 = 1_728_000_000` (= tepat batas hari UTC,
1_728_000_000 / 86400 = 20000) supaya batas hari UTC tidak ambigu.
`forge build` sukses (hanya warning lint non-blocking soal `block.timestamp`
dan strict equality — wajar untuk logika hari UTC).

## Deploy lokal (anvil, port 8545) — referensi saja

- Deployer (anvil akun #0, key test default): `0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266`
- Kontrak (constructor arg = alamat Agent ID asli):
  `0x5FbDB2315678afecb367f032d93F642f64180aa3`
- Tx hash: `0x418d41598a284a8b44d6660fac7d02daa907dfbb41df99d6d4ebc926e219c7f7`
- Receipt: status 1 (success), block 1, `gasUsed = 690522`
- Verifikasi: `AGENT_ID()` di kontrak ter-deploy mengembalikan
  `0x60B9262456dE011F7d15a54CdD8c48bAaa8B022F` (benar).
- Deploy uji kedua (constructor arg = mock, untuk mengukur `checkIn`):
  kontrak `0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9`,
  mock `0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512`,
  `checkIn()` pertama sukses, `gasUsed = 142068`, streak = 1, uniqueCheckers = 1.

## Estimasi gas deploy mainnet BSC (presisi)

Dicek 18 Nov 2026 ~18:55 WIB.

| Item | Nilai |
|---|---|
| Gas deploy (`gasUsed` receipt anvil) | **690.522 gas** |
| Harga gas BSC saat dicek | **50.000.000 wei = 0,05 gwei** |
| Sumber harga gas | `eth_gasPrice` via `cast gas-price`, dikonfirmasi 3 RPC: `bsc-dataseed.bnbchain.org`, `bsc-rpc.publicnode.com`, `bsc-dataseed1.defibit.io` (ketiganya 50.000.000 wei; raw `eth_gasPrice` = `0x2faf080`) |
| Biaya deploy | 690.522 × 50.000.000 wei = **0,0000345261 BNB** |
| Harga BNB saat dicek | **$589,39** (CoinGecko, 18 Nov ~18:55 WIB) |
| Biaya deploy dalam USD | **≈ $0,0203** |
| Biaya `checkIn()` pertama (142.068 gas) | 0,0000071034 BNB ≈ **$0,0042** |

Sensitivitas (kalau harga gas naik saat deploy sungguhan):
- 1 gwei → deploy 0,000690522 BNB ≈ $0,41
- 3 gwei → deploy 0,002071566 BNB ≈ $1,22
- 5 gwei → deploy 0,003452610 BNB ≈ $2,03

Catatan: 0,05 gwei adalah harga gas BSC yang sangat rendah (di bawah level
historis 3–5 gwei). Estimasi di atas memakai harga live saat pengecekan;
cek ulang `cast gas-price` tepat sebelum deploy mainnet.

## Constructor arg deploy mainnet

Satu argumen saja:

```
0x60b9262456de011f7d15a54cdd8c48baaa8b022f
```

(SPACE ID ERC-721 Agent ID, non-transferable.) Tanpa argumen lain.
Contoh perintah deploy (setelah wallet mainnet siap — JANGAN dijalankan tanpa
persetujuan user):

```
forge create contracts/AgentCheckIn.sol:AgentCheckIn \
  --rpc-url https://bsc-dataseed.bnbchain.org \
  --private-key <KEY_MAINNET_USER> --broadcast \
  --constructor-args 0x60b9262456de011f7d15a54cdd8c48baaa8b022f
```

## Lokasi file

- Kontrak: `~/workspace/agent-id-hackathon/checkin/contracts/AgentCheckIn.sol`
- Mock: `~/workspace/agent-id-hackathon/checkin/contracts/mocks/MockAgentID.sol`
- Test: `~/workspace/agent-id-hackathon/checkin/test/AgentCheckIn.t.sol`
- Config: `~/workspace/agent-id-hackathon/checkin/foundry.toml`
  (`src = "contracts"`, `out = "out"`, `libs = ["lib"]`, solc `0.8.24`;
  `lib/forge-std` v1.17.0 terinstal)
- ABI bersih: `~/workspace/agent-id-hackathon/checkin/abi.json` (11 entries)
- Bytecode (creation code): `~/workspace/agent-id-hackathon/checkin/bytecode.txt`
  (6.630 karakter incl. `0x...`)
- Laporan ini: `~/workspace/agent-id-hackathon/checkin/CONTRACT.md`

## Catatan / yang mentok

1. `forge install foundry-rs/forge-std` awalnya gagal karena folder bukan git
   repo — diperbaiki dengan `git init` di folder checkin, lalu install sukses.
2. Deploy anvil pertama gagal dua kali: (a) `forge create` tanpa `--broadcast`
   hanya dry-run dan estimasi gas-nya 0 ("Out of gas: gas required exceeds
   allowance: 0") — perlu `--broadcast` (+ `--gas-limit` tidak diperlukan
   setelah broadcast); (b) saya sempat salah ketik satu digit private key
   test anvil (`...f3ff80` vs yang benar `...f2ff80`) sehingga "Insufficient
   funds" — diperbaiki dengan key dari log anvil. Tidak ada dana user yang
   tersentuh; semua di anvil lokal.
3. BscScan gas oracle tidak bisa dipakai sebagai pembanding (API mengembalikan
   301 via Cloudflare tanpa API key) — harga gas hanya dari 3 RPC publik BSC,
   ketiganya sepakat.
4. Frontend (`frontend/`) masih kosong — belum dikerjakan dalam tugas ini.
