# AgentCheckIn — Frontend

**Tanggal:** Rabu, 18 November 2026 (~19:00 WIB)
**Status:** Selesai, sudah diuji. **TIDAK di-deploy ke mana pun, TIDAK ada wallet
yang dihubungkan, TIDAK ada transaksi yang dikirim.**

## File

- `index.html` — satu file statis, self-contained (kecuali ethers via CDN).
- `FRONTEND.md` — laporan ini.

## Cara membuka / serve halaman

Halaman ini file HTML statis biasa. Karena memakai CDN, butuh koneksi internet
untuk memuat ethers.

**Opsi A — buka langsung:** double-click `index.html`, atau buka
`file:///…/frontend/index.html` di browser.

**Opsi B — serve lokal (disarankan, supaya konsisten):**

```bash
cd ~/workspace/agent-id-hackathon/checkin/frontend
python3 -m http.server 8080
# lalu buka http://localhost:8080/
```

Tidak ada build step, tidak ada backend, tidak ada API key.

## Yang harus diisi setelah deploy

Di bagian atas `<script>` di `index.html`, blok `CONFIG`:

```js
const CONTRACT_ADDRESS = "0x0000000000000000000000000000000000000000"; // GANTI SETELAH DEPLOY
const DEPLOY_BLOCK = 0; // GANTI DENGAN BLOCK DEPLOY untuk leaderboard
```

1. **`CONTRACT_ADDRESS`** — ganti dengan alamat kontrak `AgentCheckIn` yang
   ter-deploy di BSC mainnet (dari output `forge create`).
2. **`DEPLOY_BLOCK`** — ganti dengan nomor block saat kontrak di-deploy
   (dari receipt deploy). Dipakai sebagai `fromBlock` saat query event
   `CheckIn` untuk leaderboard — makin akurat, makin cepat query-nya.

Yang **tidak perlu diganti**:

- `AGENT_ID_ADDRESS = "0x60b9262456de011f7d15a54cdd8c48baaa8b022f"`
  (kontrak Agent ID asli, BSC mainnet — sudah benar).
- `CHAIN_ID = 56` (BSC mainnet).

Selama `CONTRACT_ADDRESS` masih placeholder, halaman tetap bisa dibuka:
statistik user menampilkan "—", tombol check-in nonaktif, dan leaderboard
menampilkan *"Kontrak belum di-deploy — leaderboard aktif setelah deploy"*
(tanpa error).

## Versi ethers CDN

- **ethers v6.13.0 (UMD)** — `https://cdn.jsdelivr.net/npm/ethers@6.13.0/dist/ethers.umd.min.js`
- URL diverifikasi bisa diakses (HTTP 200, header `x-jsd-version: 6.13.0`,
  dicek 18 Nov 2026 ~18:54 WIB). Headless test mengonfirmasi
  `ethers.version === "6.13.0"` saat halaman dimuat.

## Fitur

1. **Connect Wallet** — `window.ethereum` (MetaMask / Binance Wallet).
   Deteksi chain; kalau bukan BSC (56), tampil tombol "Pindah ke BSC"
   (`wallet_switchEthereumChain`, tambah chain otomatis kalau belum ada,
   `wallet_addEthereumChain`). Alamat terhubung ditampilkan disingkat
   (`0x6003…7823`). Sesi yang sudah terhubung dipulihkan pasif saat halaman
   dimuat ulang; `accountsChanged` / `chainChanged` ditangani (reload).
2. **Status Agent ID** — `balanceOf(address)` di kontrak Agent ID; badge
   "Ya/Tidak". Kalau tidak pegang Agent ID, tombol check-in nonaktif dengan
   penjelasan.
3. **Kartu statistik user** — streak (`getStreak`), total check-in
   (`getTotalCheckIns`), check-in terakhir (`getLastCheckIn`, format tanggal
   Indonesia), bisa check-in hari ini atau tidak (`canCheckIn`).
4. **Kartu statistik global** — total check-in (`totalCheckIns`) dan jumlah
   checker unik (`uniqueCheckers`), dibaca via RPC publik BSC
   (`bsc-dataseed.bnbchain.org`) sehingga tampil tanpa wallet.
5. **Tombol Check-in** — memanggil `checkIn()` via signer. **User HARUS
   konfirmasi tx sendiri di wallet** — tidak ada auto-sign, tidak ada bypass.
   Status ditampilkan bertahap: menunggu konfirmasi → tx hash → sukses/gagal.
   Setelah sukses, statistik user + global + leaderboard di-refresh.
6. **Leaderboard top 10** — query event `CheckIn` dari `DEPLOY_BLOCK`
   (`queryFilter`), agregasi per address (total check-in + streak saat ini,
   dihitung dari hari UTC berurutan berdasarkan timestamp event), urut
   berdasarkan total check-in. Placeholder tampil ramah sebelum deploy.

Desain: netral (abu-abu/biru, tanpa meniru brand Binance), mobile-friendly
(max-width 720px, grid 2 kolom yang menyempit di layar kecil). Catatan di
bawah halaman: *"Check-in hanya butuh gas BNB, tanpa fee dan tanpa token."*
Tidak ada klaim passive income/return, tidak ada lookup wallet orang lain
berdasarkan nama, tidak ada login QR.

Penanganan error yang ramah (pesan tampil di halaman, tidak crash): wallet
tidak ada, chain salah, user menolak tx (`ACTION_REJECTED` / 4001), saldo BNB
kurang, RPC gagal, ethers CDN gagal dimuat.

## Hasil pengujian (18 Nov 2026 ~19:00 WIB)

| Pengujian | Hasil |
|---|---|
| CDN ethers 6.13.0 bisa diakses (HTTP 200) | ✅ PASS |
| Validasi sintaks JS (`node --check` pada script inline yang diekstrak) | ✅ PASS |
| ABI di halaman sama persis dengan `../abi.json` (deep-equal via script, 11 entries, urutan + isi) | ✅ PASS |
| Headless load test (jsdom, serve via `http.server`, CDN ethers sungguhan dimuat) | ✅ PASS — `ethers` terdefinisi, versi 6.13.0, **0 error JS**, 6 kartu tampil, tombol Connect ada, tombol Check-in disabled tanpa wallet, leaderboard menampilkan pesan placeholder, klik Connect tanpa wallet menampilkan pesan ramah "Wallet tidak ditemukan. Pasang MetaMask atau Binance Wallet…" |
| Deploy / hubung wallet / kirim tx | ❌ TIDAK DILAKUKAN (sesuai instruksi tugas) |

Catatan pengujian: headless test memakai jsdom, bukan Chromium asli — interaksi
wallet sungguhan (MetaMask/Binance Wallet, pop-up konfirmasi tx, query event
setelah deploy) **belum diuji** dan baru bisa diuji setelah kontrak di-deploy
dan dibuka di browser dengan wallet. RPC publik BSC tidak dipanggil saat
pengujian karena `CONTRACT_ADDRESS` masih placeholder (by design — statistik
global + leaderboard return lebih awal).

## Catatan

- ABI di halaman **disisipkan secara programatik** dari `../abi.json`
  (bukan diketik ulang), lalu diverifikasi identik via script.
- Streak leaderboard dihitung dari event on-chain (hari UTC berurutan),
  bukan dari `getStreak` per address — supaya tidak perlu N panggilan RPC
  untuk N address.
- Kalau RPC publik `bsc-dataseed.bnbchain.org` lambat/down, statistik global
  dan leaderboard menampilkan "—" / pesan error ramah; fungsi connect +
  check-in (yang memakai `window.ethereum`) tidak terpengaruh.
