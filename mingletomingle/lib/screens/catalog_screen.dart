import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/api_controller.dart';
import '../models/product_model.dart';
import '../theme/app_theme.dart';

/// Screen implementing:
/// 1. Dynamic Product ListView Presentation (15pts)
/// 2. Search View Filtering (10pts)
/// 3. Emulated JSON Data Display Viewer (Req 2)
/// 4. HTTP API Controller CRUD Execution (Req 1 & 3)
class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> with SingleTickerProviderStateMixin {
  final ApiController _apiController = ApiController();
  final TextEditingController _searchController = TextEditingController();

  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = false;
  String _selectedCategory = 'All';
  String _searchQuery = '';

  // Tab switcher index: 0 = Service Catalog, 1 = Raw JSON Viewer, 2 = HTTP API Console
  int _activeTab = 0;

  // Categories list for filtering chips
  final List<String> _categories = [
    'All',
    'Subscriptions',
    'Boosts',
    'Date Packages',
    'Virtual Gifts',
    'Coaching',
    'Security',
    'beauty',
  ];

  @override
  void initState() {
    super.initState();
    _fetchCatalog();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// 1. HTTP GET - Trigger catalog fetch
  Future<void> _fetchCatalog() async {
    setState(() => _isLoading = true);
    try {
      final products = await _apiController.getProducts();
      setState(() {
        _allProducts = products;
        _applyFilters();
      });
    } catch (e) {
      _showSnack('Error loading catalog: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Search View Filtering logic
  void _applyFilters() {
    List<Product> list = List.from(_allProducts);

    // Filter by Category
    if (_selectedCategory != 'All') {
      list = list.where((p) => p.category.toLowerCase() == _selectedCategory.toLowerCase()).toList();
    }

    // Filter by Search Query (Title, Description, or Brand)
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      list = list.where((p) {
        return p.title.toLowerCase().contains(q) ||
            p.description.toLowerCase().contains(q) ||
            p.category.toLowerCase().contains(q) ||
            p.brand.toLowerCase().contains(q);
      }).toList();
    }

    _filteredProducts = list;
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      _applyFilters();
    });
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
        ),
        backgroundColor: isError ? Colors.redAccent : AppTheme.primaryPurple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ===========================================================================
  // 2. HTTP POST Dialog: Add New Product
  // ===========================================================================
  void _showAddProductDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final priceCtrl = TextEditingController(text: '9.99');
    String selectedCat = 'Subscriptions';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withAlpha(30),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add_shopping_cart, color: Colors.green, size: 22),
                ),
                const SizedBox(width: 12),
                Text('Add Service (POST)', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(labelText: 'Service / Product Name', hintText: 'e.g. Speed Date Ticket'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descCtrl,
                    decoration: const InputDecoration(labelText: 'Description', hintText: 'Brief description'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: priceCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Price (\$USD)', hintText: '9.99'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCat,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: ['Subscriptions', 'Boosts', 'Date Packages', 'Virtual Gifts', 'Coaching', 'Security']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) => setDialogState(() => selectedCat = val ?? selectedCat),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () async {
                  if (titleCtrl.text.trim().isEmpty) return;
                  final newProd = Product(
                    id: 0,
                    title: titleCtrl.text.trim(),
                    description: descCtrl.text.trim().isEmpty ? 'Exclusive Mingle Service' : descCtrl.text.trim(),
                    price: double.tryParse(priceCtrl.text) ?? 9.99,
                    category: selectedCat,
                    thumbnail: 'https://images.unsplash.com/photo-1518199266791-5375a83190b7?auto=format&fit=crop&w=400&q=80',
                  );
                  Navigator.pop(ctx);
                  setState(() => _isLoading = true);
                  final created = await _apiController.createProduct(newProd);
                  setState(() {
                    _allProducts.insert(0, created);
                    _applyFilters();
                    _isLoading = false;
                  });
                  _showSnack('POST Request Successful: Added "${created.title}" (Status ${ApiController.lastStatusCode})');
                },
                child: Text('Create (POST)', style: GoogleFonts.poppins(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  // ===========================================================================
  // 3. HTTP PUT Dialog: Update Existing Product
  // ===========================================================================
  void _showEditProductDialog(Product product) {
    final titleCtrl = TextEditingController(text: product.title);
    final descCtrl = TextEditingController(text: product.description);
    final priceCtrl = TextEditingController(text: product.price.toStringAsFixed(2));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.edit, color: Colors.blue, size: 22),
            ),
            const SizedBox(width: 12),
            Text('Edit Service (PUT)', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
              const SizedBox(height: 12),
              TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description'), maxLines: 2),
              const SizedBox(height: 12),
              TextField(
                controller: priceCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Price (\$USD)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              final updated = product.copyWith(
                title: titleCtrl.text.trim(),
                description: descCtrl.text.trim(),
                price: double.tryParse(priceCtrl.text) ?? product.price,
              );
              Navigator.pop(ctx);
              setState(() => _isLoading = true);
              final res = await _apiController.updateProduct(product.id, updated);
              setState(() {
                final idx = _allProducts.indexWhere((p) => p.id == product.id);
                if (idx != -1) _allProducts[idx] = res;
                _applyFilters();
                _isLoading = false;
              });
              _showSnack('PUT Request Successful: Updated ID #${product.id} (Status ${ApiController.lastStatusCode})');
            },
            child: Text('Update (PUT)', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 4. HTTP DELETE Dialog: Confirm & Delete Product
  // ===========================================================================
  void _confirmDelete(Product product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Item (DELETE)', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text(
          'Are you sure you want to delete "${product.title}" via HTTP DELETE request?',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isLoading = true);
              await _apiController.deleteProduct(product.id);
              setState(() {
                _allProducts.removeWhere((p) => p.id == product.id);
                _applyFilters();
                _isLoading = false;
              });
              _showSnack('DELETE Request Successful: Removed ID #${product.id} (Status ${ApiController.lastStatusCode})');
            },
            child: Text('Delete (DELETE)', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgMain,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Service Catalog',
          style: GoogleFonts.poppins(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh Catalog (GET)',
            icon: const Icon(Icons.refresh_rounded, color: AppTheme.primaryPurple),
            onPressed: _fetchCatalog,
          ),
          IconButton(
            tooltip: 'Add Product (POST)',
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppTheme.primaryPurple),
            onPressed: _showAddProductDialog,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildSegmentButton(0, 'Products Catalog', Icons.view_list_rounded),
                _buildSegmentButton(1, 'JSON Display', Icons.data_object_rounded),
                _buildSegmentButton(2, 'HTTP Console', Icons.terminal_rounded),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryPurple))
          : IndexedStack(
              index: _activeTab,
              children: [
                _buildCatalogView(),
                _buildJsonDisplayView(),
                _buildHttpConsoleView(),
              ],
            ),
      floatingActionButton: _activeTab == 0
          ? FloatingActionButton.extended(
              backgroundColor: AppTheme.primaryPurple,
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text('New Service', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
              onPressed: _showAddProductDialog,
            )
          : null,
    );
  }

  Widget _buildSegmentButton(int index, String label, IconData icon) {
    final active = _activeTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: Colors.black.withAlpha(15),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: active ? AppTheme.primaryPurple : Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                  color: active ? AppTheme.primaryPurple : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // VIEW 1: DYNAMIC PRODUCT LISTVIEW & SEARCH VIEW FILTERING
  // ===========================================================================
  Widget _buildCatalogView() {
    return Column(
      children: [
        // ── Search View Filtering Bar ────────────────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          color: Colors.white,
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search products or services...',
              hintStyle: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 13),
              prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primaryPurple),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppTheme.borderDefault),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppTheme.borderDefault),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppTheme.primaryPurple, width: 1.5),
              ),
            ),
          ),
        ),

        // ── Category Filter Chips ───────────────────────────────────────────
        Container(
          height: 48,
          color: Colors.white,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            itemCount: _categories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final cat = _categories[i];
              final isSelected = _selectedCategory.toLowerCase() == cat.toLowerCase();
              return GestureDetector(
                onTap: () => _onCategorySelected(cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: isSelected ? AppTheme.brandGradient : null,
                    color: isSelected ? null : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? Colors.transparent : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      cat,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? Colors.white : AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const Divider(height: 1, color: AppTheme.borderDefault),

        // ── Dynamic Product ListView ─────────────────────────────────────────
        Expanded(
          child: _filteredProducts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off_rounded, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 12),
                      Text('No matching services found', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Text('Try modifying your search or category filter', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                  itemCount: _filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = _filteredProducts[index];
                    return _buildProductCard(product);
                  },
                ),
        ),
      ],
    );
  }

  /// Product Card Widget
  Widget _buildProductCard(Product product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.borderDefault),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail Image
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 90,
                height: 90,
                color: const Color(0xFFF1F5F9),
                child: Image.network(
                  product.thumbnail,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => Center(
                    child: Icon(Icons.shopping_bag_outlined, color: Colors.purple.withAlpha(120), size: 36),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Content details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category tag & rating
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryPurple.withAlpha(20),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          product.category.toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryPurple,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                      const SizedBox(width: 2),
                      Text(
                        product.rating.toStringAsFixed(1),
                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Title
                  Text(
                    product.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                  ),

                  // Description
                  Text(
                    product.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 8),

                  // Price and CRUD Actions
                  Row(
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryPurple,
                        ),
                      ),
                      const Spacer(),
                      // Edit Button (PUT)
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.blue),
                        tooltip: 'Update (PUT)',
                        onPressed: () => _showEditProductDialog(product),
                      ),
                      // Delete Button (DELETE)
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                        tooltip: 'Delete (DELETE)',
                        onPressed: () => _confirmDelete(product),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // VIEW 2: EMULATED DISPLAY OF JSON DATA (Req 2)
  // ===========================================================================
  Widget _buildJsonDisplayView() {
    String formattedJson;
    try {
      if (ApiController.lastRawJson.trim().isNotEmpty) {
        final decoded = json.decode(ApiController.lastRawJson);
        formattedJson = const JsonEncoder.withIndent('  ').convert(decoded);
      } else {
        formattedJson = const JsonEncoder.withIndent('  ').convert({
          "endpoint": "https://dummyjson.com/products",
          "status": 200,
          "message": "Execute GET or tap Refresh to load live JSON array payload.",
          "total_items": _allProducts.length,
          "sample": _allProducts.take(3).map((p) => p.toJson()).toList()
        });
      }
    } catch (_) {
      formattedJson = ApiController.lastRawJson;
    }

    return Container(
      color: const Color(0xFF0F172A),
      child: Column(
        children: [
          // Header info bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFF1E293B),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: ApiController.lastStatusCode == 200 || ApiController.lastStatusCode == 201
                        ? Colors.green.withAlpha(50)
                        : Colors.red.withAlpha(50),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: ApiController.lastStatusCode == 200 || ApiController.lastStatusCode == 201
                          ? Colors.greenAccent
                          : Colors.redAccent,
                    ),
                  ),
                  child: Text(
                    'HTTP ${ApiController.lastStatusCode} OK',
                    style: GoogleFonts.jetBrainsMono(
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'GET https://dummyjson.com/products',
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.jetBrainsMono(color: const Color(0xFF94A3B8), fontSize: 11),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white, size: 18),
                  tooltip: 'Reload JSON',
                  onPressed: _fetchCatalog,
                ),
              ],
            ),
          ),

          // JSON Content View
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: SelectableText(
                formattedJson,
                style: GoogleFonts.jetBrainsMono(
                  color: const Color(0xFF38BDF8),
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // VIEW 3: INTERACTIVE HTTP API CONTROLLER CONSOLE (Req 1)
  // ===========================================================================
  Widget _buildHttpConsoleView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HTTP Full API Request Execution (20pts)',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            'Directly triggers controller methods (GET, POST, PUT, DELETE) and records live responses.',
            style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),

          // GET Action Card
          _buildMethodCard(
            method: 'GET',
            color: Colors.blue,
            endpoint: '/products?limit=10',
            description: 'Fetches the full products catalog and maps JSON Array into List<Product>.',
            onTap: () async {
              _fetchCatalog();
              _showSnack('Executing HTTP GET request...');
            },
          ),
          const SizedBox(height: 12),

          // POST Action Card
          _buildMethodCard(
            method: 'POST',
            color: Colors.green,
            endpoint: '/products/add',
            description: 'Submits a JSON payload to create a new product item in the catalog.',
            onTap: _showAddProductDialog,
          ),
          const SizedBox(height: 12),

          // PUT Action Card
          _buildMethodCard(
            method: 'PUT',
            color: Colors.orange,
            endpoint: '/products/{id}',
            description: 'Sends updated fields to modify an existing catalog service item.',
            onTap: () {
              if (_allProducts.isNotEmpty) {
                _showEditProductDialog(_allProducts.first);
              } else {
                _showSnack('No products available to update', isError: true);
              }
            },
          ),
          const SizedBox(height: 12),

          // DELETE Action Card
          _buildMethodCard(
            method: 'DELETE',
            color: Colors.redAccent,
            endpoint: '/products/{id}',
            description: 'Sends a delete command to remove a product item by ID from the catalog.',
            onTap: () {
              if (_allProducts.isNotEmpty) {
                _confirmDelete(_allProducts.first);
              } else {
                _showSnack('No products available to delete', isError: true);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMethodCard({
    required String method,
    required Color color,
    required String endpoint,
    required String description,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderDefault),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withAlpha(80)),
                ),
                child: Text(
                  method,
                  style: GoogleFonts.jetBrainsMono(color: color, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  endpoint,
                  style: GoogleFonts.jetBrainsMono(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: onTap,
                child: Text('Execute', style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(description, style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}
