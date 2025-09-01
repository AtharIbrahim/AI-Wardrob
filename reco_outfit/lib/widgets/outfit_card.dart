import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/outfit.dart';

class OutfitCard extends StatelessWidget {
  final Outfit outfit;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onSave;
  final bool showActions;

  const OutfitCard({
    super.key,
    required this.outfit,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onSave,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with title, AI badge, and actions
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              outfit.name,
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // AI Badge
                          if (outfit.metadata != null && outfit.metadata!.isNotEmpty) ...[
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF6750A4), Color(0xFF7C4DFF)],
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.auto_awesome_rounded,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'AI',
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (showActions && (onEdit != null || onDelete != null || onSave != null))
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_vert_rounded,
                            color: Colors.grey[600],
                            size: 20,
                          ),
                          onSelected: (value) {
                            switch (value) {
                              case 'edit':
                                onEdit?.call();
                                break;
                              case 'delete':
                                onDelete?.call();
                                break;
                              case 'save':
                                onSave?.call();
                                break;
                            }
                          },
                          itemBuilder: (context) => [
                            if (onSave != null)
                              PopupMenuItem(
                                value: 'save',
                                child: Row(
                                  children: [
                                    const Icon(Icons.bookmark_rounded, size: 18, color: Color(0xFF4CAF50)),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Save Outfit',
                                      style: GoogleFonts.inter(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            if (onEdit != null)
                              PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    const Icon(Icons.edit_rounded, size: 18, color: Color(0xFF6750A4)),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Edit',
                                      style: GoogleFonts.inter(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            if (onDelete != null)
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    const Icon(Icons.delete_rounded, size: 18, color: Colors.red),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Delete',
                                      style: GoogleFonts.inter(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Info chips in a modern layout
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildModernChip(
                      Icons.event_rounded,
                      outfit.occasion,
                      const Color(0xFF42A5F5),
                    ),
                    _buildModernChip(
                      Icons.mood_rounded,
                      outfit.mood,
                      const Color(0xFF9C27B0),
                    ),
                    _buildModernChip(
                      Icons.wb_sunny_rounded,
                      outfit.weather,
                      const Color(0xFFFF9800),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Items section with modern grid
                Row(
                  children: [
                    Icon(
                      Icons.checkroom_rounded,
                      size: 18,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Items (${outfit.items.length})',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Items display
                outfit.items.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.checkroom_rounded,
                                size: 32,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No items added',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: outfit.items.length,
                          itemBuilder: (context, index) {
                            final item = outfit.items[index];
                            return Container(
                              width: 80,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[200]!),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF6750A4).withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      _getCategoryIcon(item.category),
                                      size: 24,
                                      color: const Color(0xFF6750A4),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: Text(
                                      item.name,
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey[700],
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                
                // Rating (if available)
                if (outfit.rating != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 18,
                          color: Colors.amber[700],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Rating: ',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                        ...List.generate(5, (index) {
                          return Icon(
                            index < outfit.rating!.round() 
                                ? Icons.star_rounded 
                                : Icons.star_outline_rounded,
                            color: Colors.amber[700],
                            size: 16,
                          );
                        }),
                        const Spacer(),
                        Text(
                          '${outfit.rating!.toStringAsFixed(1)}/5',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.amber[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
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
}
