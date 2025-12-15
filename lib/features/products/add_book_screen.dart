import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/app_state.dart';
import '../../core/models/book.dart';
import '../../core/data/dummy_data.dart';
import '../../core/utils/toast_helper.dart';

class AddBookScreen extends StatefulWidget {
  final Book? bookToEdit;

  const AddBookScreen({super.key, this.bookToEdit});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _originalPriceController;
  late TextEditingController _isbnController;
  late TextEditingController _stockController;
  late TextEditingController _publisherController;
  late TextEditingController _yearController;
  late TextEditingController _pagesController;
  late TextEditingController _imageUrlController;

  String _selectedCategory = 'Fiction';
  BookCondition _selectedCondition = BookCondition.good;
  String _selectedLanguage = 'English';

  bool get _isEditing => widget.bookToEdit != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.bookToEdit?.title);
    _authorController = TextEditingController(text: widget.bookToEdit?.author);
    _descriptionController = TextEditingController(text: widget.bookToEdit?.description);
    _priceController = TextEditingController(text: widget.bookToEdit?.price.toStringAsFixed(0));
    _originalPriceController = TextEditingController(text: widget.bookToEdit?.originalPrice.toStringAsFixed(0));
    _isbnController = TextEditingController(text: widget.bookToEdit?.isbn);
    _stockController = TextEditingController(text: widget.bookToEdit?.stock.toString() ?? '1');
    _publisherController = TextEditingController(text: widget.bookToEdit?.publisher);
    _yearController = TextEditingController(text: widget.bookToEdit?.year.toString() ?? DateTime.now().year.toString());
    _pagesController = TextEditingController(text: widget.bookToEdit?.pages.toString());
    _imageUrlController = TextEditingController(text: widget.bookToEdit?.imageUrl);

    if (widget.bookToEdit != null) {
      _selectedCategory = widget.bookToEdit!.category;
      _selectedCondition = widget.bookToEdit!.condition;
      _selectedLanguage = widget.bookToEdit!.language;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _originalPriceController.dispose();
    _isbnController.dispose();
    _stockController.dispose();
    _publisherController.dispose();
    _yearController.dispose();
    _pagesController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final isDark = appState.isDarkMode;

    final isId = appState.language == 'id';

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(_isEditing 
            ? (isId ? 'Edit Buku' : 'Edit Book')
            : (isId ? 'Tambah Buku Baru' : 'Add New Book')),
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        actions: [
          if (_isEditing)
            IconButton(
              onPressed: _showDeleteConfirmation,
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Cover Section
              Center(
                child: GestureDetector(
                  onTap: () => _showImageOptions(context, isDark),
                  child: Container(
                    width: 150,
                    height: 200,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primaryBlue.withValues(alpha: 0.3),
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadowLight,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: _imageUrlController.text.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.network(
                              _imageUrlController.text,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(isDark, isId),
                            ),
                          )
                        : _buildImagePlaceholder(isDark, isId),
                  ),
                ),
              ).animate().scale(duration: 300.ms),

              const SizedBox(height: 24),

              // Title
              _buildTextField(
                controller: _titleController,
                label: isId ? 'Judul Buku' : 'Book Title',
                hint: isId ? 'Masukkan judul buku' : 'Enter book title',
                validator: (value) => value?.isEmpty ?? true ? (isId ? 'Masukkan judul' : 'Enter title') : null,
                isDark: isDark,
              ).animate().fadeIn(duration: 300.ms, delay: 100.ms),

              const SizedBox(height: 16),

              // Author
              _buildTextField(
                controller: _authorController,
                label: isId ? 'Penulis' : 'Author',
                hint: isId ? 'Masukkan nama penulis' : 'Enter author name',
                validator: (value) => value?.isEmpty ?? true ? (isId ? 'Masukkan penulis' : 'Enter author') : null,
                isDark: isDark,
              ).animate().fadeIn(duration: 300.ms, delay: 150.ms),

              const SizedBox(height: 16),

              // Description
              _buildTextField(
                controller: _descriptionController,
                label: isId ? 'Deskripsi' : 'Description',
                hint: isId ? 'Masukkan deskripsi buku' : 'Enter book description',
                maxLines: 4,
                validator: (value) => value?.isEmpty ?? true ? (isId ? 'Masukkan deskripsi' : 'Enter description') : null,
                isDark: isDark,
              ).animate().fadeIn(duration: 300.ms, delay: 200.ms),

              const SizedBox(height: 16),

              // Category & Condition
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown(
                      label: isId ? 'Kategori' : 'Category',
                      value: _selectedCategory,
                      items: DummyData.categories,
                      onChanged: (value) => setState(() => _selectedCategory = value!),
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildConditionDropdown(isDark, isId),
                  ),
                ],
              ).animate().fadeIn(duration: 300.ms, delay: 250.ms),

              const SizedBox(height: 16),

              // Price & Original Price
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _priceController,
                      label: isId ? 'Harga Jual (Rp)' : 'Selling Price (Rp)',
                      hint: '0',
                      keyboardType: TextInputType.number,
                      validator: (value) => value?.isEmpty ?? true ? (isId ? 'Wajib diisi' : 'Required') : null,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _originalPriceController,
                      label: isId ? 'Harga Asli (Rp)' : 'Original Price (Rp)',
                      hint: '0',
                      keyboardType: TextInputType.number,
                      isDark: isDark,
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 300.ms, delay: 300.ms),

              const SizedBox(height: 16),

              // ISBN & Stock
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _isbnController,
                      label: 'ISBN',
                      hint: '978-0-000-00000-0',
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 100,
                    child: _buildTextField(
                      controller: _stockController,
                      label: isId ? 'Stok' : 'Stock',
                      hint: '1',
                      keyboardType: TextInputType.number,
                      isDark: isDark,
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 300.ms, delay: 350.ms),

              const SizedBox(height: 16),

              // Publisher & Year
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _publisherController,
                      label: isId ? 'Penerbit' : 'Publisher',
                      hint: isId ? 'Nama penerbit' : 'Publisher name',
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 100,
                    child: _buildTextField(
                      controller: _yearController,
                      label: isId ? 'Tahun' : 'Year',
                      hint: '2024',
                      keyboardType: TextInputType.number,
                      isDark: isDark,
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 300.ms, delay: 400.ms),

              const SizedBox(height: 16),

              // Pages & Language
              Row(
                children: [
                  SizedBox(
                    width: 100,
                    child: _buildTextField(
                      controller: _pagesController,
                      label: isId ? 'Halaman' : 'Pages',
                      hint: '0',
                      keyboardType: TextInputType.number,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDropdown(
                      label: isId ? 'Bahasa' : 'Language',
                      value: _selectedLanguage,
                      items: const ['English', 'Indonesian', 'Japanese', 'Korean', 'Chinese', 'Other'],
                      onChanged: (value) => setState(() => _selectedLanguage = value!),
                      isDark: isDark,
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 300.ms, delay: 450.ms),

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _isEditing 
                        ? (isId ? 'Simpan Perubahan' : 'Save Changes')
                        : (isId ? 'Tambah Buku' : 'Add Book'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 300.ms, delay: 500.ms),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isDark,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: isDark ? Colors.white : AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.textPrimaryLight,
          ),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: isDark ? AppColors.surfaceDark : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark 
                  ? AppColors.textTertiaryDark.withValues(alpha: 0.2)
                  : AppColors.textTertiaryLight.withValues(alpha: 0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark 
                  ? AppColors.textTertiaryDark.withValues(alpha: 0.2)
                  : AppColors.textTertiaryLight.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: isDark ? Colors.white : AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark 
                ? AppColors.textTertiaryDark.withValues(alpha: 0.2)
                : AppColors.textTertiaryLight.withValues(alpha: 0.3),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: isDark ? AppColors.surfaceDark : Colors.white,
              items: items.map((item) => DropdownMenuItem(
                value: item,
                child: Text(item),
              )).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConditionDropdown(bool isDark, bool isId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kondisi',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: isDark ? Colors.white : AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark 
                ? AppColors.textTertiaryDark.withValues(alpha: 0.2)
                : AppColors.textTertiaryLight.withValues(alpha: 0.3),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<BookCondition>(
              value: _selectedCondition,
              isExpanded: true,
              dropdownColor: isDark ? AppColors.surfaceDark : Colors.white,
              items: BookCondition.values.map((condition) => DropdownMenuItem(
                value: condition,
                child: Text(condition.localizedLabel(isId)),
              )).toList(),
              onChanged: (value) => setState(() => _selectedCondition = value!),
            ),
          ),
        ),
      ],
    );
  }

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      final appState = AppStateProvider.of(context);
      
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryBlue),
        ),
      );
      
      final book = Book(
        id: widget.bookToEdit?.id ?? const Uuid().v4(),
        title: _titleController.text,
        author: _authorController.text,
        description: _descriptionController.text,
        price: double.tryParse(_priceController.text) ?? 0,
        originalPrice: double.tryParse(_originalPriceController.text) ?? double.tryParse(_priceController.text) ?? 0,
        category: _selectedCategory,
        imageUrl: _imageUrlController.text.isNotEmpty 
            ? _imageUrlController.text 
            : 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=400',
        condition: _selectedCondition,
        isbn: _isbnController.text,
        stock: int.tryParse(_stockController.text) ?? 1,
        publisher: _publisherController.text,
        year: int.tryParse(_yearController.text) ?? DateTime.now().year,
        pages: int.tryParse(_pagesController.text) ?? 0,
        language: _selectedLanguage,
        addedDate: widget.bookToEdit?.addedDate ?? DateTime.now(),
        sellerId: appState.currentUser?.id,
      );

      try {
        if (_isEditing) {
          await appState.updateBook(book);
        } else {
          await appState.addBook(book);
        }
        
        if (!mounted) return;
        Navigator.pop(context); // Close loading
        
        ToastHelper.showSuccess(
          context, 
          _isEditing ? appState.tr('book_updated') : appState.tr('book_added'),
        );

        Navigator.pop(context);
      } catch (e) {
        Navigator.pop(context); // Close loading
        ToastHelper.showError(
          context,
          '${appState.language == 'id' ? 'Gagal' : 'Failed'}: ${e.toString()}',
        );
      }
    }
  }

  void _showDeleteConfirmation() {
    final appState = AppStateProvider.of(context);
    final isDark = appState.isDarkMode;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(appState.tr('delete_book')),
        content: Text('Are you sure you want to delete "${widget.bookToEdit?.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(appState.tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              final dialogContext = context;
              Navigator.pop(dialogContext); // Close dialog
              await appState.deleteBook(widget.bookToEdit!.id);
              if (!mounted) return;
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext); // Go back
                ToastHelper.showSuccess(dialogContext, appState.tr('book_deleted'));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text(appState.tr('delete'), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder(bool isDark, bool isId) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate_rounded,
          size: 48,
          color: AppColors.primaryBlue.withValues(alpha: 0.5),
        ),
        const SizedBox(height: 8),
        Text(
          isId ? 'Tambah Cover' : 'Add Cover',
          style: TextStyle(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }

  void _showImageOptions(BuildContext context, bool isDark) {
    final appState = AppStateProvider.of(context);
    final isId = appState.language == 'id';
    final textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final cardColor = isDark ? const Color(0xFF161B22) : Colors.white;
    final borderColor = isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0);

    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isId ? 'Tambah Cover Buku' : 'Add Book Cover',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            // URL Input
            TextField(
              controller: _imageUrlController,
              style: TextStyle(color: textPrimary),
              decoration: InputDecoration(
                labelText: isId ? 'URL Gambar' : 'Image URL',
                hintText: isId ? 'Tempel URL gambar di sini...' : 'Paste image URL here...',
                prefixIcon: const Icon(Icons.link_rounded),
                filled: true,
                fillColor: isDark ? const Color(0xFF21262D) : const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
                ),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
            const SizedBox(height: 16),
            // Preview if URL is entered
            if (_imageUrlController.text.isNotEmpty)
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: Image.network(
                    _imageUrlController.text,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, color: AppColors.error, size: 32),
                          const SizedBox(height: 8),
                          Text(isId ? 'URL Tidak Valid' : 'Invalid URL', style: TextStyle(color: AppColors.error)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isId ? 'Simpan Cover' : 'Save Cover',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
