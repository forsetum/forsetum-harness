# Register Risiko & Rencana Kontinjensi — {{PROJECT_NAME}}

> Dokumen kanonikal yang menetapkan identifikasi risiko terstruktur, matriks evaluasi tingkat keparahan, strategi mitigasi preventif, dan rencana kontinjensi operasional untuk `{{PROJECT_NAME}}`.

---

## 1. Tata Kelola Manajemen Risiko

| Parameter | Nilai |
|---|---|
| **Kerangka Risiko Acuan** | `{{RISK_FRAMEWORK}}` |
| **Kategori Proyek** | `{{PROJECT_TYPE}}` |
| **Pimpinan Manajemen Risiko** | `{{DECISION_OWNER}}` |
| **Toleransi Risiko (Risk Appetite)** | Rendah untuk keselamatan, perizinan, dan kepatuhan finansial |

---

## 2. Matriks Evaluasi Risiko (Matriks 5 × 5)

Tingkat keparahan risiko dihitung dari perkalian **Probabilitas (P)** dan **Dampak (D)**:

$$\text{Skor Risiko} = P \times D \quad (1 - 25)$$

| Tingkat Probabilitas (P) | Tingkat Dampak (D) | Klasifikasi Skor Risiko | Tindakan Wajib |
|---|---|---|---|
| **5: Sangat Sering (Hampir Pasti)** | **5: Bencana / Fatal** | **15 – 25 (Kritis / Merah)** | Rencana mitigasi dan kontinjensi wajib disetujui langsung oleh `{{DECISION_OWNER}}` |
| **4: Sering (Kemungkinan Besar)** | **4: Mayor / Kerugian Besar** | **10 – 14 (Tinggi / Oranye)** | Pemantauan intensif berkala dan tindakan pencegahan terjadwal |
| **3: Sedang (Dapat Terjadi)** | **3: Moderat / Gangguan Sedang** | **5 – 9 (Sedang / Kuning)** | Dikelola di level supervisor workstream dengan SOP standar |
| **2: Jarang Terjadi** | **2: Minor / Gangguan Kecil** | **1 – 4 (Rendah / Hijau)** | Cukup dicatat dan dipantau secara berkala |
| **1: Sangat Jarang** | **1: Dapat Diabaikan** | | |

---

## 3. Register Risiko Proyek (Risk Register)

| ID | Kategori | Deskripsi Potensi Risiko | P | D | Skor | Strategi Mitigasi Preventif | Penanggung Jawab (PIC) |
|---|---|---|---|---|---|---|---|
| **R-01** | Operasional | Pemadaman listrik mendadak di venue saat acara berlangsung | 2 | 5 | **10** | Menyediakan genset otomatis (*automatic transfer switch*) berkapasitas 100% | Tim Perlengkapan / Venue |
| **R-02** | Operasional | Pembicara kunci (*Keynote Speaker*) berhalangan hadir mendadak | 3 | 4 | **12** | Menyiapkan narasumber cadangan setara dan materi video pre-recorded | Tim Acara & Konten |
| **R-03** | Teknis | Gangguan koneksi internet dedicated untuk livestreaming/absensi | 3 | 3 | **9** | Berlangganan 2 ISP berbeda (*dual backup failover*) dan modem GSM cadangan | Tim IT & Broadcast |
| **R-04** | Finansial | Pembengkakan biaya vendor akibat perubahan spesifikasi mendadak | 3 | 3 | **9** | Mengunci kontrak *fixed-price* dan menahan dana cadangan kontinjensi 10% | Project Manager & Finance |
| **R-05** | Legal & Safety | Keterlambatan penerbitan izin aparat keamanan / kepolisian | 2 | 5 | **10** | Pengurusan perizinan lengkap H-30 sebelum pelaksanaan acara | Tim Legal & Humas |

---

## 4. Prosedur Tanggap Darurat & Kontinjensi (Contingency SOP)

### 4.1. Skenario Kontinjensi A: Gangguan Daya Listrik
1. Tim teknis venue mengaktifkan genset otomatis dalam waktu maksimal 10 detik.
2. Master of Ceremony (MC) mengambil alih kendali panggung dengan mikrofon nirkabel portabel baterai.
3. Koordinator lapangan memandu penerangan darurat di pintu evakuasi.

### 4.2. Skenario Kontinjensi B: Cuaca Ekstrem (Hujan Badai / Angin Kencang)
1. Tim logistik segera menurunkan tenda roder transparan dan mengamankan jalur kabel audio-visual dengan pelindung tahan air (*cable protector*).
2. Jika kondisi membahayakan struktur luar ruang, pimpinan acara memerintahkan pengalihan seluruh peserta ke ruang indoor pendukung dalam waktu 15 menit.

### 4.3. Skenario Kontinjensi C: Keadaan Darurat Medis
1. Tim medis lapangan bersiaga di pos P3K dengan ambulans berstandar lengkap.
2. Evakuasi darurat ke rumah sakit rujukan terdekat dikoordinasikan dalam waktu respons maksimal 5 menit.
