import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/wardrobe_provider.dart';
import '../widgets/clothing_item_card.dart';
import '../models/clothing_item.dart';
import '../utils/responsive_utils.dart';
import '../theme/app_theme.dart';
import 'add_clothing_screen.dart';
import 'clothing_item_detail_screen.dart';

class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({super.key});

  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> 
    with SingleTickerProviderStateMixin {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppTheme.slowAnimation,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AppTheme.defaultCurve,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AppTheme.defaultCurve,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // Responsive App Bar with gradient
          _buildResponsiveAppBar(),

          // Main Content
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Consumer<WardrobeProvider>(
                  builder: (context, provider, child) {
                    return ResponsiveContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 16, tablet: 24, desktop: 32)),
                          
                          // Search and filters
                          _buildResponsiveSearchSection(provider),
                          
                          SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 24, tablet: 32, desktop: 40)),
                          
                          // Statistics section
                          _buildResponsiveStatsSection(provider),
                          
                          SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 24, tablet: 32, desktop: 40)),
                          
                          // Categories filter
                          _buildResponsiveCategoriesFilter(provider),
                          
                          SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 24, tablet: 32, desktop: 40)),
                          
                          // Clothing items grid
                          _buildResponsiveClothingGrid(provider),
                          
                          SizedBox(height: ResponsiveUtils.getBottomNavHeight(context) + 20),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildResponsiveFAB(),
    );
  }

  Widget _buildResponsiveAppBar() {
    return SliverAppBar(
      expandedHeight: ResponsiveUtils.getResponsiveValue(context, mobile: 140, tablet: 180, desktop: 220),
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.8),
              Theme.of(context).colorScheme.secondary,
            ],
          ),
        ),
        child: FlexibleSpaceBar(
          title: Text(
            'My Wardrobe',
            style: GoogleFonts.inter(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, base: 20, tablet: 24, desktop: 28),
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          centerTitle: false,
          titlePadding: EdgeInsets.only(
            left: ResponsiveUtils.getResponsiveValue(context, mobile: 20, tablet: 24, desktop: 32),
            bottom: ResponsiveUtils.getResponsiveValue(context, mobile: 16, tablet: 20, desktop: 24),
          ),
          background: Stack(
            children: [
              // Animated background elements
              _buildBackgroundElement(
                top: -40,
                right: -40,
                size: ResponsiveUtils.getResponsiveValue(context, mobile: 120, tablet: 150, desktop: 180),
                opacity: 0.1,
              ),
              _buildBackgroundElement(
                bottom: -20,
                left: -20,
                size: ResponsiveUtils.getResponsiveValue(context, mobile: 80, tablet: 100, desktop: 120),
                opacity: 0.08,
              ),
              _buildBackgroundElement(
                top: ResponsiveUtils.getResponsiveValue(context, mobile: 40, tablet: 60, desktop: 80),
                left: ResponsiveUtils.getResponsiveValue(context, mobile: 30, tablet: 50, desktop: 70),
                size: ResponsiveUtils.getResponsiveValue(context, mobile: 60, tablet: 80, desktop: 100),
                opacity: 0.06,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundElement({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
    required double opacity,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(opacity),
        ),
      ),
    );
  }

  Widget _buildResponsiveSearchSection(WardrobeProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search bar
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: ResponsiveUtils.getResponsiveElevation(context),
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Search your wardrobe...',
              prefixIcon: Icon(
                Icons.search_rounded,
                color: Colors.grey[400],
                size: ResponsiveUtils.getResponsiveIconSize(context),
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear_rounded,
                        color: Colors.grey[400],
                        size: ResponsiveUtils.getResponsiveIconSize(context),
                      ),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : Icon(
                      Icons.tune_rounded,
                      color: Colors.grey[400],
                      size: ResponsiveUtils.getResponsiveIconSize(context),
                    ),
              border: InputBorder.none,
              contentPadding: ResponsiveUtils.getResponsivePadding(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResponsiveStatsSection(WardrobeProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Wardrobe Overview',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 16, tablet: 20, desktop: 24)),
        ResponsiveWidget(
          mobile: _buildMobileStatsLayout(provider),
          tablet: _buildTabletStatsLayout(provider),
          desktop: _buildDesktopStatsLayout(provider),
        ),
      ],
    );
  }

  Widget _buildMobileStatsLayout(WardrobeProvider provider) {
    final stats = provider.getCategoryStats();
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard('Total Items', provider.totalItems.toString(), Icons.checkroom_rounded, AppTheme.primaryColor),
            ),
            SizedBox(width: ResponsiveUtils.getGridSpacing(context)),
            Expanded(
              child: _buildStatCard('Categories', stats.keys.length.toString(), Icons.category_rounded, AppTheme.secondaryColor),
            ),
          ],
        ),
        SizedBox(height: ResponsiveUtils.getGridSpacing(context)),
        Row(
          children: [
            Expanded(
              child: _buildStatCard('Favorites', '0', Icons.favorite_rounded, AppTheme.warningColor),
            ),
            SizedBox(width: ResponsiveUtils.getGridSpacing(context)),
            Expanded(
              child: _buildStatCard('Recently Added', '${provider.totalItems > 5 ? 5 : provider.totalItems}', Icons.fiber_new_rounded, AppTheme.successColor),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabletStatsLayout(WardrobeProvider provider) {
    final stats = provider.getCategoryStats();
    return Row(
      children: [
        Expanded(
          child: _buildStatCard('Total Items', provider.totalItems.toString(), Icons.checkroom_rounded, AppTheme.primaryColor),
        ),
        SizedBox(width: ResponsiveUtils.getGridSpacing(context)),
        Expanded(
          child: _buildStatCard('Categories', stats.keys.length.toString(), Icons.category_rounded, AppTheme.secondaryColor),
        ),
        SizedBox(width: ResponsiveUtils.getGridSpacing(context)),
        Expanded(
          child: _buildStatCard('Favorites', '0', Icons.favorite_rounded, AppTheme.warningColor),
        ),
      ],
    );
  }

  Widget _buildDesktopStatsLayout(WardrobeProvider provider) {
    final stats = provider.getCategoryStats();
    return Row(
      children: [
        Expanded(
          child: _buildStatCard('Total Items', provider.totalItems.toString(), Icons.checkroom_rounded, AppTheme.primaryColor),
        ),
        SizedBox(width: ResponsiveUtils.getGridSpacing(context)),
        Expanded(
          child: _buildStatCard('Categories', stats.keys.length.toString(), Icons.category_rounded, AppTheme.secondaryColor),
        ),
        SizedBox(width: ResponsiveUtils.getGridSpacing(context)),
        Expanded(
          child: _buildStatCard('Favorites', '0', Icons.favorite_rounded, AppTheme.warningColor),
        ),
        SizedBox(width: ResponsiveUtils.getGridSpacing(context)),
        Expanded(
          child: _buildStatCard('Recently Added', '${provider.totalItems > 5 ? 5 : provider.totalItems}', Icons.fiber_new_rounded, AppTheme.successColor),
        ),
        SizedBox(width: ResponsiveUtils.getGridSpacing(context)),
        Expanded(
          child: _buildStatCard('Most Used', '${stats.isNotEmpty ? stats.values.reduce((a, b) => a > b ? a : b) : 0}', Icons.trending_up_rounded, AppTheme.infoColor),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: ResponsiveUtils.getResponsivePadding(context),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: ResponsiveUtils.getResponsiveElevation(context),
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(ResponsiveUtils.getResponsiveValue(context, mobile: 12, tablet: 16, desktop: 20)),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: ResponsiveUtils.getResponsiveIconSize(context),
            ),
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 12, tablet: 16, desktop: 20)),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[800],
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 4, tablet: 6, desktop: 8)),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveCategoriesFilter(WardrobeProvider provider) {
    final categories = ['All', ...provider.getCategoryStats().keys.toList()];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categories',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 12, tablet: 16, desktop: 20)),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories.map((category) {
              final isSelected = category == provider.selectedCategory;
              return Container(
                margin: EdgeInsets.only(right: ResponsiveUtils.getResponsiveValue(context, mobile: 8, tablet: 12, desktop: 16)),
                child: FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      provider.setSelectedCategory(category);
                    }
                  },
                  backgroundColor: Colors.grey[100],
                  selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                  checkmarkColor: AppTheme.primaryColor,
                  labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isSelected ? AppTheme.primaryColor : Colors.grey[700],
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  side: BorderSide(
                    color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.getResponsiveValue(context, mobile: 12, tablet: 16, desktop: 20),
                    vertical: ResponsiveUtils.getResponsiveValue(context, mobile: 8, tablet: 10, desktop: 12),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildResponsiveClothingGrid(WardrobeProvider provider) {
    List<ClothingItem> filteredItems = provider.clothingItems;
    
    if (_searchQuery.isNotEmpty) {
      filteredItems = filteredItems.where((item) {
        return item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               item.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               item.color.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               item.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()));
      }).toList();
    }

    if (filteredItems.isEmpty) {
      return _buildEmptyState();
    }

    return ResponsiveGrid(
      aspectRatio: ResponsiveUtils.getCardAspectRatio(context),
      spacing: ResponsiveUtils.getGridSpacing(context),
      padding: EdgeInsets.zero,
      children: filteredItems.map((item) {
        return ClothingItemCard(
          item: item,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ClothingItemDetailScreen(item: item),
              ),
            );
          },
          onEdit: () {
            // Add edit functionality
          },
          onDelete: () {
            _showDeleteConfirmation(provider, item);
          },
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: ResponsiveUtils.getResponsivePadding(context),
      margin: EdgeInsets.symmetric(vertical: ResponsiveUtils.getResponsiveValue(context, mobile: 40, tablet: 60, desktop: 80)),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(ResponsiveUtils.getResponsiveValue(context, mobile: 24, tablet: 32, desktop: 40)),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              _searchQuery.isNotEmpty ? Icons.search_off_rounded : Icons.checkroom_rounded,
              size: ResponsiveUtils.getResponsiveValue(context, mobile: 48, tablet: 64, desktop: 80),
              color: Colors.grey[400],
            ),
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 24, tablet: 32, desktop: 40)),
          Text(
            _searchQuery.isNotEmpty ? 'No items found' : 'Your wardrobe is empty',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 12, tablet: 16, desktop: 20)),
          Text(
            _searchQuery.isNotEmpty 
                ? 'Try adjusting your search terms\nor browse all categories'
                : 'Start building your digital wardrobe\nby adding your first clothing item!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 24, tablet: 32, desktop: 40)),
          ElevatedButton.icon(
            onPressed: () {
              if (_searchQuery.isNotEmpty) {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                });
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddClothingScreen(),
                  ),
                );
              }
            },
            icon: Icon(_searchQuery.isNotEmpty ? Icons.clear_rounded : Icons.add_rounded),
            label: Text(_searchQuery.isNotEmpty ? 'Clear Search' : 'Add Clothing'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.getResponsiveValue(context, mobile: 24, tablet: 32, desktop: 40),
                vertical: ResponsiveUtils.getResponsiveValue(context, mobile: 12, tablet: 16, desktop: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveFAB() {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AddClothingScreen(),
          ),
        );
      },
      backgroundColor: AppTheme.primaryColor,
      foregroundColor: Colors.white,
      icon: Icon(
        Icons.add_rounded,
        size: ResponsiveUtils.getResponsiveIconSize(context),
      ),
      label: Text(
        ResponsiveUtils.isMobile(context) ? '' : '',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevation: ResponsiveUtils.getResponsiveElevation(context),
    );
  }

  void _showDeleteConfirmation(WardrobeProvider provider, ClothingItem item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context),
          ),
          title: Text(
            'Delete Item',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to delete "${item.name}" from your wardrobe? This action cannot be undone.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (item.id != null) {
                  provider.deleteClothingItem(item.id!);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${item.name} deleted from wardrobe'),
                      backgroundColor: AppTheme.errorColor,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context),
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
