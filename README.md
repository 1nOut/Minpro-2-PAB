# 🎮 Top Up Game — Mini Project 2

Aplikasi mobile Flutter untuk admin mengelola layanan top up game online dengan integrasi **Supabase** sebagai database dan autentikasi.

---

## 📱 Deskripsi Aplikasi

**Top Up Game** adalah aplikasi berbasis Flutter yang dirancang untuk **admin** layanan top up game. Admin dapat menerima permintaan top up dari user, memproses antrian pending, memantau stok item game, dan melihat riwayat semua transaksi yang sudah selesai.

Alur kerja utama:
1. Admin membuat **permintaan top up** → status otomatis `pending`
2. Halaman **Pending** menampilkan antrian yang belum diproses
3. Admin **konfirmasi** → stok berkurang, status berubah jadi `selesai`
4. Halaman **Riwayat** menampilkan semua transaksi yang sudah selesai

---

## ✨ Fitur Aplikasi

### 🔐 Autentikasi (Supabase Auth)
- Register akun baru dengan email & password
- Login dengan validasi
- Logout dengan dialog konfirmasi
- Auto redirect ke halaman utama jika sudah login

### 🏠 Home — Pilih Game
- Menampilkan daftar game dalam tampilan grid 2 kolom
- Setiap kartu menampilkan logo, nama, dan stok tersedia
- Animasi tekan dan hover pada kartu
- Pull-to-refresh

### 📦 Inventory — Kelola Stok Game (CRUD)
- **Create** — Tambah game baru (nama, stok, logo)
- **Read** — Tampilkan daftar game dari Supabase
- **Update** — Edit stok game via dialog
- **Delete** — Hapus game dengan konfirmasi
- Indikator stok habis (label merah "Habis")

### ⏳ Pending — Antrian Top Up (Fitur Admin)
- Menampilkan semua permintaan top up yang belum diproses
- Badge **"Stok Kurang"** + tombol Proses otomatis di-disable jika stok tidak cukup
- Tombol **"Proses Top Up"** → status jadi selesai, stok berkurang
- Tombol **"Tolak"** → hapus permintaan dari antrian
- Dialog konfirmasi lengkap sebelum proses (ID Player, Email, Jumlah, sisa stok)

### 📋 Form Top Up
- Input ID Player, Jumlah, dan Email
- Validasi lengkap (field kosong, tipe data, stok cukup)
- Permintaan masuk sebagai **pending** — stok belum dikurangi
- Banner informasi bahwa permintaan akan diproses admin

### 📜 Riwayat — Transaksi Selesai
- Hanya menampilkan transaksi berstatus **selesai**
- **Search** berdasarkan ID Player, Email, atau nama Game
- **Filter chip** per game
- Badge status "Selesai" + jumlah top up di setiap kartu
- Tap kartu → Edit transaksi
- Long press kartu → Mode seleksi → Hapus banyak sekaligus
- Pull-to-refresh

### 🌗 Light Mode & Dark Mode
- Toggle via menu floating action button di pojok kanan bawah
- Konsisten di seluruh halaman

### 🔒 Environment Variables
- Supabase URL & API Key disimpan di file `.env`
- File `.env` masuk `.gitignore` (tidak ter-push ke GitHub)

---

## 🛠️ Widget yang Digunakan

