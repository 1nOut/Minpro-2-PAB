# 🎮 Mini Project 2 PAB
# 💎 Aplikasi Manajemen Top Up Game

Aplikasi mobile Flutter untuk admin mengelola layanan top up game online dengan integrasi **Supabase** sebagai database dan autentikasi.

# 📱 Deskripsi Aplikasi

Aplikasi ini merupakan aplikasi berbasis Flutter yang dirancang untuk **admin** layanan top up game. Admin dapat menerima permintaan top up dari user, memproses antrian pending, memantau stok item game, dan melihat riwayat semua transaksi yang sudah selesai.

Halaman Utama: 

🏠 **Home Page** → Menampilkan daftar game yang tersedia untuk membuat permintaan top up

📦 **Inventory Page** → Mengelola data game beserta stok (tambah, edit, hapus)

⏳ **Pending Page** → Memproses antrian permintaan top up dari pengguna

📜 **Riwayat Page** → Melihat riwayat transaksi top up yang telah selesai

👤 **Profile Page** → Melihat informasi akun dan mengganti password



# Struktur Folder

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
│   ├── profile_page.dart
│   └── form_topup_page.dart
├── services/
│   └── supabase_service.dart
├── theme/
│   └── app_theme.dart
└── widgets/
    ├── game_image.dart
    ├── custom_appbar.dart
    └── custom_textfield.dart
