# 2.2 Penanganan Concurrency (Race Condition)

**Masalah.** Dua kasir menjual item yang sama saat stok tinggal 1. Keduanya membaca stok = 1, keduanya lolos pengecekan, lalu keduanya menjual sehingga terjadi overselling. Penyebabnya adalah pola check-then-act yang tidak atomik.

**Solusi 1: pessimistic locking (`SELECT ... FOR UPDATE`).** Kasir kedua menunggu sampai kasir pertama COMMIT, lalu membaca stok terbaru (0) dan ditolak.

**Solusi 2: UPDATE atomik bersyarat.** Cek dan pengurangan dalam satu pernyataan (`WHERE stock_qty >= qty`); jumlah baris terpengaruh 0 berarti stok habis.

**Solusi 3: isolasi SERIALIZABLE dengan retry.** Transaksi yang bentrok gagal dengan SQLSTATE `40001`; aplikasi mengulang seluruh transaksi.

**Pada trigger Soal 2.1**, UPDATE di dalam trigger sudah mengunci baris item. Pada isolasi default READ COMMITTED, transaksi kedua menunggu, membaca ulang baris yang sudah berubah (stok 0), lalu trigger memunculkan `RAISE EXCEPTION`. Untuk transaksi yang menyentuh banyak item, kunci diambil dengan urutan yang sama (`ORDER BY item_id`) agar tidak terjadi deadlock.

Kode lengkap: [`concurrency.sql`](concurrency.sql). Untuk mensimulasikan, buka dua tab SQL dan jalankan Solusi 1 secara bergantian sebelum COMMIT.
