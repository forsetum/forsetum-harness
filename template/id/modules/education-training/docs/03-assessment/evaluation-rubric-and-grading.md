# Rubrik Penilaian & Kriteria Kelulusan — {{PROJECT_NAME}}

> Dokumen kanonikal yang menetapkan komponen penilaian hasil belajar, rubrik evaluasi bertingkat, kriteria kelulusan, dan format sertifikat untuk `{{PROJECT_NAME}}`.

---

## 1. Konfigurasi Evaluasi Pembelajaran

| Parameter | Nilai |
|---|---|
| **Metode Evaluasi Utama** | `{{ASSESSMENT_METHOD}}` |
| **Kategori Peserta** | `{{TARGET_LEARNER}}` |
| **Batas Minimum Kelulusan (Passing Grade)** | Skor Kumulatif Minimal 75 / 100 (atau Skala B) |
| **Kehadiran Minimum** | 80% dari total sesi terjadwal |
| **Otoritas Penilai & Sertifikasi** | `{{DECISION_OWNER}}` |

---

## 2. Bobot Komponen Penilaian Akhir

Nilai akhir peserta diakumulasikan dari empat pilar evaluasi:

| Komponen Evaluasi | Bobot | Instrumen Penilaian | Kriteria Minimum |
|---|---|---|---|
| **1. Partisipasi & Kehadiran** | 15% | Presensi digital & keaktifan diskusi sesi | Minimal kehadiran 80% |
| **2. Kuis Konseptual** | 20% | Kuis pilihan ganda / jawaban singkat via LMS | Rata-rata skor minimal 70 |
| **3. Tugas Lab & Praktik Mandiri** | 30% | Lembar kerja hands-on dan review kode/tugas | Seluruh tugas terkumpul lengkap |
| **4. Capstone Project / Ujian Akhir** | 35% | Pengerjaan proyek akhir terintegrasi & presentasi | Skor rubrik minimal 75 |
| **Total** | **100%** | | |

---

## 3. Rubrik Evaluasi Proyek Akhir (Skala 1–4)

Penilaian tugas akhir atau portofolio menggunakan rubrik analitik berstandar:

| Kriteria Penilaian | Bobot | 1 - Perlu Bimbingan (<65) | 2 - Cukup (65–74) | 3 - Baik (75–89) | 4 - Sangat Baik (90–100) |
|---|---|---|---|---|---|
| **Penerapan Konsep & Solusi** | 35% | Solusi salah konsep, tidak memenuhi spesifikasi minimal | Solusi berjalan sebagian, terdapat kekurangan logika penting | Solusi tepat, memenuhi seluruh spesifikasi yang diminta | Solusi elegan, efisien, melampaui ekspektasi spesifikasi |
| **Kualitas Teknis & Arsitektur** | 25% | Struktur berantakan, standar mutu dan best practice diabaikan | Struktur dasar ada namun banyak pelanggaran standar | Mematuhi standar arsitektur dan best practice industri | Struktur sangat rapi, modular, mudah dirawat dan dikembangkan |
| **Dokumentasi & Pengujian** | 20% | Tidak ada dokumentasi atau pengujian yang memadai | Dokumentasi minim, pengujian hanya pada alur umum | Dokumentasi jelas, cakupan pengujian memadai pada skenario inti | Dokumentasi komprehensif, pengujian mencakup skenario batas (edge cases) |
| **Presentasi & Artikulasi** | 20% | Tidak mampu menjelaskan alasan di balik keputusan solusi | Penjelasan ragu-ragu, kesulitan menjawab pertanyaan penguji | Menjelaskan alur solusi dengan lancar, lugas, dan terstruktur | Presentasi sangat persuasif, penguasaan materi menyeluruh |

---

## 4. Ketentuan Remedial & Remediasi

1. **Hak Remedial:** Peserta dengan skor kumulatif antara 60–74 berhak mengikuti 1 kali sesi remedial atau revisi proyek akhir dalam waktu maksimal 7 hari kalender.
2. **Batas Nilai Remedial:** Skor maksimal yang dapat diperoleh melalui jalur perbaikan remedial adalah batas minimum kelulusan (75 / B).
3. **Keterlambatan Pengumpulan:** Pemotongan nilai sebesar 10% per hari keterlambatan, dengan batas toleransi maksimum 3 hari kalender.

---

## 5. Format & Predikat Sertifikat Kelulusan

Peserta yang dinyatakan memenuhi seluruh kriteria berhak menerima sertifikat resmi:

### 5.1. Skala Predikat Kelulusan
- **Skor 90 – 100:** Lulus dengan Predikat Amat Baik (*With Distinction*)
- **Skor 80 – 89:** Lulus dengan Predikat Baik (*With Merit*)
- **Skor 75 – 79:** Lulus (*Passed*)
- **Skor < 75:** Surat Keterangan Keikutsertaan (*Certificate of Attendance*)

### 5.2. Format Data Sertifikat
- **Nomor Dokumen:** `CERT-{{PROJECT_NAME}}-YYYYMM-[ID_PESERTA]`
- **Nama Penerima:** `[NAMA_LENGKAP_PESERTA]`
- **Kompetensi / Modul Teruji:** Lingkup materi `{{CURRICULUM_SCOPE}}`
- **Tanggal Kelulusan:** `YYYY-MM-DD`
- **Otoritas Pengesahan:** `{{DECISION_OWNER}}` (Ketua Program / Direktur Pelatihan)
