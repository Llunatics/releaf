# 📦 Cara Mengubah Status Pesanan (Shipping)

## 🔄 Flow Status Pesanan

```
PENDING → PROCESSING → SHIPPED → DELIVERED → COMPLETED
                ↓
            CANCELLED
```

## 📋 Cara Mengubah Status

### Metode 1: Melalui UI (Recommended)

#### 1️⃣ Buka Profile → My Orders
- Klik icon Profile di bottom navigation
- Pilih "Orders" (akan menampilkan daftar pesanan)

#### 2️⃣ Pilih Order yang Ingin Diubah
- Cari order dengan status yang ingin diubah
- Order akan menampilkan tombol **"Update Status"**

#### 3️⃣ Klik "Update Status"
- Dialog akan muncul dengan pilihan status yang tersedia
- Status yang ditampilkan tergantung status saat ini:

   **Dari PENDING:**
   - ✅ Processing (Pesanan sedang diproses)
   - ❌ Cancelled (Batalkan pesanan)

   **Dari PROCESSING:**
   - 🚚 Shipped (Pesanan dikirim)
   - ❌ Cancelled (Batalkan pesanan)

   **Dari SHIPPED:**
   - 🏠 Delivered (Pesanan sampai)

   **Dari DELIVERED:**
   - ⭐ Completed (Hanya bisa dari buyer via "Terima Pesanan")

#### 4️⃣ Pilih Status Baru
- Klik pada status yang diinginkan
- Konfirmasi akan muncul
- Status akan diupdate otomatis

### Metode 2: Programmatically (For Testing/Admin)

```dart
// Update ke status tertentu
await appState.updateOrderStatus(transactionId, TransactionStatus.shipped);

// Atau langsung mark as delivered
await appState.markAsDelivered(transactionId);
```

## 🎯 Status dan Fungsinya

### 1. **PENDING** 🟡
- **Deskripsi**: Menunggu konfirmasi pembayaran
- **Warna**: Kuning/Orange
- **Action Tersedia**: 
  - → Processing (Proses pesanan)
  - → Cancelled (Batalkan)

### 2. **PROCESSING** 🔵
- **Deskripsi**: Pesanan sedang diproses/dikemas
- **Warna**: Biru
- **Action Tersedia**: 
  - → Shipped (Kirim pesanan)
  - → Cancelled (Batalkan)

### 3. **SHIPPED** 🚚
- **Deskripsi**: Pesanan dalam pengiriman
- **Warna**: Biru
- **Action Tersedia**: 
  - → Delivered (Tandai sudah sampai)

### 4. **DELIVERED** 🏠
- **Deskripsi**: Barang sudah sampai, menunggu konfirmasi buyer
- **Warna**: Ungu
- **Auto-Accept**: 1 hari setelah delivered
- **Action Tersedia**: 
  - ⭐ Accept Order (Hanya buyer)

### 5. **COMPLETED** ✅
- **Deskripsi**: Pesanan selesai & dikonfirmasi
- **Warna**: Hijau
- **Review**: Buyer bisa kasih review & rating

### 6. **CANCELLED** ❌
- **Deskripsi**: Pesanan dibatalkan
- **Warna**: Merah
- **Final Status**: Tidak bisa diubah lagi

## 🎬 Tutorial Lengkap (Step by Step)

### Skenario: Mengubah Order dari PENDING → SHIPPED

#### Step 1: Login & Buka Orders
```
1. Buka aplikasi
2. Klik tab "Profile" di bawah
3. Klik card "Orders" atau icon list
```

#### Step 2: Ubah PENDING → PROCESSING
```
1. Cari order dengan status "PENDING" (warna kuning)
2. Klik tombol "Update Status"
3. Pilih "Processing" (icon: 📦)
4. Notifikasi muncul: "Status updated to Processing"
```

#### Step 3: Ubah PROCESSING → SHIPPED
```
1. Order sekarang berstatus "PROCESSING" (warna biru)
2. Klik tombol "Update Status" lagi
3. Pilih "Shipped" (icon: 🚚)
4. Notifikasi muncul: "Status updated to Shipped"
```

