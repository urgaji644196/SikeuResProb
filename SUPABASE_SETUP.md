# Menyiapkan Supabase untuk aplikasi GUP

GitHub Pages tetap digunakan untuk hosting halaman web. Supabase menyediakan login, PostgreSQL, kebijakan keamanan Row Level Security (RLS), dan sinkronisasi realtime.

## 1. Buat proyek Supabase

1. Buat proyek di [Supabase](https://supabase.com/dashboard). Pilih wilayah dan pengaturan yang disetujui instansi.
2. Simpan database password di pengelola kata sandi; password itu tidak digunakan di `index.html`.
3. Dari halaman **Connect** atau **Project Settings → API**, salin **Project URL** dan **publishable/anon key**.
4. Di pengaturan Authentication, nonaktifkan pendaftaran publik (**Allow new users to sign up**) karena aplikasi ini hanya memiliki satu admin.

## 2. Buat akun admin

Aplikasi menampilkan username admin `197610312014121001`, lalu memetakannya ke email internal:

```text
197610312014121001@PROJECT_REF.supabase.co
```

Ganti `PROJECT_REF` dengan bagian hostname pada Project URL. Contohnya, URL `https://abcxyz.supabase.co` menghasilkan email login `197610312014121001@abcxyz.supabase.co`.

Di **Authentication → Users**, buat satu pengguna dengan email alias dan password baru yang kuat. Tandai email sebagai **confirmed** jika dashboard meminta konfirmasi. Alias ini bukan kotak surat; reset password dilakukan admin lewat dashboard Supabase, bukan email. Jangan gunakan password yang pernah dibagikan di percakapan.

Salin UID pengguna tersebut. Jangan memberikan akses admin kepada akun lain.

## 3. Siapkan database dan RLS

1. Buka **SQL Editor → New query**.
2. Jalankan seluruh isi `supabase/schema.sql`. Skrip membuat tabel, mengaktifkan RLS, menerapkan policies, dan mengaktifkan tabel pada Supabase Realtime.
3. Tambahkan UID admin melalui SQL Editor, dengan mengganti UUID contoh:

   ```sql
   insert into public.app_admins (user_id)
   values ('GANTI_DENGAN_UID_ADMIN');
   ```

4. Pada `index.html`, ganti:
   - `https://GANTI_PROJECT_REF.supabase.co` dengan Project URL.
   - `GANTI_DENGAN_SUPABASE_PUBLISHABLE_KEY` dengan publishable/anon key.
   - `GANTI_DENGAN_UID_ADMIN` dengan UID akun admin yang sama.

Publishable/anon key memang digunakan oleh halaman web. **Jangan pernah** menaruh `service_role`/secret key atau password database di HTML, GitHub, atau browser.

Policies RLS mengizinkan publik hanya membaca tabel `rekap` dan agregat `dashboard_summary`. Semua penulisan serta tabel `detail`, `kas`, dan `talangan` dibatasi ke UID di `app_admins`. Menyembunyikan tab di tampilan bukan batas keamanan; RLS adalah perlindungan utamanya.

## 4. Uji sebelum menerbitkan

1. Uji melalui GitHub Pages atau server lokal melalui HTTP/HTTPS. Login admin dan autentikasi Supabase umumnya tidak berjalan baik jika halaman dibuka sebagai `file://`.
2. Tanpa login, pastikan Dashboard dan Rekap GUP dapat dibaca, tetapi tab admin tidak muncul.
3. Login dengan username dan password admin. Pastikan halaman Input GUP, Rekap Kas, Input Kas, dan Talangan tersedia, lalu uji satu data sementara.
4. Pastikan perubahan dari satu browser terlihat pada browser kedua.
5. Di Supabase **Table Editor/SQL Editor**, pastikan data tersimpan di `rekap`, `detail`, `kas`, `talangan`, dan ringkasan di `dashboard_summary`.
6. Setelah lolos uji, commit dan push `index.html`, `supabase/schema.sql`, dan dokumentasi ini. GitHub Pages akan menerbitkan perubahan.

## 5. Migrasikan data lama

Data lama masih berada di localStorage browser, terpisah untuk setiap browser/perangkat. Login admin dari setiap browser yang menyimpan data lama; aplikasi akan menawarkan migrasi dan menggabungkan record ke Supabase berdasarkan ID. Data lokal tidak dihapus. Cadangkan data lebih dahulu dan periksa isi/jumlah data setelah migrasi.

## Akses publik dan perlindungan data

- Rincian Rekap GUP, termasuk nama subsatker, nominal, dan status pembayaran, dapat dilihat publik tanpa login sesuai keputusan pemilik aplikasi.
- Kas dan talangan rinci hanya dapat dilihat admin. Dashboard publik hanya menerima ringkasan angka kas/talangan.
- Pastikan publikasi rincian Rekap GUP disetujui instansi. Jika tidak boleh publik, ubah policy RLS dan aplikasi agar memerlukan login untuk membaca rekap juga.
- Paket gratis dapat memiliki batas penggunaan, jeda proyek tidak aktif, atau ketentuan yang berubah. Periksa [harga Supabase](https://supabase.com/pricing) dan kebijakan instansi sebelum memakai data dinas sebenarnya.
