# Manajemen Inventori Gudang & Stock Opname — {{PROJECT_NAME}}

> Dokumen kanonikal yang menetapkan kebijakan valuasi stok, sistem zonasi gudang, formula titik pemesanan ulang (Reorder Point), dan prosedur stock opname berkala untuk `{{PROJECT_NAME}}`.

---

## 1. Konfigurasi Sistem Pergudangan

| Parameter | Nilai |
|---|---|
| **Metode Valuasi Inventori** | `{{INVENTORY_METHOD}}` |
| **Sistem Manajemen Gudang** | `{{WAREHOUSE_SYSTEM}}` |
| **Model Distribusi** | `{{DELIVERY_MODEL}}` |
| **Kepala Pengelola Inventori** | `{{DECISION_OWNER}}` |

---

## 2. Kebijakan Pencatatan & Valuasi Stok

1. **Prinsip Perputaran Stok:** Menggunakan metode `{{INVENTORY_METHOD}}` untuk memastikan perputaran barang optimal dan meminimalkan resiko barang kadaluarsa atau usang.
2. **Batch & Lot Tracking:** Seluruh item komoditas wajib mencantumkan nomor lot produksi dan tanggal kadaluarsa (*expired date*) pada label barcode sistem `{{WAREHOUSE_SYSTEM}}`.
3. **Pencatatan Real-Time:** Setiap mutasi fisik barang (masuk, keluar, transfer antar gudang, relokasi bin) wajib tercatat pada sistem dalam kurun waktu kurang dari 15 menit.

---

## 3. Tata Letak Gudang & Zonasi Penyimpanan

Gudang dibagi menjadi 4 zona fungsional terpisah:

| Kode Zona | Nama Zona | Fungsi & Karakteristik | Aksesibilitas |
|---|---|---|---|
| **Zona A** | Receiving & Dispatch Staging | Pembongkaran barang masuk, sortir awal, dan staging muat barang keluar | Area lalu lintas tinggi forklift & hand pallet |
| **Zona B** | Fast-Moving Storage | Rak tingkat bawah untuk barang berputar cepat (*high turnover / ABC Class A*) | Dekat dengan area picking & pengepakan |
| **Zona C** | Slow-Moving / Bulk Storage | Rak tingkat atas untuk persediaan penyangga (*bulk reserve / ABC Class B & C*) | Area penyimpanan jangka menengah |
| **Zona D** | Karantina, Damaged & Retur | Area tertutup dan terkunci untuk barang retur, rusak, atau belum lolos QC | Akses terbatas hanya petugas QC & Supervisor |

---

## 4. Pengendalian Tingkat Stok (Stock Control Formula)

Tingkat persediaan dikelola secara otomatis menggunakan parameter matematis:

```text
Safety Stock (SS) = (Lead Time Maksimal - Lead Time Rata-rata) × Penggunaan Harian Rata-rata
Reorder Point (ROP) = (Penggunaan Harian Rata-rata × Lead Time Pemasok) + Safety Stock
Maksimum Persediaan = ROP + Ukuran Pemesanan Ekonomis (EOQ)
```

| Parameter Stok | Deskripsi | Ambang Batas / Trigger Sistem |
|---|---|---|
| **Safety Stock (Penyangga)** | Batas aman cadangan stok mengantisipasi lonjakan permintaan | Alert sistem otomatis berstatus `WARNING` |
| **Reorder Point (ROP)** | Batas kuantitas fisik pemicu penerbitan Purchase Order otomatis | Otomatis membuat draft PO ke Departemen Pengadaan |
| **Maximum Stock** | Batas kapasitas maksimal penyimpanan rak gudang | Mencegah penumpukan modal kerja berlebih |

---

## 5. Prosedur Stock Opname (SOP Stock Opname)

### 5.1. Metode Penghitungan Fisik
- **Cycle Count (Hitung Berkala):** Dilakukan setiap hari kerja terhadap 20–30 SKU kategori fast-moving tanpa menghentikan operasional.
- **Wall-to-Wall Opname (Opname Menyeluruh):** Dilakukan 2 kali setahun (akhir semester) dengan pembekuan mutasi barang sementara (*system freeze*).

### 5.2. Toleransi Selisih & Penanganan Variansi
- **Toleransi Selisih Fisik vs Sistem:** Maksimal 0.2% dari total nilai persediaan kumulatif.
- **Langkah Jika Terjadi Selisih (*Variance*):**
  1. Penghitungan ulang kedua (*re-count*) oleh tim independen yang berbeda.
  2. Penelusuran riwayat mutasi transaksi di `{{WAREHOUSE_SYSTEM}}` selama 30 hari terakhir.
  3. Apabila selisih tetap terjadi, susun Berita Acara Selisih Stok (BASS).
  4. Penyesuaian stok (*write-off / write-in*) wajib mendapatkan persetujuan tertulis dari `{{DECISION_OWNER}}`.
