import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wardrobe_provider.dart';
import '../widgets/outfit_card.dart';
import '../widgets/responsive_ui_components.dart';
import '../models/outfit.dart';
import '../utils/responsive_utils.dart';
import '../theme/app_theme.dart';

class OutfitsScreen extends StatefulWidget {
  const OutfitsScreen({super.key});

  @override
  State<OutfitsScreen> createState() => _OutfitsScreenState();
}

class _OutfitsScreenState extends State<OutfitsScreen> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Consumer<WardrobeProvider>(
          builder: (context, provider, child) {
            return Column(
              children: [
                // Filter Section
                _buildFilterSection(context),
                
                // Outfits List
                Expanded(
                  child: _buildOutfitsList(context, provider),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).colorScheme.surface,
      foregroundColor: Theme.of(context).appBarTheme.foregroundColor ?? Theme.of(context).colorScheme.onSurface,
      elevation: 0,
      centerTitle: false,
      title: Text(
        'My Outfits',
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      actions: [
        ResponsiveWidget(
          mobile: IconButton(
            icon: const Icon(Icons.add, color: AppTheme.primaryColor),
            onPressed: () => _navigateToCreate(context),
          ),
          tablet: ResponsiveButton(
            text: 'Create',
            icon: Icons.add,
            size: ButtonSize.small,
            onPressed: () => _navigateToCreate(context),
          ),
          desktop: ResponsiveButton(
            text: 'Create Outfit',
            icon: Icons.add,
            size: ButtonSize.medium,
            onPressed: () => _navigateToCreate(context),
          ),
        ),
        SizedBox(width: ResponsiveUtils.getResponsiveValue(context, mobile: 8, tablet: 12, desktop: 16)),
      ],
    );
  }

  Widget _buildFilterSection(BuildContext context) {
    final filters = ['All', ...Occasion.all];
    
    return ResponsiveCard(
      margin: ResponsiveUtils.getResponsivePadding(context),
      padding: ResponsiveUtils.getResponsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveSectionHeader(
            title: 'Filter by Occasion',
            subtitle: '${_getFilteredCount()} outfit${_getFilteredCount() != 1 ? 's' : ''} found',
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 12, tablet: 16, desktop: 20)),
          ResponsiveWidget(
            mobile: _buildMobileFilters(context, filters),
            tablet: _buildTabletFilters(context, filters),
            desktop: _buildDesktopFilters(context, filters),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileFilters(BuildContext context, List<String> filters) {
    return SizedBox(
      height: ResponsiveUtils.getResponsiveValue(context, mobile: 36, tablet: 40, desktop: 44),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) => _buildFilterChip(context, filters[index], index == 0),
      ),
    );
  }

  Widget _buildTabletFilters(BuildContext context, List<String> filters) {
    return Wrap(
      spacing: ResponsiveUtils.getResponsiveValue(context, mobile: 8, tablet: 12, desktop: 16),
      runSpacing: ResponsiveUtils.getResponsiveValue(context, mobile: 8, tablet: 12, desktop: 16),
      children: filters.map((filter) => _buildFilterChip(context, filter, false)).toList(),
    );
  }

  Widget _buildDesktopFilters(BuildContext context, List<String> filters) {
    return Row(
      children: [
        Expanded(
          child: Wrap(
            spacing: ResponsiveUtils.getResponsiveValue(context, mobile: 8, tablet: 12, desktop: 16),
            runSpacing: ResponsiveUtils.getResponsiveValue(context, mobile: 8, tablet: 12, desktop: 16),
            children: filters.map((filter) => _buildFilterChip(context, filter, false)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(BuildContext context, String filter, bool addMargin) {
    final isSelected = _selectedFilter == filter;
    
    return Container(
      margin: addMargin ? EdgeInsets.only(right: ResponsiveUtils.getResponsiveValue(context, mobile: 8, tablet: 12, desktop: 16)) : null,
      child: FilterChip(
        label: Text(
          filter,
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveValue(context, mobile: 12, tablet: 14, desktop: 16),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppTheme.primaryColor : Colors.grey[700],
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = filter;
          });
        },
        backgroundColor: Colors.white,
        selectedColor: AppTheme.primaryColor.withOpacity(0.1),
        checkmarkColor: AppTheme.primaryColor,
        side: BorderSide(
          color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.getResponsiveValue(context, mobile: 12, tablet: 16, desktop: 20),
          vertical: ResponsiveUtils.getResponsiveValue(context, mobile: 8, tablet: 10, desktop: 12),
        ),
      ),
    );
  }

  Widget _buildOutfitsList(BuildContext context, WardrobeProvider provider) {
    List<Outfit> filteredOutfits = _getFilteredOutfits(provider);

    if (filteredOutfits.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () async {
        await provider.loadOutfits();
      },
      child: ResponsiveWidget(
        mobile: _buildMobileOutfitsList(context, filteredOutfits, provider),
        tablet: _buildTabletOutfitsList(context, filteredOutfits, provider),
        desktop: _buildDesktopOutfitsList(context, filteredOutfits, provider),
      ),
    );
  }

  Widget _buildMobileOutfitsList(BuildContext context, List<Outfit> outfits, WardrobeProvider provider) {
    return ListView.builder(
      padding: ResponsiveUtils.getResponsivePadding(context),
      itemCount: outfits.length,
      itemBuilder: (context, index) {
        final outfit = outfits[index];
        return Container(
          margin: EdgeInsets.only(bottom: ResponsiveUtils.getResponsiveValue(context, mobile: 12, tablet: 16, desktop: 20)),
          child: OutfitCard(
            outfit: outfit,
            onTap: () => _showOutfitDetails(context, outfit),
            onEdit: () => _editOutfit(context, outfit),
            onDelete: () => _deleteOutfit(context, outfit, provider),
          ),
        );
      },
    );
  }

  Widget _buildTabletOutfitsList(BuildContext context, List<Outfit> outfits, WardrobeProvider provider) {
    return ResponsiveGrid(
      forceColumns: 2,
      padding: ResponsiveUtils.getResponsivePadding(context),
      spacing: ResponsiveUtils.getResponsiveValue(context, mobile: 12, tablet: 16, desktop: 20),
      children: outfits.map((outfit) => OutfitCard(
        outfit: outfit,
        onTap: () => _showOutfitDetails(context, outfit),
        onEdit: () => _editOutfit(context, outfit),
        onDelete: () => _deleteOutfit(context, outfit, provider),
      )).toList(),
    );
  }

  Widget _buildDesktopOutfitsList(BuildContext context, List<Outfit> outfits, WardrobeProvider provider) {
    return ResponsiveGrid(
      forceColumns: 3,
      padding: ResponsiveUtils.getResponsivePadding(context),
      spacing: ResponsiveUtils.getResponsiveValue(context, mobile: 12, tablet: 16, desktop: 20),
      children: outfits.map((outfit) => OutfitCard(
        outfit: outfit,
        onTap: () => _showOutfitDetails(context, outfit),
        onEdit: () => _editOutfit(context, outfit),
        onDelete: () => _deleteOutfit(context, outfit, provider),
      )).toList(),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Container(
        padding: ResponsiveUtils.getResponsivePadding(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.style_outlined,
              size: ResponsiveUtils.getResponsiveValue(context, mobile: 64, tablet: 80, desktop: 96),
              color: Colors.grey[400],
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 16, tablet: 20, desktop: 24)),
            Text(
              _selectedFilter == 'All' ? 'No outfits yet' : 'No $_selectedFilter outfits',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 8, tablet: 12, desktop: 16)),
            Text(
              'Create outfits by getting recommendations\nor manually adding clothing items!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 24, tablet: 32, desktop: 40)),
            ResponsiveWidget(
              mobile: Column(
                children: [
                  ResponsiveButton(
                    text: 'Get Recommendations',
                    icon: Icons.lightbulb_outline,
                    fullWidth: true,
                    onPressed: () => _navigateToRecommendations(context),
                  ),
                  SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 12, tablet: 16, desktop: 20)),
                  ResponsiveButton(
                    text: 'Create Manually',
                    icon: Icons.add,
                    variant: ButtonVariant.secondary,
                    fullWidth: true,
                    onPressed: () => _navigateToCreate(context),
                  ),
                ],
              ),
              tablet: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ResponsiveButton(
                    text: 'Get Recommendations',
                    icon: Icons.lightbulb_outline,
                    onPressed: () => _navigateToRecommendations(context),
                  ),
                  SizedBox(width: ResponsiveUtils.getResponsiveValue(context, mobile: 12, tablet: 16, desktop: 20)),
                  ResponsiveButton(
                    text: 'Create Manually',
                    icon: Icons.add,
                    variant: ButtonVariant.secondary,
                    onPressed: () => _navigateToCreate(context),
                  ),
                ],
              ),
              desktop: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ResponsiveButton(
                    text: 'Get Recommendations',
                    icon: Icons.lightbulb_outline,
                    size: ButtonSize.large,
                    onPressed: () => _navigateToRecommendations(context),
                  ),
                  SizedBox(width: ResponsiveUtils.getResponsiveValue(context, mobile: 12, tablet: 16, desktop: 20)),
                  ResponsiveButton(
                    text: 'Create Manually',
                    icon: Icons.add,
                    variant: ButtonVariant.secondary,
                    size: ButtonSize.large,
                    onPressed: () => _navigateToCreate(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOutfitDetails(BuildContext context, Outfit outfit) {
    showDialog(
      context: context,
      builder: (context) => ResponsiveWidget(
        mobile: _buildMobileOutfitDialog(context, outfit),
        tablet: _buildTabletOutfitDialog(context, outfit),
        desktop: _buildDesktopOutfitDialog(context, outfit),
      ),
    );
  }

  Widget _buildMobileOutfitDialog(BuildContext context, Outfit outfit) {
    return Dialog(
      insetPadding: ResponsiveUtils.getResponsivePadding(context),
      shape: RoundedRectangleBorder(
        borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: _buildOutfitDialogContent(context, outfit),
      ),
    );
  }

  Widget _buildTabletOutfitDialog(BuildContext context, Outfit outfit) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: _buildOutfitDialogContent(context, outfit),
      ),
    );
  }

  Widget _buildDesktopOutfitDialog(BuildContext context, Outfit outfit) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context),
      ),
      child: Container(
        width: 500,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: _buildOutfitDialogContent(context, outfit),
      ),
    );
  }

  Widget _buildOutfitDialogContent(BuildContext context, Outfit outfit) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Container(
          padding: ResponsiveUtils.getResponsivePadding(context),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.vertical(
              top: ResponsiveUtils.getResponsiveBorderRadius(context).topLeft,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  outfit.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.close,
                  size: ResponsiveUtils.getResponsiveIconSize(context),
                ),
              ),
            ],
          ),
        ),
        
        // Content
        Flexible(
          child: SingleChildScrollView(
            padding: ResponsiveUtils.getResponsivePadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Outfit info
                _buildDetailRow(context, 'Occasion', outfit.occasion),
                _buildDetailRow(context, 'Mood', outfit.mood),
                _buildDetailRow(context, 'Weather', outfit.weather),
                _buildDetailRow(context, 'Created', _formatDate(outfit.createdAt)),
                if (outfit.rating != null)
                  _buildRatingRow(context, outfit.rating!),
                
                SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 16, tablet: 20, desktop: 24)),
                Text(
                  'Items (${outfit.items.length}):',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 8, tablet: 12, desktop: 16)),
                
                // Items list
                ...outfit.items.map((item) => ResponsiveCard(
                  margin: EdgeInsets.only(
                    bottom: ResponsiveUtils.getResponsiveValue(context, mobile: 8, tablet: 12, desktop: 16),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: ResponsiveUtils.getResponsiveValue(context, mobile: 12, tablet: 16, desktop: 20),
                      vertical: ResponsiveUtils.getResponsiveValue(context, mobile: 8, tablet: 10, desktop: 12),
                    ),
                    leading: Container(
                      width: ResponsiveUtils.getResponsiveValue(context, mobile: 40, tablet: 48, desktop: 56),
                      height: ResponsiveUtils.getResponsiveValue(context, mobile: 40, tablet: 48, desktop: 56),
                      decoration: BoxDecoration(
                        borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context),
                        color: Colors.grey[200],
                      ),
                      child: Icon(
                        Icons.checkroom,
                        size: ResponsiveUtils.getResponsiveIconSize(context),
                        color: Colors.grey[600],
                      ),
                    ),
                    title: Text(
                      item.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      '${item.category} • ${item.color}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                )).toList(),
              ],
            ),
          ),
        ),
        
        // Actions
        Container(
          padding: ResponsiveUtils.getResponsivePadding(context),
          child: ResponsiveWidget(
            mobile: Column(
              children: [
                ResponsiveButton(
                  text: 'Edit Outfit',
                  icon: Icons.edit,
                  variant: ButtonVariant.secondary,
                  fullWidth: true,
                  onPressed: () {
                    Navigator.pop(context);
                    _editOutfit(context, outfit);
                  },
                ),
                SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 12, tablet: 16, desktop: 20)),
                ResponsiveButton(
                  text: 'Rate Outfit',
                  icon: Icons.star,
                  fullWidth: true,
                  onPressed: () {
                    Navigator.pop(context);
                    _rateOutfit(context, outfit);
                  },
                ),
              ],
            ),
            tablet: Row(
              children: [
                Expanded(
                  child: ResponsiveButton(
                    text: 'Edit',
                    icon: Icons.edit,
                    variant: ButtonVariant.secondary,
                    onPressed: () {
                      Navigator.pop(context);
                      _editOutfit(context, outfit);
                    },
                  ),
                ),
                SizedBox(width: ResponsiveUtils.getResponsiveValue(context, mobile: 12, tablet: 16, desktop: 20)),
                Expanded(
                  child: ResponsiveButton(
                    text: 'Rate',
                    icon: Icons.star,
                    onPressed: () {
                      Navigator.pop(context);
                      _rateOutfit(context, outfit);
                    },
                  ),
                ),
              ],
            ),
            desktop: Row(
              children: [
                Expanded(
                  child: ResponsiveButton(
                    text: 'Edit Outfit',
                    icon: Icons.edit,
                    variant: ButtonVariant.secondary,
                    size: ButtonSize.large,
                    onPressed: () {
                      Navigator.pop(context);
                      _editOutfit(context, outfit);
                    },
                  ),
                ),
                SizedBox(width: ResponsiveUtils.getResponsiveValue(context, mobile: 12, tablet: 16, desktop: 20)),
                Expanded(
                  child: ResponsiveButton(
                    text: 'Rate Outfit',
                    icon: Icons.star,
                    size: ButtonSize.large,
                    onPressed: () {
                      Navigator.pop(context);
                      _rateOutfit(context, outfit);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: ResponsiveUtils.getResponsiveValue(context, mobile: 4, tablet: 6, desktop: 8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: ResponsiveUtils.getResponsiveValue(context, mobile: 80, tablet: 100, desktop: 120),
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingRow(BuildContext context, double rating) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: ResponsiveUtils.getResponsiveValue(context, mobile: 4, tablet: 6, desktop: 8),
      ),
      child: Row(
        children: [
          SizedBox(
            width: ResponsiveUtils.getResponsiveValue(context, mobile: 80, tablet: 100, desktop: 120),
            child: Text(
              'Rating:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          ...List.generate(5, (index) {
            return Icon(
              index < rating.round() ? Icons.star : Icons.star_border,
              color: Colors.amber,
              size: ResponsiveUtils.getResponsiveValue(context, mobile: 20, tablet: 24, desktop: 28),
            );
          }),
          SizedBox(width: ResponsiveUtils.getResponsiveValue(context, mobile: 8, tablet: 10, desktop: 12)),
          Text(
            '(${rating.toStringAsFixed(1)})',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  List<Outfit> _getFilteredOutfits(WardrobeProvider provider) {
    List<Outfit> filteredOutfits = provider.outfits;
    
    if (_selectedFilter != 'All') {
      filteredOutfits = provider.outfits
          .where((outfit) => outfit.occasion == _selectedFilter)
          .toList();
    }
    
    return filteredOutfits;
  }

  int _getFilteredCount() {
    return context.read<WardrobeProvider>().outfits.length;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _navigateToRecommendations(BuildContext context) {
    // Navigate to recommendations screen
    DefaultTabController.of(context).animateTo(3);
  }

  void _navigateToCreate(BuildContext context) {
    // Navigate to create outfit screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Create outfit feature coming soon!')),
    );
  }

  void _editOutfit(BuildContext context, Outfit outfit) {
    // Implement outfit editing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Outfit editing coming soon!')),
    );
  }

  void _deleteOutfit(BuildContext context, Outfit outfit, WardrobeProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context),
        ),
        title: Text(
          'Delete Outfit',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${outfit.name}"? This action cannot be undone.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[700],
          ),
        ),
        actions: [
          ResponsiveButton(
            text: 'Cancel',
            variant: ButtonVariant.text,
            onPressed: () => Navigator.pop(context),
          ),
          ResponsiveButton(
            text: 'Delete',
            customColor: AppTheme.errorColor,
            onPressed: () {
              provider.deleteOutfit(outfit.id!);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${outfit.name} deleted'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _rateOutfit(BuildContext context, Outfit outfit) {
    double currentRating = outfit.rating ?? 0;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context),
        ),
        title: Text(
          'Rate Outfit',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'How would you rate "${outfit.name}"?',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 16, tablet: 20, desktop: 24)),
            StatefulBuilder(
              builder: (context, setState) => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    onPressed: () {
                      setState(() {
                        currentRating = index + 1.0;
                      });
                    },
                    icon: Icon(
                      index < currentRating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: ResponsiveUtils.getResponsiveValue(context, mobile: 32, tablet: 36, desktop: 40),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
        actions: [
          ResponsiveButton(
            text: 'Cancel',
            variant: ButtonVariant.text,
            onPressed: () => Navigator.pop(context),
          ),
          ResponsiveButton(
            text: 'Save Rating',
            onPressed: () {
              final updatedOutfit = Outfit(
                id: outfit.id,
                name: outfit.name,
                items: outfit.items,
                occasion: outfit.occasion,
                weather: outfit.weather,
                mood: outfit.mood,
                createdAt: outfit.createdAt,
                rating: currentRating,
              );
              
              context.read<WardrobeProvider>().updateOutfit(updatedOutfit);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Rating saved! (${currentRating.toStringAsFixed(1)} stars)'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
