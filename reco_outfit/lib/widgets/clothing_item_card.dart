import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import '../models/clothing_item.dart';

class ClothingItemCard extends StatelessWidget {
  final ClothingItem item;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isSelected;

  const ClothingItemCard({
    super.key,
    required this.item,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isSmallPhone = screenWidth < 360;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth;
        final isWideCard = cardWidth > 200;
        
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
            border: isSelected 
              ? Border.all(
                  color: const Color(0xFF6750A4), 
                  width: isTablet ? 3 : 2
                )
              : Border.all(color: Colors.grey[200]!, width: 1),
            boxShadow: [
              BoxShadow(
                color: isSelected 
                  ? const Color(0xFF6750A4).withOpacity(0.25)
                  : Colors.grey.withOpacity(0.15),
                blurRadius: isSelected ? (isTablet ? 20 : 15) : (isTablet ? 15 : 10),
                offset: Offset(0, isSelected ? 8 : 5),
                spreadRadius: isSelected ? 2 : 0,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
              splashColor: const Color(0xFF6750A4).withOpacity(0.1),
              highlightColor: const Color(0xFF6750A4).withOpacity(0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image section with overlay
                  Expanded(
                    flex: isWideCard ? 4 : 3,
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(isTablet ? 20 : 16)
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(isTablet ? 20 : 16)
                            ),
                            child: _buildImage(isTablet: isTablet),
                          ),
                        ),
                        
                        // Gradient overlay for better text readability
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(isTablet ? 20 : 16)
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.1),
                              ],
                            ),
                          ),
                        ),
                        
                        // Selection indicator with animation
                        if (isSelected)
                          Positioned(
                            top: isTablet ? 12 : 8,
                            right: isTablet ? 12 : 8,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: EdgeInsets.all(isTablet ? 6 : 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6750A4),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF6750A4).withOpacity(0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: isTablet ? 20 : 16,
                              ),
                            ),
                          ),
                        
                        // Category badge with better styling
                        Positioned(
                          top: isTablet ? 12 : 8,
                          left: isTablet ? 12 : 8,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 12 : 8, 
                              vertical: isTablet ? 6 : 4
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withOpacity(0.8),
                                  Colors.black.withOpacity(0.6),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getCategoryIcon(item.category),
                                  color: Colors.white,
                                  size: isTablet ? 14 : 10,
                                ),
                                SizedBox(width: isTablet ? 4 : 2),
                                Text(
                                  item.category,
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: isTablet ? 12 : 10,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        // Favorite/Action button (if needed)
                        if (onEdit != null || onDelete != null)
                          Positioned(
                            bottom: isTablet ? 12 : 8,
                            right: isTablet ? 12 : 8,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: PopupMenuButton<String>(
                                icon: Icon(
                                  Icons.more_vert_rounded,
                                  color: Colors.grey[700],
                                  size: isTablet ? 20 : 16,
                                ),
                                onSelected: (value) {
                                  if (value == 'edit' && onEdit != null) onEdit!();
                                  if (value == 'delete' && onDelete != null) onDelete!();
                                },
                                itemBuilder: (context) => [
                                  if (onEdit != null)
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit_rounded, size: 18),
                                          SizedBox(width: 8),
                                          Text('Edit'),
                                        ],
                                      ),
                                    ),
                                  if (onDelete != null)
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete_rounded, size: 18, color: Colors.red),
                                          SizedBox(width: 8),
                                          Text('Delete'),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  // Content section with responsive padding
                  Expanded(
                    flex: isWideCard ? 3 : 2,
                    child: Padding(
                      padding: EdgeInsets.all(isTablet ? 16 : (isSmallPhone ? 8 : 12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title with responsive font
                          Text(
                            item.name,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: isTablet ? 16 : (isSmallPhone ? 12 : 14),
                              color: Colors.grey[800],
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          
                          SizedBox(height: isTablet ? 12 : 8),
                          
                          // Color and season row with better spacing
                          Row(
                            children: [
                              _buildColorIndicator(isTablet: isTablet),
                              SizedBox(width: isTablet ? 8 : 6),
                              Expanded(
                                child: Text(
                                  item.color,
                                  style: GoogleFonts.inter(
                                    color: Colors.grey[600],
                                    fontSize: isTablet ? 13 : (isSmallPhone ? 10 : 11),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              _buildSeasonChip(isTablet: isTablet, isSmallPhone: isSmallPhone),
                            ],
                          ),
                          
                          const Spacer(),
                          
                          // Bottom tags row with better responsive behavior
                          if (item.tags.isNotEmpty && isWideCard)
                            Wrap(
                              spacing: isTablet ? 6 : 4,
                              runSpacing: isTablet ? 4 : 2,
                              children: item.tags.take(isTablet ? 3 : 2).map((tag) => 
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isTablet ? 8 : 6, 
                                    vertical: isTablet ? 4 : 2
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFF6750A4).withOpacity(0.1),
                                        const Color(0xFF7C4DFF).withOpacity(0.1),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(isTablet ? 10 : 8),
                                    border: Border.all(
                                      color: const Color(0xFF6750A4).withOpacity(0.2),
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Text(
                                    tag,
                                    style: GoogleFonts.inter(
                                      fontSize: isTablet ? 11 : (isSmallPhone ? 8 : 9),
                                      color: const Color(0xFF6750A4),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ).toList(),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImage({bool isTablet = false}) {
    // Handle sample/placeholder images
    if (item.imagePath == 'sample_image_path' || item.imagePath.isEmpty) {
      return _buildPlaceholder(isTablet: isTablet);
    }
    
    if (item.imagePath.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: item.imagePath,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildLoadingPlaceholder(isTablet: isTablet),
        errorWidget: (context, url, error) => _buildPlaceholder(isTablet: isTablet),
      );
    } else if (File(item.imagePath).existsSync()) {
      return Image.file(
        File(item.imagePath),
        fit: BoxFit.cover,
      );
    } else {
      return _buildPlaceholder(isTablet: isTablet);
    }
  }

  Widget _buildPlaceholder({bool isTablet = false}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[100]!,
            Colors.grey[200]!,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(isTablet ? 16 : 12),
              decoration: BoxDecoration(
                color: const Color(0xFF6750A4).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getCategoryIcon(item.category),
                size: isTablet ? 40 : 32,
                color: const Color(0xFF6750A4).withOpacity(0.7),
              ),
            ),
            SizedBox(height: isTablet ? 8 : 4),
            Text(
              'No Image',
              style: GoogleFonts.inter(
                fontSize: isTablet ? 12 : 10,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingPlaceholder({bool isTablet = false}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF6750A4).withOpacity(0.05),
            const Color(0xFF7C4DFF).withOpacity(0.05),
          ],
        ),
      ),
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: isTablet ? 3 : 2,
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6750A4)),
        ),
      ),
    );
  }

  Widget _buildColorIndicator({bool isTablet = false}) {
    Color color = _getColorFromString(item.color);
    return Container(
      width: isTablet ? 18 : 14,
      height: isTablet ? 18 : 14,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: color == Colors.white ? Colors.grey[300]! : Colors.transparent,
          width: isTablet ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.4),
            blurRadius: isTablet ? 4 : 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }

  Widget _buildSeasonChip({bool isTablet = false, bool isSmallPhone = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 10 : (isSmallPhone ? 5 : 6), 
        vertical: isTablet ? 4 : 2
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getSeasonColor(item.season).withOpacity(0.15),
            _getSeasonColor(item.season).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
        border: Border.all(
          color: _getSeasonColor(item.season).withOpacity(0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _getSeasonColor(item.season).withOpacity(0.2),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getSeasonIcon(item.season),
            size: isTablet ? 12 : (isSmallPhone ? 8 : 10),
            color: _getSeasonColor(item.season),
          ),
          if (!isSmallPhone) ...[
            SizedBox(width: isTablet ? 4 : 2),
            Text(
              item.season,
              style: GoogleFonts.inter(
                color: _getSeasonColor(item.season),
                fontSize: isTablet ? 11 : 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'top':
      case 'shirt':
      case 't-shirt':
        return Icons.checkroom_rounded;
      case 'bottom':
      case 'pants':
      case 'jeans':
        return Icons.dry_cleaning_rounded;
      case 'shoes':
        return Icons.shop;
      case 'accessories':
        return Icons.watch_rounded;
      case 'dress':
        return Icons.woman_rounded;
      case 'jacket':
      case 'coat':
        return Icons.layers_rounded;
      default:
        return Icons.checkroom_rounded;
    }
  }

  IconData _getSeasonIcon(String season) {
    switch (season.toLowerCase()) {
      case 'spring':
        return Icons.local_florist_rounded;
      case 'summer':
        return Icons.wb_sunny_rounded;
      case 'autumn':
      case 'fall':
        return Icons.nature_rounded;
      case 'winter':
        return Icons.ac_unit_rounded;
      case 'all':
      case 'year-round':
        return Icons.public_rounded;
      default:
        return Icons.calendar_today_rounded;
    }
  }

  Color _getColorFromString(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      case 'gray':
      case 'grey':
        return Colors.grey;
      case 'navy':
        return const Color(0xFF000080);
      case 'brown':
        return Colors.brown;
      case 'beige':
        return const Color(0xFFF5F5DC);
      case 'red':
        return Colors.red;
      case 'pink':
        return Colors.pink;
      case 'orange':
        return Colors.orange;
      case 'yellow':
        return Colors.yellow;
      case 'green':
        return Colors.green;
      case 'blue':
        return Colors.blue;
      case 'purple':
        return Colors.purple;
      case 'maroon':
        return const Color(0xFF800000);
      case 'teal':
        return Colors.teal;
      case 'cyan':
        return Colors.cyan;
      case 'lime':
        return Colors.lime;
      case 'indigo':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  Color _getSeasonColor(String season) {
    switch (season.toLowerCase()) {
      case 'spring':
        return const Color(0xFF4CAF50);
      case 'summer':
        return const Color(0xFFFF9800);
      case 'autumn':
      case 'fall':
        return const Color(0xFF795548);
      case 'winter':
        return const Color(0xFF2196F3);
      case 'all':
      case 'year-round':
        return const Color(0xFF9C27B0);
      default:
        return Colors.grey;
    }
  }
}
