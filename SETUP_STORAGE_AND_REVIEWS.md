# Setup Storage Bucket & Review System

## 1. Setup Avatars Storage Bucket

Buka Supabase Dashboard → Storage → Create Bucket

### Create Avatars Bucket:
```
Bucket Name: avatars
Public bucket: YES (centang)
File size limit: 5 MB
Allowed MIME types: image/jpeg, image/png, image/jpg
```

### Set Storage Policies:
```sql
-- Policy untuk upload avatar (hanya user sendiri)
CREATE POLICY "Users can upload their own avatar"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'avatars' 
  AND (storage.foldername(name))[1] = auth.uid()::text
);

-- Policy untuk update avatar (hanya user sendiri)
CREATE POLICY "Users can update their own avatar"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'avatars' 
  AND (storage.foldername(name))[1] = auth.uid()::text
);

-- Policy untuk delete avatar (hanya user sendiri)
CREATE POLICY "Users can delete their own avatar"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'avatars' 
  AND (storage.foldername(name))[1] = auth.uid()::text
);

-- Policy untuk read avatar (public)
CREATE POLICY "Anyone can view avatars"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'avatars');
```

## 2. Setup Book Reviews Table

### Create book_reviews Table:
```sql
-- Create book_reviews table
CREATE TABLE IF NOT EXISTS public.book_reviews (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    book_id UUID NOT NULL REFERENCES public.books(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    user_name TEXT NOT NULL,
    user_avatar TEXT,
    rating DECIMAL(2,1) NOT NULL CHECK (rating >= 0 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Add indexes for better query performance
CREATE INDEX idx_book_reviews_book_id ON public.book_reviews(book_id);
CREATE INDEX idx_book_reviews_user_id ON public.book_reviews(user_id);
CREATE INDEX idx_book_reviews_created_at ON public.book_reviews(created_at DESC);

-- Create composite index for book reviews with rating
CREATE INDEX idx_book_reviews_book_rating ON public.book_reviews(book_id, rating);

-- Trigger untuk update updated_at
CREATE OR REPLACE FUNCTION update_book_reviews_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = timezone('utc'::text, now());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_book_reviews_updated_at
    BEFORE UPDATE ON public.book_reviews
    FOR EACH ROW
    EXECUTE FUNCTION update_book_reviews_updated_at();
```

### Set Row Level Security (RLS):
```sql
-- Enable RLS
ALTER TABLE public.book_reviews ENABLE ROW LEVEL SECURITY;

-- Policy untuk membaca semua reviews (public)
CREATE POLICY "Anyone can view book reviews"
ON public.book_reviews FOR SELECT
TO public
USING (true);

-- Policy untuk insert review (authenticated users)
CREATE POLICY "Authenticated users can create reviews"
ON public.book_reviews FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- Policy untuk update review (hanya pemilik review)
CREATE POLICY "Users can update their own reviews"
ON public.book_reviews FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Policy untuk delete review (hanya pemilik review)
CREATE POLICY "Users can delete their own reviews"
ON public.book_reviews FOR DELETE
TO authenticated
USING (auth.uid() = user_id);
```

## 3. Insert Sample Reviews

```sql
-- Get sample user ID and book IDs first
-- Replace these with actual IDs from your database
INSERT INTO public.book_reviews (book_id, user_id, user_name, user_avatar, rating, comment) VALUES
(
    '00000000-0000-0000-0000-000000000001', -- book_id (replace with actual)
    '00000000-0000-0000-0000-000000000001', -- user_id (replace with actual)
    'John Doe',
    'https://via.placeholder.com/100',
    5.0,
    'Buku yang sangat bagus! Sangat recommended untuk pemula yang ingin belajar pemrograman.'
),
(
    '00000000-0000-0000-0000-000000000001', -- book_id (same book)
    '00000000-0000-0000-0000-000000000002', -- different user_id
    'Jane Smith',
    'https://via.placeholder.com/100',
    4.5,
    'Materi lengkap dan mudah dipahami. Contoh kodenya juga sangat membantu.'
);
```

## 4. Query untuk Testing

