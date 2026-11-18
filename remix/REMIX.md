# Deploy AgentCheckIn via Remix — paket deploy

**Kenapa paket ini ada:** deploy lewat Binance Agentic Wallet (`baw`) TIDAK
BISA. `baw contract-call preview` menolak contract creation — backend
mengembalikan error `"to is required for EVM contract-call"` (dicek
18 Nov 2026 ~19:02 WIB). `baw` hanya bisa memanggil kontrak yang sudah ada,
bukan membuat kontrak baru. `fire.js` (fastmint) juga wajib `--to`, jadi
tidak bisa dipakai untuk deploy. Tidak ada improvisasi deployer lain yang
dilakukan — paket ini adalah jalur yang benar.

**Jalur deploy:** Remix (https://remix.ethereum.org), dari wallet BSC mana
pun yang kamu kuasai dan sudah terisi BNB. **Deployer TIDAK harus pemegang
Agent ID** — kontrak hanya mengecek Agent ID saat seseorang `checkIn()`,
bukan saat deploy. Alamat reward hackathon tetap
`0x60037Bd32176cdC335dd8EB86aCe8b97189D7823` (hazomi.ai).

## Dana yang dibutuhkan

- Gas deploy (terukur): **690.522 gas**.
- Harga gas BSC saat dicek ~19:00 WIB: **0,05 gwei** → biaya deploy
  **≈ 0,0000345 BNB (≈ $0,02)**. Tapi 0,05 gwei sangat rendah dibanding
  historis BSC (3–5 gwei); di 1 gwei deploy = 0,0006905 BNB, di 5 gwei =
  0,0034526 BNB.
- **Isi wallet deployer dengan ~0,005 BNB** supaya aman sampai 5 gwei +
  masih sisa untuk beberapa check-in.
- Wallet Agentic Wallet (`0x60037Bd...`) saat ini hanya punya ~0,000285 BNB
  dan TIDAK bisa dipakai untuk deploy via Remix (tidak bisa connect ke
  dApp). Pakai wallet utama Binance / MetaMask kamu yang sudah terisi.

## Langkah deploy di Remix

1. Buka https://remix.ethereum.org (di browser desktop).
2. Buat file baru `AgentCheckIn.sol`, lalu copy-paste SELURUH isi file
   `AgentCheckIn.sol` di folder ini (sudah satu file lengkap, tidak perlu
   import).
3. Tab **Solidity Compiler**:
   - Compiler: **0.8.24**
   - **Optimizer: MATIKAN (OFF)** — bytecode referensi dikompilasi tanpa
     optimizer (Foundry default). Ini penting supaya verifikasi BscScan
     cocok.
   - Klik **Compile AgentCheckIn.sol**.
4. Tab **Deploy & Run Transactions**:
   - Environment: **Injected Provider — MetaMask** (atau WalletConnect ke
     wallet kamu). Pastikan wallet terhubung ke **BNB Smart Chain (56)**.
   - Contract: pilih **AgentCheckIn**.
   - Deploy: isi constructor dengan SATU alamat ini:
     `0x60b9262456de011f7d15a54cdd8c48baaa8b022f`
     (kontrak Agent ID / SPACE ID ERC-721 di BSC).
   - Klik **Deploy**, lalu konfirmasi transaksi di wallet. Biaya gas
     tampil di wallet sebelum konfirmasi — cek dulu wajar (di bawah
     ~0,005 BNB).
5. Setelah transaksi sukses, catat:
   - **Alamat kontrak** yang baru dibuat
   - **Tx hash**
   - **Nomor block**
   Kirim ketiganya ke Muse — Muse akan update frontend, verifikasi
   `canCheckIn()`, dan siapkan submission hackathon.

## Verifikasi source di BscScan (setelah deploy)

1. Buka https://bscscan.com/address/<alamat-kontrak> → tab **Contract** →
   **Verify and Publish**.
2. Compiler Type: **Solidity (Single file)**.
3. Compiler Version: **v0.8.24+commit.e11b9ed9**.
4. Optimization: **No**.
5. Paste source code dari `AgentCheckIn.sol` di folder ini.
6. Constructor Arguments: ABI-encoded dari alamat Agent ID — kode hex ini
   (tanpa `0x` di depan boleh, BscScan menerima keduanya):
   `00000000000000000000000060b9262456de011f7d15a54cdd8c48baaa8b022f`
7. Verify. Kalau gagal, kirim alamat kontrak ke Muse — Muse coba bantu
   lewat API BscScan.

## File di folder ini

- `AgentCheckIn.sol` — source kontrak lengkap (MIT, Solidity 0.8.24).
- `abi.json` — ABI kontrak (11 entries, untuk frontend / verifikasi).
- `creation-data.txt` — bytecode + constructor arg ter-encode (data mentah
  untuk contract creation tx, 3.346 byte; hanya untuk referensi / deploy
  via raw tx kalau kamu paham caranya — cara Remix di atas sudah cukup).
- `REMIX.md` — file ini.

## Yang TIDAK dilakukan / jangan dilakukan

- Jangan deploy dari wallet yang seed/private key-nya tidak kamu kuasai.
- Jangan kirim BNB ke alamat kontrak (kontrak ini tidak menerima / tidak
  butuh BNB).
- Jangan lakukan `checkIn()` dari wallet yang BUKAN pemegang Agent ID —
  transaksinya akan revert dan gas hangus (cek dulu `canCheckIn()` di
  frontend setelah deploy).
- Setelah deploy, JANGAN langsung submit hackathon sebelum: (1) source
  terverifikasi di BscScan, (2) repo di-push ke GitHub, (3) frontend
  di-hosting, (4) kanal submit resmi terkonfirmasi. Deadline submit:
  **9 Des 2026 08:00 UTC (15:00 WIB)**.