| Widget | Keterangan |
|---|---|
| `MaterialApp` | Root aplikasi, konfigurasi tema light/dark |
| `StreamBuilder` | Mendengarkan perubahan status auth Supabase |
| `Scaffold` | Struktur dasar tiap halaman |
| `AppBar` / `CustomAppBar` | Header halaman kustom bertema hijau |
| `BottomNavigationBar` | Navigasi 4 tab (Home, Inventory, Pending, Riwayat) |
| `GridView.builder` | Tampilan grid kartu game di Home |
| `ListView.builder` | Tampilan list di Inventory, Pending, Riwayat |
| `GestureDetector` | Deteksi tap, long press, tap down/up |
| `MouseRegion` | Efek hover (web/desktop) |
| `AnimatedScale` | Animasi scale saat kartu ditekan |
| `AnimatedContainer` | Animasi transisi warna container filter chip |
| `Card` | Kartu untuk setiap item |
| `TextField` | Input teks (search, form, dialog) |
| `ElevatedButton` | Tombol aksi utama |
| `OutlinedButton` | Tombol Tolak di pending |
| `TextButton` | Tombol sekunder (Batal) |
| `PopupMenuButton` | Menu dark mode & logout |
| `AlertDialog` | Dialog konfirmasi dan form edit stok |
| `StatefulBuilder` | State di dalam dialog |
| `DropdownButtonFormField` | Pilihan logo game saat tambah game |
| `CircularProgressIndicator` | Indikator loading |
| `SnackBar` | Notifikasi pesan singkat |
| `RefreshIndicator` | Pull-to-refresh di semua list |
| `SingleChildScrollView` | Scroll konten form |
| `Column` / `Row` / `Expanded` | Layout dasar |
| `Container` / `SizedBox` | Dekorasi dan spasi |
| `ClipRRect` | Rounded corner pada gambar logo |
| `Image.asset` | Logo game dari assets |
| `Icon` | Ikon di seluruh UI |
| `Future.wait` | Parallel fetch data di Pending page |

---

## 🗄️ Struktur Tabel Supabase

### Tabel `games`
| Kolom | Tipe | Keterangan |
|---|---|---|
| `id` | uuid | Primary key, auto-generate |
| `nama` | text | Nama game |
| `logo` | text | Path asset logo |
| `stok` | int | Stok item (tidak boleh negatif) |

### Tabel `transaksi`
| Kolom | Tipe | Keterangan |
|---|---|---|
| `id` | uuid | Primary key, auto-generate |
| `user_id` | uuid | Relasi ke `auth.users` |
| `nama_game` | text | Nama game yang di-top up |
| `id_player` | text | ID player dalam game |
| `jumlah` | int | Jumlah top up (harus > 0) |
| `email` | text | Email pembeli |
| `status` | text | `pending` atau `selesai` |
| `created_at` | timestamptz | Waktu transaksi, auto-isi |

---

## 📁 Struktur Folder

```
lib/
├── main.dart
├── models/
│   ├── game.dart
│   └── transaksi.dart
├── pages/
│   ├── auth/
│   │   ├── login_page.dart
│   │   └── register_page.dart
│   ├── main_page.dart
│   ├── home_page.dart
│   ├── inventory_page.dart
│   ├── pending_page.dart
│   ├── riwayat_page.dart
│   ├── form_topup_page.dart
│   └── form_edit_transaksi_page.dart
├── services/
│   └── supabase_service.dart
└── widgets/
    ├── custom_appbar.dart
    └── custom_textfield.dart
```

---

## 🚀 Cara Menjalankan

1. **Clone repository ini**
   ```bash
   git clone https://github.com/username/topup-game-mp2.git
   cd topup-game-mp2
   ```

2. **Buat file `.env`** di root project (lihat `.env.example`):
   ```
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your-anon-key-here
   ```

3. **Jalankan SQL setup** di Supabase SQL Editor (file `supabase_setup.sql`)

4. **Nonaktifkan "Confirm email"** di Supabase → Authentication → Providers → Email (untuk development)

5. **Install dependencies**
   ```bash
   flutter pub get
   ```

6. **Jalankan aplikasi**
   ```bash
   flutter run
   ```

---

## 📦 Dependencies

```yaml
supabase_flutter: ^2.3.4   # Integrasi Supabase (Auth + Database)
flutter_dotenv: ^5.1.0     # Membaca file .env
intl: ^0.19.0              # Format tanggal di riwayat
```

---

## 👨‍💻 Dikembangkan untuk Mini Project 2 — Flutter & Supabase
