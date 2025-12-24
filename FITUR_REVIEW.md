# Fitur Konfirmasi Penerimaan Barang & Review

## Overview
Fitur ini memungkinkan pembeli untuk mengkonfirmasi penerimaan barang dan memberikan review setelah pesanan diterima. Sistem mendukung dua cara konfirmasi:
1. **Manual** - Pembeli menekan tombol "Terima Pesanan"
2. **Auto-Accept** - Otomatis dikonfirmasi setelah 1 hari barang sampai

## Status Transaksi

### Status Flow
```
Pending → Processing → Shipped → Delivered → Completed
```

- **Pending**: Menunggu konfirmasi pembayaran
- **Processing**: Pesanan sedang diproses
- **Shipped**: Pesanan dalam pengiriman
- **Delivered**: Barang sudah sampai, menunggu konfirmasi pembeli
- **Completed**: Pesanan selesai (barang diterima & dikonfirmasi)
- **Cancelled**: Pesanan dibatalkan

### Status Delivered
Status baru yang menandakan:
- Barang sudah sampai ke pembeli
- Menunggu konfirmasi penerimaan dari pembeli
- Auto-accept akan terjadi dalam 1 hari jika tidak dikonfirmasi manual

## Fitur Utama

### 1. Konfirmasi Manual
Pembeli dapat mengkonfirmasi penerimaan barang dengan:
- Klik tombol **"Terima Pesanan"** pada order dengan status `Delivered`
- Memberikan rating (1-5 bintang)
- Menulis review (opsional)
- Sistem akan update status menjadi `Completed`

### 2. Auto-Accept (1 Hari)
- Saat status berubah menjadi `Delivered`, sistem mencatat:
  - `deliveredDate`: Tanggal barang sampai
  - `autoAcceptDate`: 1 hari setelah deliveredDate
- Sistem akan otomatis mengecek dan accept order yang melewati autoAcceptDate
- Check dilakukan saat:
  - User membuka Profile Screen
  - App startup (bisa ditambahkan)

### 3. Review & Rating
Setelah order di-accept (manual atau auto), pembeli dapat:
- Melihat review yang sudah diberikan
- Rating ditampilkan dengan bintang
- Review text ditampilkan di detail order

## Model Changes

### BookTransaction Model
Tambahan field baru:
```dart
final DateTime? deliveredDate;     // Tanggal barang sampai
final DateTime? autoAcceptDate;    // Tanggal auto-accept (deliveredDate + 1 hari)
final String? review;              // Review dari pembeli
final double? rating;              // Rating 1-5
```

Helper methods:
```dart
bool get canAutoAccept             // Cek apakah bisa auto-accept
bool get needsConfirmation         // Cek apakah perlu konfirmasi
```

## API Methods

### AppState
```dart
// Accept order dengan review
Future<void> acceptOrder(String transactionId, {String? review, double? rating})

// Tandai sebagai delivered (untuk testing atau system)
Future<void> markAsDelivered(String transactionId)

// Check dan auto-accept orders
Future<void> checkAutoAcceptOrders()
```

### SupabaseService
```dart
// Update status transaksi
Future<void> updateTransactionStatus({
  required String transactionId,
  required String status,
  String? review,
  double? rating,
  DateTime? deliveredDate,
  DateTime? autoAcceptDate,
})
```

## UI/UX

### Profile Screen - My Orders

#### Status Shipped
- Tombol: **"Tandai Sudah Sampai"** (untuk testing)
- Action: Mark order sebagai delivered

#### Status Delivered
- Tombol: **"Terima Pesanan"** (hijau, dengan icon check)
- Info: Menampilkan tanggal auto-accept
- Action: Buka dialog konfirmasi

#### Status Completed dengan Review
- Tampilan review dalam card
- Rating dengan bintang kuning
- Text review

### Dialog Konfirmasi
- Title: "Konfirmasi Penerimaan"
- Rating selector: 5 bintang interaktif
- Text field: Review (opsional)
- Buttons: "Batal" dan "Konfirmasi"

## Testing Guide

### 1. Testing Manual Accept

1. Login ke aplikasi
2. Buka Profile → My Orders
3. Cari order dengan status "Shipped"
4. Klik tombol **"Tandai Sudah Sampai"**
5. Status berubah menjadi "Delivered"
6. Lihat tanggal auto-accept di bawah tombol
7. Klik tombol **"Terima Pesanan"**
8. Berikan rating dan review
9. Klik "Konfirmasi"
10. Status berubah menjadi "Completed"
11. Review ditampilkan di order card

### 2. Testing Auto-Accept

1. Gunakan order dengan status "Delivered"
2. Pastikan `deliveredDate` sudah lebih dari 1 hari yang lalu
3. Tutup dan buka kembali Profile screen
4. Order otomatis berubah menjadi "Completed"

### 3. Dummy Data untuk Testing

File `dummy_data.dart` sudah memiliki:
- `TRX008`: Order dengan status `Delivered`
- Delivered 12 jam yang lalu
- Auto-accept 12 jam lagi

## Database Schema (Supabase)

Tambahkan kolom baru di tabel `transactions`:

```sql
ALTER TABLE transactions 
ADD COLUMN delivered_date TIMESTAMP,
ADD COLUMN auto_accept_date TIMESTAMP,
ADD COLUMN review TEXT,
ADD COLUMN rating DECIMAL(2,1);
```

## Future Improvements

1. **Push Notification**
   - Notif saat barang delivered
   - Reminder sebelum auto-accept

2. **Review Management**
   - Edit review setelah submit
   - Upload foto review
   - Reply dari penjual

3. **Advanced Auto-Accept**
   - Custom duration per kategori
   - Pause auto-accept (extend time)

4. **Analytics**
   - Average rating per seller
   - Review statistics
   - Auto-accept vs manual ratio

5. **Seller Response**
   - Penjual bisa balas review
   - Dispute resolution

## Notes

- Auto-accept check saat ini hanya di Profile screen
- Bisa ditambahkan background task untuk check otomatis
- Review tidak bisa diedit setelah submit
- Rating default adalah 5 bintang
- Review bersifat opsional, rating wajib

---

**Implementasi selesai!** ✅

Fitur sudah fully functional dengan:
- ✅ Status Delivered
- ✅ Manual Accept dengan Review
- ✅ Auto-Accept setelah 1 hari
- ✅ UI lengkap di Profile Screen
- ✅ Integration dengan Supabase
- ✅ Testing data tersedia