```

# Fitur Aplikasi

## 1. Autentikasi (Login & Register)

- Login menggunakan email dan password via Supabase Auth
- Register akun baru dengan konfirmasi password
- Logout dengan konfirmasi dialog

## 2. Daftar Game (Home)

- Menampilkan seluruh game dalam bentuk grid
- Setiap kartu game menampilkan logo, nama game, dan jumlah stok
- Chip stok berubah warna merah jika stok habis
- Tap kartu game untuk langsung membuat permintaan top up

## 3. Top Up Game

- Halaman form untuk mengajukan permintaan top up
- Input field untuk ID Player, jumlah top up, dan email
- Permintaan masuk ke antrian pending untuk diproses admin

## 4. Manajemen Inventory (CRUD Game)

- Menampilkan daftar game beserta stok saat ini dengan progress bar
- **Tambah (CREATE)** game baru dengan nama, stok awal, dan foto logo dari galeri
- **Edit (UPDATE)** stok game melalui bottom sheet
- **Hapus (DELETE)** game dengan konfirmasi dialog
- Upload gambar logo ke Supabase Storage

## 5. Antrian Pending

- Menampilkan semua permintaan top up yang belum diproses
- **Proses** permintaan top up — stok game otomatis berkurang (UPDATE)
- **Tolak & hapus** permintaan yang tidak valid (DELETE)

## 6. Riwayat Transaksi

- Menampilkan semua transaksi yang sudah selesai (READ)
- Filter berdasarkan nama game
- Pencarian berdasarkan ID Player, email, atau nama game
- Hapus satu transaksi atau pilih banyak sekaligus dengan long press
- Swipe kiri untuk hapus cepat

## 7. Profil & Akun

- Menampilkan informasi akun (email, tanggal bergabung)
- Ganti password dengan verifikasi password lama terlebih dahulu

## 8. Navigasi & Tema

- Bottom navigation bar custom dengan animasi aktif
- Dukungan Light Mode dan Dark Mode yang bisa di-toggle dari menu
- Real-time sync antar akun menggunakan Supabase Realtime

# Widget yang Digunakan

## 1. Widget Layout dan Navigation
| Widget | Fungsi |
|--------|--------|
| `MaterialApp` | Root aplikasi dengan konfigurasi tema |
| `Scaffold` | Struktura dasar setiap halaman |
| `CustomScrollView` | Scroll view dengan sliver support |
| `SliverAppBar` | AppBar yang collapse saat scroll |
| `SliverGrid` | Grid game di halaman Home |
| `SliverList` | List kartu di Inventory, Pending, Riwayat |
| `SliverPadding` | Padding untuk sliver content |
| `SliverToBoxAdapter` | Menempatkan widget biasa dalam sliver |
| `SliverFillRemaining` | Mengisi sisa layar (loading/empty state) |
| `Row` | Layout horizontal |
| `Column` | Layout vertikal |
| `Expanded` | Layout fleksibel dalam Row/Column |
| `Stack` + `Positioned` | Dekorasi lingkaran di background AppBar |
| `SafeArea` | Menghindari area notch/status bar |
| `SizedBox` | Spacing antar widget |
| `Padding` | Memberikan jarak pada widget |
| `Container` | Styling, dekorasi, dan kartu UI |
| `ClipRRect` | Gambar dengan border radius |

## 2. Widget Input
| Widget | Fungsi |
|--------|--------|
| `TextField` | Input email, password, ID player, jumlah, dll |
| `TextEditingController` | Mengambil dan mengontrol nilai input |
| `GestureDetector` | Deteksi tap pada tombol dan kartu custom |
| `Dismissible` | Swipe kiri untuk hapus kartu di Riwayat |
| `ListView.separated` | Filter chip game di Riwayat |

## 3. Widget Dialog & Overlay
| Widget | Fungsi |
|--------|--------|
| `AlertDialog` | Konfirmasi hapus, logout, proses top up |
| `showModalBottomSheet` | Form tambah game, edit stok, detail transaksi, menu |
| `SnackBar` | Notifikasi sukses dan error |

## 4. Widget Animasi
| Widget | Fungsi |
|--------|--------|
| `AnimatedContainer` | Animasi tombol dan kartu saat state berubah |
| `AnimatedSwitcher` | Animasi pergantian icon di bottom nav |
| `AnimatedBuilder` | Animasi stagger kartu game di Home |
| `FadeTransition` | Animasi fade masuk di halaman Login & Register |
| `SlideTransition` | Animasi slide naik di halaman Login & Register |
| `AnimationController` | Mengontrol durasi dan curve animasi |
| `CurvedAnimation` | Kurva animasi easeOut |
| `LinearProgressIndicator` | Progress bar visual stok game |

## 5. Widget Gambar
| Widget | Fungsi |
|--------|--------|
| `Image.network` | Menampilkan logo game dari URL Supabase Storage |
| `Image.asset` | Menampilkan logo game dari asset lokal |
| `Image.memory` | Preview gambar yang dipilih dari galeri (web) |
| `GameImage` (custom) | Widget helper otomatis memilih antara network/asset |

## 6. Widget Lainnya
| Widget | Fungsi |
|--------|--------|
| `StreamBuilder` | Mendengarkan perubahan status autentikasi Supabase |
| `StatefulWidget` | Halaman dengan state dinamis |
| `StatelessWidget` | Widget tanpa state (dialog, tile) |
| `CircularProgressIndicator` | Indikator loading |
| `LinearGradient` | Gradient warna pada kartu dan AppBar |
| `BoxDecoration` | Dekorasi border radius, shadow, gradient |
| `BoxShadow` | Efek bayangan pada kartu |
| `Icon` | Ikon UI dari Material Icons |


# Teknologi & Package

| Package | Versi | Kegunaan |
|---------|-------|----------|
| `supabase_flutter` | ^2.3.4 | Database, Auth, Storage, Realtime |
| `flutter_dotenv` | ^5.1.0 | Menyimpan URL & API Key di file `.env` |
| `google_fonts` | ^6.1.0 | Font Plus Jakarta Sans |
| `image_picker` | ^1.0.7 | Memilih gambar dari galeri |
| `intl` | ^0.19.0 | Format tanggal dan waktu |



# Contoh Penggunaan Aplikasi

## 1. Tampilan Page Login

<img width="1919" height="908" alt="Image" src="https://github.com/user-attachments/assets/76db98ea-7818-494f-91d3-32ababc96638" />

## 2. Tampilan Page Register

<img width="1919" height="907" alt="Image" src="https://github.com/user-attachments/assets/208817e0-034c-439b-a935-830449fcb595" />

## 3. Tampilan Page Home

<img width="1919" height="910" alt="Image" src="https://github.com/user-attachments/assets/d5bea508-faa0-4398-83e9-662ed57fd82d" />

## 4. Tampilan Form untuk Membuat Transaksi

<img width="1919" height="907" alt="Image" src="https://github.com/user-attachments/assets/9fa1d9f8-c640-443e-91f0-976a6c95a35f" />

## 5. Tampilan Page Inventory

<img width="1919" height="902" alt="Image" src="https://github.com/user-attachments/assets/5589c142-1a79-40a5-a354-823accbc1f80" />

## 6. Tampilan untuk Membuat Pilihan Game Baru

<img width="1919" height="907" alt="Image" src="https://github.com/user-attachments/assets/d2c9b861-9710-4607-8b8b-b8d398405b1d" />

## 7. Tampilan Page Pending

<img width="1919" height="908" alt="Image" src="https://github.com/user-attachments/assets/1593c46a-233e-49ca-bc58-d4d107dff035" />

## 8. Tampilan untuk Mengkonfirmasi Transaksi

<img width="1919" height="911" alt="Image" src="https://github.com/user-attachments/assets/eb65927e-1c42-4c4a-93aa-44ed385a47c3" />

## 9. Tampilan Page Riwayat

<img width="1919" height="905" alt="Image" src="https://github.com/user-attachments/assets/f9805b03-007f-4df1-b440-4652d0d11353" />

## 10. Tampilan ketika Memencet Tombol Menu

<img width="1919" height="906" alt="Image" src="https://github.com/user-attachments/assets/ac8b76da-54d6-4035-8f78-12667b036562" />

## 11. Tampilan Page Profil & Akun

<img width="1919" height="899" alt="Image" src="https://github.com/user-attachments/assets/9d5c4b10-cd39-4fea-b271-10c90f39a214" />

## 12. Tampilan Dark Mode

<img width="1919" height="903" alt="Image" src="https://github.com/user-attachments/assets/b2dad341-029d-4550-9010-89bbc5b03d63" />