### Test Get Books dengan Reviews:
```sql
SELECT 
    books.*,
    profiles.full_name as seller_name,
    profiles.avatar_url as seller_avatar,
    json_agg(
        json_build_object(
            'id', book_reviews.id,
            'user_id', book_reviews.user_id,
            'user_name', book_reviews.user_name,
            'user_avatar', book_reviews.user_avatar,
            'rating', book_reviews.rating,
            'comment', book_reviews.comment,
            'created_at', book_reviews.created_at
        )
    ) FILTER (WHERE book_reviews.id IS NOT NULL) as reviews
FROM books
LEFT JOIN profiles ON books.seller_id = profiles.id
LEFT JOIN book_reviews ON books.id = book_reviews.book_id
GROUP BY books.id, profiles.full_name, profiles.avatar_url;
```

### Test Get Average Rating per Book:
```sql
SELECT 
    books.id,
    books.title,
    COUNT(book_reviews.id) as review_count,
    ROUND(AVG(book_reviews.rating), 1) as avg_rating
FROM books
LEFT JOIN book_reviews ON books.id = book_reviews.book_id
GROUP BY books.id, books.title;
```

### Test Get User's Reviews:
```sql
SELECT 
    book_reviews.*,
    books.title as book_title,
    books.cover_image as book_cover
FROM book_reviews
JOIN books ON book_reviews.book_id = books.id
WHERE book_reviews.user_id = 'YOUR_USER_ID_HERE'
ORDER BY book_reviews.created_at DESC;
```

## 5. Troubleshooting

### Problem: Review tidak muncul
**Solution:**
1. Cek apakah table `book_reviews` sudah dibuat
2. Pastikan RLS policies sudah enable
3. Cek apakah ada data review di database
4. Pastikan query JOIN sudah benar di SupabaseService

### Problem: Upload avatar gagal
**Solution:**
1. Cek apakah bucket `avatars` sudah dibuat
2. Pastikan bucket setting adalah PUBLIC
3. Cek storage policies sudah enable
4. Pastikan user sudah login (authenticated)

### Problem: Review tidak bisa submit
**Solution:**
1. Cek koneksi internet
2. Pastikan user sudah login
3. Cek console log untuk error message
4. Verify RLS policy untuk INSERT review

### Problem: Avatar tidak tampil
**Solution:**
1. Cek URL avatar di database (profiles.avatar_url)
2. Pastikan URL bisa diakses public
3. Cek CachedNetworkImage error widget
4. Verify storage bucket adalah public

## 6. Cara Upload Avatar dari App

1. Buka Profile Screen
2. Tap icon camera di avatar
3. Pilih "Ambil Foto" atau "Pilih dari Galeri"
4. Upload akan otomatis
5. Avatar akan update di profile dan di review

## 7. Cara Submit Review

1. Buka Product Detail
2. Scroll ke bagian Review
3. Tap "Tulis Review"
4. Pilih rating (1-5 bintang)
5. Tulis komentar (opsional)
6. Tap "Kirim Review"
7. Review akan muncul dengan avatar dan nama user

## 8. Verification Steps

**Checklist:**
- [ ] Avatars bucket created and public
- [ ] Storage policies applied
- [ ] book_reviews table created
- [ ] RLS policies enabled
- [ ] Indexes created
- [ ] Sample reviews inserted
- [ ] Test query returns data
- [ ] App can upload avatar
- [ ] App can submit review
- [ ] Review appears with avatar

## 9. Additional Notes

- Avatar max size: 5 MB
- Supported formats: JPG, PNG
- Reviews dapat diedit/delete oleh owner
- Avatar otomatis resize ke 500x500px
- Storage path: `avatars/{user_id}/{filename}`
- Review support rating 0-5 (step 0.5)

## 10. Security Considerations

1. **Storage Security:**
   - User hanya bisa upload/update/delete avatar sendiri
   - Avatar public readable
   - File size limited
   - MIME type restricted

2. **Review Security:**
   - User hanya bisa review jika authenticated
   - User hanya bisa edit/delete review sendiri
   - All reviews public readable
   - Rating range validated (0-5)

3. **Data Validation:**
   - Rating CHECK constraint in database
   - user_id foreign key to auth.users
   - book_id foreign key to books
   - CASCADE delete on book/user deletion