#### Step 4: Ubah SHIPPED → DELIVERED
```
1. Order sekarang berstatus "SHIPPED"
2. Klik tombol "Update Status"
3. Pilih "Delivered" (icon: 🏠)
4. System akan set auto-accept dalam 1 hari
```

#### Step 5: Buyer Konfirmasi (DELIVERED → COMPLETED)
```
1. Buyer klik "Terima Pesanan"
2. Buyer kasih rating & review
3. Status berubah jadi "COMPLETED" ✅
```

## 🔧 Requirements untuk Update Status

### Yang Dibutuhkan:
1. **User harus login** ✅
2. **Order harus ada** ✅
3. **Status harus valid** (sesuai flow)
4. **Koneksi internet** (untuk sync ke database)

### Yang TIDAK Dibutuhkan:
- ❌ Tracking number (opsional)
- ❌ Alamat (sudah ada saat checkout)
- ❌ Konfirmasi tambahan
- ❌ Upload bukti kirim

## 📱 UI Components

### Tombol "Update Status"
- Muncul di setiap order card
- Hanya untuk status: pending, processing, shipped
- Tidak muncul jika completed/cancelled
- Warna: Biru outline

### Dialog Update Status
- Title: "Update Status"
- Subtitle: Order ID
- Current status ditampilkan
- List pilihan status baru
- Setiap pilihan ada icon + description

### Notifikasi Success
- Snackbar hijau
- Icon check circle
- Text: "Status updated to [Status]"
- Auto dismiss dalam 3 detik

## 🗄️ Database (Supabase)

### Update Query:
```sql
UPDATE transactions 
SET 
  status = 'shipped',
  updated_at = NOW()
WHERE id = 'transaction_id';
```

### Untuk Delivered:
```sql
UPDATE transactions 
SET 
  status = 'delivered',
  delivered_date = NOW(),
  auto_accept_date = NOW() + INTERVAL '1 day',
  updated_at = NOW()
WHERE id = 'transaction_id';
```

## 🐛 Troubleshooting

### Problem: Tombol "Update Status" tidak muncul
**Solusi:**
- Pastikan order belum completed/cancelled
- Refresh halaman
- Check koneksi internet

### Problem: Status tidak berubah
**Solusi:**
- Check console untuk error
- Pastikan user masih login
- Restart aplikasi

### Problem: Error saat update
**Solusi:**
- Pastikan order ID valid
- Check database connection
- Lihat log error di console

## 🎯 Best Practices

### Untuk Seller:
1. ✅ Update status secara berkala
2. ✅ Langsung update ke "Shipped" setelah kirim
3. ✅ Kasih tracking number (jika ada)
4. ✅ Tandai "Delivered" setelah sampai

### Untuk Buyer:
1. ✅ Segera konfirmasi penerimaan barang
2. ✅ Kasih review yang jujur
3. ✅ Rating sesuai kualitas produk
4. ✅ Laporkan jika ada masalah

## 📊 Tracking & Monitoring

### Check Status Order:
```
Profile → Orders → Lihat status badge
```

### History Status Changes:
- Setiap perubahan tercatat
- Timestamp disimpan di database
- Bisa lihat updated_at field

## 🚀 Quick Commands (Developer)

```dart
// Update ke processing
appState.updateOrderStatus(orderId, TransactionStatus.processing);

// Update ke shipped
appState.updateOrderStatus(orderId, TransactionStatus.shipped);

// Update ke delivered (auto-set tanggal)
appState.updateOrderStatus(orderId, TransactionStatus.delivered);

// Atau lebih simple:
appState.markAsDelivered(orderId);
```

---

## ✨ Summary

**Cara Paling Mudah:**
1. Buka Profile → My Orders
2. Klik "Update Status" di order
3. Pilih status baru (Processing/Shipped/Delivered)
4. Done! ✅

**Flow Normal:**
PENDING → PROCESSING → SHIPPED → DELIVERED → COMPLETED

**Waktu Auto-Accept:**
1 hari setelah status DELIVERED

**Review & Rating:**
Setelah status COMPLETED

---

Sekarang Anda bisa mengubah status pesanan dengan mudah! 🎉
