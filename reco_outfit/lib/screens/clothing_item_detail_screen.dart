import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import '../models/clothing_item.dart';
import '../providers/wardrobe_provider.dart';

class ClothingItemDetailScreen extends StatelessWidget {
  final ClothingItem item;

  const ClothingItemDetailScreen({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          item.name,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor ?? Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.edit,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () => _editItem(context),
          ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onSelected: (value) {
              if (value == 'delete') {
                _deleteItem(context);
              } else if (value == 'duplicate') {
                _duplicateItem(context);
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'duplicate',
                child: Row(
                  children: [
                    Icon(Icons.copy, color: Theme.of(context).colorScheme.onSurface),
                    const SizedBox(width: 8),
                    Text(
                      'Duplicate',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    ),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                    const SizedBox(width: 8),
                    Text(
                      'Delete', 
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth > 600;
          
          if (isTablet) {
            return _buildTabletLayout(context);
          } else {
            return _buildMobileLayout(context);
          }
        },
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          _buildImageSection(context),
          
          // Details Section
          _buildDetailsSection(context),
          
          // Actions Section
          _buildActionsSection(context),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Row(
      children: [
        // Image Section (Left Half)
        Expanded(
          flex: 1,
          child: _buildImageSection(context),
        ),
        
        // Details Section (Right Half)
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailsContent(context),
                const SizedBox(height: 24),
                _buildActionsSection(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      width: double.infinity,
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Stack(
        children: [
          Center(child: _buildImage(context)),
          
          // Favorite/Heart Button
          Positioned(
            top: 16,
            right: 16,
            child: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.9),
              child: IconButton(
                icon: Icon(
                  Icons.favorite_border,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                onPressed: () => _toggleFavorite(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: _buildDetailsContent(context),
    );
  }

  Widget _buildDetailsContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name and Category
        Text(
          item.name,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            item.category,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Properties Grid
        _buildPropertyGrid(context),
        
        const SizedBox(height: 24),
        
        // Tags
        if (item.tags.isNotEmpty) ...[
          Text(
            'Tags',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: item.tags.map((tag) => Chip(
              label: Text(tag),
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              labelStyle: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            )).toList(),
          ),
          const SizedBox(height: 24),
        ],
        
        // Additional Info
        _buildAdditionalInfo(context),
      ],
    );
  }

  Widget _buildPropertyGrid(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildPropertyCard(
                context,
                'Color',
                item.color,
                Icons.palette,
                _getColorFromString(item.color),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPropertyCard(
                context,
                'Season',
                item.season,
                Icons.wb_sunny,
                _getSeasonColor(item.season),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildPropertyCard(
                context,
                'Added',
                _formatDate(item.createdAt),
                Icons.calendar_today,
                Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPropertyCard(
                context,
                'Outfits',
                '${_getOutfitCount(context)} outfits',
                Icons.style,
                Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPropertyCard(BuildContext context, String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfo(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Additional Information',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            _buildInfoRow(context, 'Item ID', item.id?.toString() ?? 'N/A'),
            _buildInfoRow(context, 'Added on', _formatFullDate(item.createdAt)),
            if (item.imagePath.isNotEmpty && item.imagePath != 'sample_image_path')
              _buildInfoRow(context, 'Image Path', item.imagePath, isPath: true),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value, {bool isPath = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: isPath ? 12 : 14,
                fontFamily: isPath ? 'monospace' : null,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Primary Actions
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _editItem(context),
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Item'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _findMatchingOutfits(context),
                  icon: const Icon(Icons.search),
                  label: const Text('Find Outfits'),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Secondary Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _duplicateItem(context),
                  icon: const Icon(Icons.copy),
                  label: const Text('Duplicate'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _deleteItem(context),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    if (item.imagePath == 'sample_image_path' || item.imagePath.isEmpty) {
      return _buildPlaceholder(context);
    }
    
    if (item.imagePath.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: item.imagePath,
        fit: BoxFit.contain,
        height: double.infinity,
        width: double.infinity,
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(),
        ),
        errorWidget: (context, url, error) => _buildPlaceholder(context),
      );
    } else if (File(item.imagePath).existsSync()) {
      return Image.file(
        File(item.imagePath),
        fit: BoxFit.contain,
        height: double.infinity,
        width: double.infinity,
      );
    } else {
      return _buildPlaceholder(context);
    }
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.checkroom,
            size: 80,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No Image',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else if (difference < 30) {
      final weeks = (difference / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else {
      final months = (difference / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    }
  }

  String _formatFullDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  int _getOutfitCount(BuildContext context) {
    final provider = Provider.of<WardrobeProvider>(context, listen: false);
    return provider.outfits.where((outfit) => 
      outfit.items.any((outfitItem) => outfitItem.id == item.id)
    ).length;
  }

  Color _getColorFromString(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'black': return Colors.black;
      case 'white': return Colors.white;
      case 'gray': case 'grey': return Colors.grey;
      case 'navy': return const Color(0xFF000080);
      case 'brown': return Colors.brown;
      case 'beige': return const Color(0xFFF5F5DC);
      case 'red': return Colors.red;
      case 'pink': return Colors.pink;
      case 'orange': return Colors.orange;
      case 'yellow': return Colors.yellow;
      case 'green': return Colors.green;
      case 'blue': return Colors.blue;
      case 'purple': return Colors.purple;
      default: return Colors.grey;
    }
  }

  Color _getSeasonColor(String season) {
    switch (season) {
      case 'Spring': return Colors.green;
      case 'Summer': return Colors.orange;
      case 'Autumn': return Colors.brown;
      case 'Winter': return Colors.blue;
      default: return Colors.grey;
    }
  }

  void _editItem(BuildContext context) {
    // TODO: Navigate to edit screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit functionality will be implemented')),
    );
  }

  void _toggleFavorite(BuildContext context) {
    // TODO: Implement favorite functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Favorite functionality will be implemented')),
    );
  }

  void _findMatchingOutfits(BuildContext context) {
    final provider = Provider.of<WardrobeProvider>(context, listen: false);
    final matchingOutfits = provider.outfits.where((outfit) => 
      outfit.items.any((outfitItem) => outfitItem.id == item.id)
    ).toList();

    if (matchingOutfits.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Outfits with ${item.name}'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: matchingOutfits.length,
              itemBuilder: (context, index) {
                final outfit = matchingOutfits[index];
                return ListTile(
                  leading: const Icon(Icons.style),
                  title: Text(outfit.name),
                  subtitle: Text('${outfit.items.length} items • ${outfit.occasion}'),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to outfit detail
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This item is not used in any outfits yet')),
      );
    }
  }

  void _duplicateItem(BuildContext context) {
    final provider = Provider.of<WardrobeProvider>(context, listen: false);
    final duplicatedItem = ClothingItem(
      name: '${item.name} (Copy)',
      category: item.category,
      color: item.color,
      season: item.season,
      imagePath: item.imagePath,
      tags: List.from(item.tags),
      createdAt: DateTime.now(),
    );
    
    provider.addClothingItem(duplicatedItem);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Item duplicated successfully!')),
    );
  }

  void _deleteItem(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "${item.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final provider = Provider.of<WardrobeProvider>(context, listen: false);
              provider.deleteClothingItem(item.id!);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close detail screen
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Item deleted successfully')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
