# Sistem Review Buku di Releaf

## Overview
Sistem review sekarang sudah terintegrasi dengan data buku. Ketika user memberikan review saat menerima pesanan, review tersebut akan otomatis masuk ke halaman detail buku.

## Alur Review

### 1. User Memberikan Review
Ketika pesanan sudah sampai (status: delivered), user bisa:
- Klik "Terima Pesanan" di halaman Profile
- Berikan rating (1-5 bintang) - **WAJIB**
- Tulis komentar review - **OPSIONAL**
- Klik "Terima & Review"

### 2. Review Disimpan
Review akan disimpan di 2 tempat:
- **Transaction**: Review tersimpan di data transaksi
- **Book Reviews**: Review masuk ke tabel `book_reviews` di database

### 3. Review Ditampilkan
Review akan muncul di:
- **Halaman Detail Buku**: Semua review dari berbagai pembeli
- **Halaman Buku yang Dibeli**: Review yang sudah user berikan

## Struktur Database

### Tabel: book_reviews
```sql
CREATE TABLE book_reviews (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  book_id UUID REFERENCES books(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  user_name TEXT NOT NULL,
  rating DECIMAL(2,1) NOT NULL CHECK (rating >= 0 AND rating <= 5),
  comment TEXT,
  user_avatar TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Index untuk performa
CREATE INDEX idx_book_reviews_book_id ON book_reviews(book_id);
CREATE INDEX idx_book_reviews_user_id ON book_reviews(user_id);
```

## Fitur Review

### Rating Rata-rata
- Setiap buku menghitung rating rata-rata dari semua review
- Ditampilkan dengan ikon bintang dan angka (misal: ⭐ 4.5)

### Tampilan Review
- **Avatar**: Inisial nama user
- **Nama User**: Username atau email prefix
- **Rating**: 1-5 bintang
- **Tanggal**: Relatif (Hari ini, Kemarin, X hari lalu, dll)
- **Komentar**: Text review dari user

### Empty State
Jika belum ada review, akan tampil:
- Icon review kosong
- Text "Belum ada review"

## Code Changes

### New Files:
1. **lib/core/models/review.dart**
   - Model untuk data review
   - Method fromJson, toJson, fromSupabase

### Modified Files:
1. **lib/core/models/book.dart**
   - Tambah field `reviews` (List)
   - Method `averageRating` untuk hitung rata-rata

2. **lib/core/services/supabase_service.dart**
   - Method `addBookReview()` - Simpan review ke database
   - Method `getBookReviews()` - Ambil review dari database

3. **lib/core/providers/app_state.dart**
   - Update `acceptOrder()` - Tambah logic untuk simpan review ke buku
   - Reload books setelah review ditambahkan

4. **lib/features/products/product_detail_screen.dart**
   - Tambah `_buildReviewsSection()` - Tampilan section review
   - Method `_formatDate()` - Format tanggal relatif
   - Integrasi ke main layout

## Cara Testing

### 1. Setup Database
Jalankan SQL query di atas di Supabase SQL Editor untuk membuat tabel `book_reviews`

### 2. Test Review Flow
1. Login sebagai buyer
2. Beli sebuah buku
3. Seller update status ke "delivered"
4. Buyer klik "Terima Pesanan" dan beri review
5. Buka halaman detail buku tersebut
6. Review akan muncul di section Reviews

### 3. Verifikasi
- Check tabel `book_reviews` di Supabase
- Pastikan review muncul di halaman detail buku
- Rating rata-rata terupdate
- Review juga tersimpan di transaksi

## Next Steps

### Fitur yang Bisa Ditambahkan:
1. **Edit Review**: User bisa edit review yang sudah diberikan
2. **Delete Review**: User bisa hapus review
3. **Review Images**: Upload foto buku saat review
4. **Helpful Button**: User lain bisa klik "Helpful" di review
5. **Seller Reply**: Seller bisa reply ke review
6. **Filter Reviews**: Filter by rating (5 bintang, 4 bintang, dst)
7. **Sort Reviews**: Sort by terbaru, rating tertinggi, paling helpful

### Improvements:
1. **Pagination**: Load reviews secara bertahap
2. **Validation**: Cek user sudah pernah beli buku atau belum sebelum review
3. **Moderation**: System untuk filter review yang tidak pantas
4. **Notification**: Notif ke seller saat dapat review baru
