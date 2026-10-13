# 3.1b Verifikasi NotebookLM: Kepatuhan terhadap PSAK Kas dan Setara Kas

> CATATAN: Tabel di bawah adalah ringkasan yang diharapkan berdasarkan PSAK 2 (Laporan Arus Kas).
> GANTI dengan hasil asli dari sesi NotebookLM Anda sendiri, lalu lampirkan screenshot di folder `screenshots/`.

Sumber yang diunggah ke NotebookLM: (isi, misalnya PSAK 2, DDL, kode form)
Pertanyaan yang diajukan: (isi prompt asli Anda)

| Aturan bisnis dalam kode | Kesesuaian dengan PSAK 2 | Catatan |
| --- | --- | --- |
| Akun Kas dan Bank sebagai lawan voucher kas keluar | Sesuai | Kas terdiri dari saldo kas dan rekening giro/bank yang dapat ditarik kapan saja. |
| Setara kas hanya untuk investasi jangka pendek yang sangat likuid | Perlu penambahan | Kode belum membedakan deposito. Deposito jatuh tempo 3 bulan atau kurang sejak perolehan dapat menjadi setara kas. |
| Kas keluar diakui saat pembayaran terjadi | Sesuai | Pengakuan mengikuti tanggal pembayaran, bukan tanggal tagihan. |
| Pengelompokan ke aktivitas operasi, investasi, pendanaan | Perlu penambahan | Tambahkan kolom cash_flow_category pada baris jurnal. |
| Kas yang dibatasi penggunaannya | Perlu penambahan | Perlu akun terpisah atau penanda untuk pengungkapan. |
| Total debit sama dengan total kredit | Sesuai | Prinsip pencatatan berpasangan, bukan ketentuan khusus PSAK 2. |

Kesimpulan: logika inti konsisten; perbaikan yang disarankan adalah klasifikasi arus kas dan klasifikasi setara kas pada skema data.
