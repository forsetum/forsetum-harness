# Arsitektur Kampanye Iklan & Optimasi ROAS — {{PROJECT_NAME}}

> Panduan kanonikal struktur akun iklan berbayar, formulasi ad copy berkonversi tinggi, pengujian angle kreatif, dan kalkulasi batas rugi ROAS untuk `{{PROJECT_NAME}}`.

---

## 1. Parameter Kampanye Berbayar

| Parameter | Nilai Instansiasi |
|---|---|
| **Saluran Berbayar Utama** | `{{AD_CHANNELS}}` |
| **Tujuan Bisnis Kampanye** | `{{CAMPAIGN_OBJECTIVE}}` |
| **Alokasi Anggaran Bulanan** | `{{BUDGET_ALLOCATION}}` |
| **Target Efisiensi Biaya (ROAS/CPA)** | `{{TARGET_ROAS_OR_CPA}}` |
| **Penanggung Jawab Anggaran** | `{{DECISION_OWNER}}` |
| **Misi Kampanye & Proposisi Nilai** | `{{PROJECT_MISSION}}` |

---

## 2. Struktur Funnel Akun Iklan

1. **Top of Funnel (TOF) — Cold Audience Awareness:**
   - Menjangkau prospek baru melalui penargetan minat luas (*broad targeting*) atau *lookalike audience*.
   - Fokus konten: Edukasi problem utama, mitos industri, dan solusi inovatif produk.
2. **Middle of Funnel (MOF) — Consideration & Social Proof:**
   - Retargeting pemirsa yang menonton >50% video atau mengunjungi landing page dalam 30 hari terakhir.
   - Fokus konten: Studi kasus, testimoni pengguna, dan teardown perbandingan fitur.
3. **Bottom of Funnel (BOF) — Direct Conversion & Offer:**
   - Retargeting prospek yang telah masuk checkout atau mengisi form pendaftaran namun belum tuntas.
   - Fokus konten: Penawaran khusus, jaminan garansi, dan teks urgensi batas waktu.

---

## 3. Disiplin Anggaran & Protokol Stop-Loss

- [ ] Konversi pixel server-side (Meta CAPI / GA4 Measurement Protocol) telah diverifikasi akurasinya.
- [ ] Aturan otomatisasi pembatasan rugi (*kill rule*): Matikan ad set jika belanja telah mencapai 1.5x target CPA tanpa konversi.
- [ ] Scaling rule: Tingkatkan anggaran harian maksimal 20% tiap 48 jam jika ROAS konsisten di atas target.
