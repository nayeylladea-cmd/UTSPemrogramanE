# 1.3 Analisis Audit dan Keamanan Finansial: Header-Line vs Tabel Tunggal

**Dari sisi 3NF.** Pada tabel tunggal, setiap baris mengulang tanggal, nomor bukti, dan deskripsi, sehingga atribut tersebut bergantung pada nomor jurnal saja, bukan pada kunci baris (pelanggaran 2NF). Nama akun yang bergantung pada kode akun adalah ketergantungan transitif yang melanggar 3NF. Pada desain tiga tabel, tiap fakta disimpan satu kali: data transaksi di header, nominal di line, atribut akun di chart_of_accounts.

**Dari sisi anomali data.** Pada tabel tunggal, mengubah tanggal satu jurnal berarti mengubah banyak baris; satu baris yang terlewat membuat jurnal inkonsisten (update anomaly). Menghapus satu baris dapat meninggalkan jurnal timpang (deletion anomaly). Pada model header-line, perubahan dan penghapusan dapat dicegat oleh constraint dan trigger.

**Dari sisi jejak audit.**
1. Status posting, pembuat, waktu, dan hash checksum melekat pada satu baris header sebagai satu unit transaksi, sehingga mudah dikunci (immutable) dan diaudit.
2. Keseimbangan jurnal diuji dengan agregasi per header (SUM debit = SUM credit).
3. Koreksi dilakukan dengan menambah header dan line baru (jurnal pembalik), sehingga riwayat tidak tertimpa.
4. ON DELETE RESTRICT mencegah akun atau header yang sudah dipakai terhapus dan meninggalkan baris yatim.
5. Nomor bukti yang unik mencegah pencatatan ganda dan memudahkan penelusuran ke dokumen sumber.
