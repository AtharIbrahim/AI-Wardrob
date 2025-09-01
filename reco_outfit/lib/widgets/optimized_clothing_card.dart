import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import '../models/clothing_item.dart';
import '../theme/app_theme.dart';
import '../utils/responsive_utils.dart';

class OptimizedClothingItemCard extends StatelessWidget {
  final ClothingItem item;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;
  final bool showShimmer;

  const OptimizedClothingItemCard({
    super.key,
    required this.item,
    this.onTap,
    this.onLongPress,
    this.isSelected = false,
    this.showShimmer = false,
  });

  @override
  Widget build(BuildContext context) {
    if (showShimmer) {
      return _buildShimmerCard(context);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedContainer(
          duration: AppTheme.fastAnimation,
          curve: AppTheme.defaultCurve,
          child: Material(
            elevation: isSelected ? 8 : 2,
            borderRadius: BorderRadius.circular(16),
            shadowColor: isSelected 
                ? AppTheme.primaryColor.withOpacity(0.3)
                : Colors.black.withOpacity(0.1),
            child: InkWell(
              onTap: onTap,
              onLongPress: onLongPress,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: isSelected 
                      ? Border.all(color: AppTheme.primaryColor, width: 2)
                      : null,
                  color: Theme.of(context).cardColor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImageSection(context, constraints),
                    _buildInfoSection(context, constraints),
                  ],
                ),
              ),
            ),
          ),
        ).animate(delay: const Duration(milliseconds: 100))
          .fadeIn(duration: AppTheme.normalAnimation)
          .slideY(begin: 0.1, end: 0);
      },
    );
  }

  Widget _buildImageSection(BuildContext context, BoxConstraints constraints) {
    final imageHeight = constraints.maxHeight * 0.6;
    
    return Container(
      height: imageHeight,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        color: _getCategoryColor().withOpacity(0.1),
      ),
      child: Stack(
        children: [
          // Image placeholder or actual image
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _getCategoryColor().withOpacity(0.2),
                  _getCategoryColor().withOpacity(0.1),
                ],
              ),
            ),
            child: Center(
              child: Icon(
                _getCategoryIcon(),
                size: constraints.maxWidth * 0.3,
                color: _getCategoryColor(),
              ),
            ),
          ),
          
          // Category badge
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getCategoryColor(),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                item.category,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: constraints.maxWidth < 150 ? 10 : 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          
          // Season indicator
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                _getSeasonIcon(),
                size: 16,
                color: _getSeasonColor(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, BoxConstraints constraints) {
    final infoHeight = constraints.maxHeight * 0.4;
    
    return Container(
      height: infoHeight,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Item name
          Flexible(
            child: Text(
              item.name,
              style: TextStyle(
                fontSize: constraints.maxWidth < 150 ? 14 : 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          const SizedBox(height: 4),
          
          // Color indicator
          Flexible(
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getColorFromName(item.color),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[300]!, width: 0.5),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item.color,
                    style: TextStyle(
                      fontSize: constraints.maxWidth < 150 ? 11 : 12,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          
          // Tags (if space allows)
          if (constraints.maxHeight > 180 && item.tags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Wrap(
                spacing: 4,
                children: item.tags.take(2).map((tag) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).chipTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontSize: 9,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                )).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildShimmerCard(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.grey[300],
        ),
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 80,
                      height: 12,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor() {
    switch (item.category) {
      case ClothingCategory.tops:
        return const Color(0xFF4CAF50);
      case ClothingCategory.bottoms:
        return const Color(0xFF2196F3);
      case ClothingCategory.dresses:
        return const Color(0xFF9C27B0);
      case ClothingCategory.outerwear:
        return const Color(0xFF795548);
      case ClothingCategory.shoes:
        return const Color(0xFF607D8B);
      case ClothingCategory.accessories:
        return const Color(0xFFFF9800);
      default:
        return AppTheme.primaryColor;
    }
  }

  IconData _getCategoryIcon() {
    switch (item.category) {
      case ClothingCategory.tops:
        return Icons.checkroom;
      case ClothingCategory.bottoms:
        return Icons.collections_outlined;
      case ClothingCategory.dresses:
        return Icons.woman;
      case ClothingCategory.outerwear:
        return Icons.snowing;
      case ClothingCategory.shoes:
        return Icons.toys;
      case ClothingCategory.accessories:
        return Icons.watch;
      default:
        return Icons.checkroom;
    }
  }

  Color _getSeasonColor() {
    switch (item.season) {
      case Season.spring:
        return const Color(0xFF4CAF50);
      case Season.summer:
        return const Color(0xFFFF9800);
      case Season.autumn:
        return const Color(0xFF795548);
      case Season.winter:
        return const Color(0xFF2196F3);
      default:
        return AppTheme.primaryColor;
    }
  }

  IconData _getSeasonIcon() {
    switch (item.season) {
      case Season.spring:
        return Icons.local_florist;
      case Season.summer:
        return Icons.wb_sunny;
      case Season.autumn:
        return Icons.eco;
      case Season.winter:
        return Icons.ac_unit;
      default:
        return Icons.all_inclusive;
    }
  }

  Color _getColorFromName(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'pink':
        return Colors.pink;
      case 'brown':
        return Colors.brown;
      case 'grey':
      case 'gray':
        return Colors.grey;
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      default:
        return Colors.grey;
    }
  }
}

// Optimized grid widget for better performance
class OptimizedClothingGrid extends StatelessWidget {
  final List<ClothingItem> items;
  final Function(ClothingItem)? onItemTap;
  final Function(ClothingItem)? onItemLongPress;
  final Set<int> selectedItems;
  final bool isLoading;
  final ScrollController? scrollController;

  const OptimizedClothingGrid({
    super.key,
    required this.items,
    this.onItemTap,
    this.onItemLongPress,
    this.selectedItems = const {},
    this.isLoading = false,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);
        final aspectRatio = _getAspectRatio(constraints.maxWidth);
        
        if (isLoading) {
          return _buildLoadingGrid(crossAxisCount, aspectRatio);
        }

        if (items.isEmpty) {
          return _buildEmptyState(context);
        }

        return GridView.builder(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: aspectRatio,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return OptimizedClothingItemCard(
              item: item,
              isSelected: selectedItems.contains(item.id),
              onTap: () => onItemTap?.call(item),
              onLongPress: () => onItemLongPress?.call(item),
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingGrid(int crossAxisCount, double aspectRatio) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: aspectRatio,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return OptimizedClothingItemCard(
          item: ClothingItem(
            name: '',
            category: '',
            color: '',
            season: '',
            imagePath: '',
            tags: const [],
            createdAt: DateTime.now(),
          ),
          showShimmer: true,
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.checkroom_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No clothing items found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some clothes to your wardrobe to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  int _getCrossAxisCount(double width) {
    if (width < 600) {
      return 2; // Mobile
    } else if (width < 900) {
      return 3; // Tablet
    } else if (width < 1200) {
      return 4; // Small desktop
    } else {
      return 5; // Large desktop
    }
  }

  double _getAspectRatio(double width) {
    if (width < 600) {
      return 0.75; // Mobile - taller cards
    } else if (width < 900) {
      return 0.8; // Tablet
    } else {
      return 0.85; // Desktop - slightly wider cards
    }
  }
}
