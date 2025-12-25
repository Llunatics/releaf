# Setup Database untuk Review System

## SQL Schema - Supabase

Jalankan SQL berikut di **Supabase SQL Editor** untuk membuat tabel `book_reviews`:

```sql
-- Create book_reviews table
CREATE TABLE IF NOT EXISTS book_reviews (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  book_id UUID NOT NULL REFERENCES books(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  user_name TEXT NOT NULL,
  rating DECIMAL(2,1) NOT NULL CHECK (rating >= 0 AND rating <= 5),
  comment TEXT,
  user_avatar TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_book_reviews_book_id ON book_reviews(book_id);
CREATE INDEX IF NOT EXISTS idx_book_reviews_user_id ON book_reviews(user_id);
CREATE INDEX IF NOT EXISTS idx_book_reviews_created_at ON book_reviews(created_at DESC);

-- Enable Row Level Security (RLS)
ALTER TABLE book_reviews ENABLE ROW LEVEL SECURITY;

-- Create policies for book_reviews

-- Policy 1: Anyone can read reviews
CREATE POLICY "Anyone can view reviews"
ON book_reviews FOR SELECT
USING (true);

-- Policy 2: Authenticated users can insert reviews
CREATE POLICY "Authenticated users can insert reviews"
ON book_reviews FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- Policy 3: Users can update their own reviews
CREATE POLICY "Users can update own reviews"
ON book_reviews FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Policy 4: Users can delete their own reviews
CREATE POLICY "Users can delete own reviews"
ON book_reviews FOR DELETE
TO authenticated
USING (auth.uid() = user_id);

-- Create trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_book_reviews_updated_at BEFORE UPDATE
ON book_reviews FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Optional: Add function to calculate average rating
CREATE OR REPLACE FUNCTION get_book_average_rating(book_uuid UUID)
RETURNS DECIMAL AS $$
BEGIN
    RETURN (
        SELECT COALESCE(AVG(rating), 0)
        FROM book_reviews
        WHERE book_id = book_uuid
    );
END;
$$ LANGUAGE plpgsql;

-- Optional: Add function to count reviews
CREATE OR REPLACE FUNCTION get_book_review_count(book_uuid UUID)
RETURNS INTEGER AS $$
BEGIN
    RETURN (
        SELECT COUNT(*)
        FROM book_reviews
        WHERE book_id = book_uuid
    );
END;
$$ LANGUAGE plpgsql;
```

## Verifikasi

Setelah menjalankan SQL di atas, verifikasi dengan:

```sql
-- Check table structure
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'book_reviews';

-- Check indexes
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'book_reviews';

-- Check policies
SELECT policyname, cmd, qual
FROM pg_policies
WHERE tablename = 'book_reviews';
```

## Testing Review System

### 1. Test Insert Review
```sql
-- Insert test review (ganti book_id dan user_id dengan yang valid)
INSERT INTO book_reviews (book_id, user_id, user_name, rating, comment)
VALUES (
  'your-book-id-here',
  'your-user-id-here',
  'Test User',
  4.5,
  'Great book! Highly recommended.'
);
```

### 2. Test Get Reviews for a Book
```sql
-- Get all reviews for a specific book
SELECT 
  br.*,
  b.title as book_title
FROM book_reviews br
JOIN books b ON br.book_id = b.id
WHERE br.book_id = 'your-book-id-here'
ORDER BY br.created_at DESC;
```

### 3. Test Average Rating
```sql
-- Calculate average rating for a book
SELECT 
  b.id,
  b.title,
  get_book_average_rating(b.id) as avg_rating,
  get_book_review_count(b.id) as review_count
FROM books b
WHERE b.id = 'your-book-id-here';
```

## Flow Review di Aplikasi

### 1. User Memberikan Review
```dart
// Di profile_screen.dart
// User klik "Terima Pesanan" → Muncul dialog review
showDialog(
  context: context,
  builder: (ctx) => _showAcceptOrderDialog(transaction),
);
```

### 2. Review Tersimpan
```dart
// Di app_state.dart → acceptOrder()
await SupabaseService.instance.addBookReview(
  bookId: item.book.id,
  rating: rating,
  comment: review ?? '',
);
```

### 3. Books Direload
```dart
// Setelah review tersimpan
await refreshBooks(); // Fetch books dengan reviews ter-update
```

### 4. Review Ditampilkan
```dart
// Di product_detail_screen.dart
_buildReviewsSection(isDark, appState)
// Menampilkan semua reviews dari book.reviews
```

## Troubleshooting

### Reviews Tidak Muncul?

**1. Cek apakah tabel sudah dibuat:**
```sql
SELECT * FROM book_reviews LIMIT 1;
```

**2. Cek apakah RLS policy sudah benar:**
```sql
-- Test query sebagai anonymous user
SELECT * FROM book_reviews WHERE book_id = 'test-id';
-- Harus return data (policy "Anyone can view reviews")
```

**3. Cek apakah review tersimpan:**
```sql
-- Lihat semua reviews
SELECT 
  br.id,
  br.user_name,
  br.rating,
  br.comment,
  br.created_at,
  b.title as book_title
FROM book_reviews br
JOIN books b ON br.book_id = b.id
ORDER BY br.created_at DESC
LIMIT 10;
```

**4. Cek query getBooks() di aplikasi:**
- Pastikan menggunakan join: `book_reviews(id, user_id, user_name, rating, comment, created_at, user_avatar)`
- Cek response di console log

**5. Hard refresh aplikasi:**
```bash
flutter clean
flutter pub get
flutter run
```

## Update Existing Books

Jika sudah ada buku tapi tidak ada reviews, tidak masalah. System akan:
- Return empty array untuk `book.reviews`
- Tampilkan "Belum ada review"
- Setelah user pertama review, akan muncul

## Migration dari Transaksi ke Book Reviews

Jika ada reviews lama di tabel `transactions`, bisa migrate dengan:

```sql
-- Migrate existing reviews from transactions to book_reviews
INSERT INTO book_reviews (book_id, user_id, user_name, rating, comment, created_at)
SELECT 
  ti.book_id,
  t.user_id,
  p.full_name as user_name,
  t.rating,
  t.review as comment,
  t.updated_at as created_at
FROM transactions t
JOIN transaction_items ti ON t.id = ti.transaction_id
LEFT JOIN profiles p ON t.user_id = p.id
WHERE t.rating IS NOT NULL
ON CONFLICT DO NOTHING;
```

## Best Practices

1. **Always reload books** setelah review ditambah
2. **Show loading indicator** saat reload
3. **Cache reviews** di local storage (future enhancement)
4. **Validate rating** (1-5 stars only)
5. **Sanitize comment** (remove harmful content)
6. **Rate limiting** (1 review per user per book)

## Next Steps

Future enhancements:
- [ ] Edit review functionality
- [ ] Delete review
- [ ] Reply to review (seller)
- [ ] Helpful/unhelpful votes
- [ ] Report inappropriate review
- [ ] Photo reviews
- [ ] Verified purchase badge
