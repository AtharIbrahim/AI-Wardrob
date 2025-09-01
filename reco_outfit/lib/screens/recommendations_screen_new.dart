import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wardrobe_provider.dart';
import '../widgets/outfit_card.dart';
import '../widgets/weather_card.dart';
import '../widgets/responsive_ui_components.dart';
import '../models/outfit.dart';
import '../utils/responsive_utils.dart';
import '../theme/app_theme.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  String _selectedOccasion = Occasion.casual;
  String _selectedMood = Mood.comfortable;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: _buildAppBar(context),
      body: Consumer<WardrobeProvider>(
        builder: (context, provider, child) {
          return SafeArea(
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Current Weather (if available)
                if (provider.currentWeather != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: ResponsiveUtils.getResponsivePadding(context),
                      child: WeatherCard(
                        weather: provider.currentWeather!,
                        onRefresh: () => provider.loadWeather(),
                        onLocationUpdate: () => provider.loadCurrentLocationWeather(),
                        showLocationButton: true,
                      ),
                    ),
                  ),
                
                // Preferences Section
                SliverToBoxAdapter(
                  child: _buildPreferencesSection(context, provider),
                ),
                
                // Recommendations List
                _buildRecommendationsSlivers(context, provider),
              ],
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      title: Text(
        'Outfit Recommendations',
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.grey[800],
        ),
      ),
      actions: [
        ResponsiveWidget(
          mobile: IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.primaryColor),
            onPressed: () => _generateRecommendations(context.read<WardrobeProvider>()),
          ),
          tablet: ResponsiveButton(
            text: 'Refresh',
            icon: Icons.refresh,
            size: ButtonSize.small,
            onPressed: () => _generateRecommendations(context.read<WardrobeProvider>()),
          ),
          desktop: ResponsiveButton(
            text: 'New Suggestions',
            icon: Icons.refresh,
            size: ButtonSize.medium,
            onPressed: () => _generateRecommendations(context.read<WardrobeProvider>()),
          ),
        ),
        SizedBox(width: ResponsiveUtils.getResponsiveValue(context, mobile: 8, tablet: 12, desktop: 16)),
      ],
    );
  }

  Widget _buildPreferencesSection(BuildContext context, WardrobeProvider provider) {
    return Container(
      margin: ResponsiveUtils.getResponsivePadding(context),
      child: ResponsiveCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ResponsiveSectionHeader(
              title: 'Tell us about your plans',
              subtitle: 'Help us create the perfect outfit for you',
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 16, tablet: 20, desktop: 24)),
            
            ResponsiveWidget(
              mobile: _buildMobilePreferences(context),
              tablet: _buildTabletPreferences(context),
              desktop: _buildDesktopPreferences(context),
            ),
            
            SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 16, tablet: 20, desktop: 24)),
            
            // Generate Button
            _buildGenerateButton(context, provider),
          ],
        ),
      ),
    );
  }

  Widget _buildMobilePreferences(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Occasion Selection
        Text(
          'Occasion',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 8, tablet: 12, desktop: 16)),
        _buildOccasionChips(context),
        
        SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 16, tablet: 20, desktop: 24)),
        
        // Mood Selection
        Text(
          'Mood',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 8, tablet: 12, desktop: 16)),
        _buildMoodChips(context),
      ],
    );
  }

  Widget _buildTabletPreferences(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Occasion Selection
        Text(
          'Occasion',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 8, tablet: 12, desktop: 16)),
        _buildOccasionChips(context),
        
        SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 16, tablet: 20, desktop: 24)),
        
        // Mood Selection
        Text(
          'Mood',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 8, tablet: 12, desktop: 16)),
        _buildMoodChips(context),
      ],
    );
  }

  Widget _buildDesktopPreferences(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Occasion Selection (Left)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Occasion',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 8, tablet: 12, desktop: 16)),
              _buildOccasionChips(context),
            ],
          ),
        ),
        
        SizedBox(width: ResponsiveUtils.getResponsiveValue(context, mobile: 16, tablet: 20, desktop: 24)),
        
        // Mood Selection (Right)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mood',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 8, tablet: 12, desktop: 16)),
              _buildMoodChips(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOccasionChips(BuildContext context) {
    return Wrap(
      spacing: ResponsiveUtils.getResponsiveValue(context, mobile: 8, tablet: 12, desktop: 16),
      runSpacing: ResponsiveUtils.getResponsiveValue(context, mobile: 8, tablet: 12, desktop: 16),
      children: Occasion.all.map((occasion) {
        final isSelected = _selectedOccasion == occasion;
        return _buildSelectionChip(context, occasion, isSelected, (selected) {
          if (selected) {
            setState(() {
              _selectedOccasion = occasion;
            });
          }
        });
      }).toList(),
    );
  }

  Widget _buildMoodChips(BuildContext context) {
    return Wrap(
      spacing: ResponsiveUtils.getResponsiveValue(context, mobile: 8, tablet: 12, desktop: 16),
      runSpacing: ResponsiveUtils.getResponsiveValue(context, mobile: 8, tablet: 12, desktop: 16),
      children: Mood.all.map((mood) {
        final isSelected = _selectedMood == mood;
        return _buildSelectionChip(context, mood, isSelected, (selected) {
          if (selected) {
            setState(() {
              _selectedMood = mood;
            });
          }
        });
      }).toList(),
    );
  }

  Widget _buildSelectionChip(BuildContext context, String label, bool isSelected, Function(bool) onSelected) {
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: ResponsiveUtils.getResponsiveValue(context, mobile: 12, tablet: 14, desktop: 16),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected ? AppTheme.primaryColor : Colors.grey[700],
        ),
      ),
      selected: isSelected,
      onSelected: onSelected,
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
    );
  }

  Widget _buildGenerateButton(BuildContext context, WardrobeProvider provider) {
    return ResponsiveButton(
      text: provider.isLoading ? 'Generating...' : 'Get AI Recommendations',
      icon: provider.isLoading ? null : Icons.auto_awesome,
      variant: ButtonVariant.gradient,
      size: ResponsiveUtils.getDeviceType(context) == DeviceType.mobile 
          ? ButtonSize.medium 
          : ButtonSize.large,
      fullWidth: true,
      loading: provider.isLoading,
      onPressed: provider.isLoading ? null : () => _generateRecommendations(provider),
    );
  }

  Widget _buildRecommendationsSlivers(BuildContext context, WardrobeProvider provider) {
    if (provider.recommendations.isEmpty && !provider.isLoading) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _buildEmptyState(context, provider),
      );
    }

    if (provider.isLoading) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Padding(
            padding: ResponsiveUtils.getResponsivePadding(context),
            child: ResponsiveLoading(
              message: 'Creating perfect outfit combinations for you...',
              size: LoadingSize.large,
            ),
          ),
        ),
      );
    }

    return SliverToBoxAdapter(
      child: Container(
        padding: ResponsiveUtils.getResponsivePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ResponsiveSectionHeader(
              title: 'Your Recommendations',
              subtitle: '${provider.recommendations.length} outfit${provider.recommendations.length != 1 ? 's' : ''} curated for you',
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 16, tablet: 20, desktop: 24)),
            ResponsiveWidget(
              mobile: _buildMobileRecommendationsList(context, provider),
              tablet: _buildTabletRecommendationsList(context, provider),
              desktop: _buildDesktopRecommendationsList(context, provider),
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 50, tablet: 60, desktop: 70)),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileRecommendationsList(BuildContext context, WardrobeProvider provider) {
    return Column(
      children: provider.recommendations.asMap().entries.map((entry) {
        final index = entry.key;
        final recommendation = entry.value;
        return Container(
          margin: EdgeInsets.only(
            bottom: index < provider.recommendations.length - 1 
                ? ResponsiveUtils.getResponsiveValue(context, mobile: 12, tablet: 16, desktop: 20)
                : 0,
          ),
          child: OutfitCard(
            outfit: recommendation,
            onTap: () => _showRecommendationDetails(context, recommendation),
            onSave: () => _saveRecommendation(context, recommendation, provider),
            showActions: true,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTabletRecommendationsList(BuildContext context, WardrobeProvider provider) {
    return ResponsiveGrid(
      forceColumns: 2,
      spacing: ResponsiveUtils.getResponsiveValue(context, mobile: 12, tablet: 16, desktop: 20),
      children: provider.recommendations.map((recommendation) => OutfitCard(
        outfit: recommendation,
        onTap: () => _showRecommendationDetails(context, recommendation),
        onSave: () => _saveRecommendation(context, recommendation, provider),
        showActions: true,
      )).toList(),
    );
  }

  Widget _buildDesktopRecommendationsList(BuildContext context, WardrobeProvider provider) {
    return ResponsiveGrid(
      forceColumns: 3,
      spacing: ResponsiveUtils.getResponsiveValue(context, mobile: 12, tablet: 16, desktop: 20),
      children: provider.recommendations.map((recommendation) => OutfitCard(
        outfit: recommendation,
        onTap: () => _showRecommendationDetails(context, recommendation),
        onSave: () => _saveRecommendation(context, recommendation, provider),
        showActions: true,
      )).toList(),
    );
  }

  Widget _buildEmptyState(BuildContext context, WardrobeProvider provider) {
    return Center(
      child: Container(
        padding: ResponsiveUtils.getResponsivePadding(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lightbulb_outline,
              size: ResponsiveUtils.getResponsiveValue(context, mobile: 64, tablet: 80, desktop: 96),
              color: Colors.grey[400],
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 16, tablet: 20, desktop: 24)),
            Text(
              'No recommendations yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 8, tablet: 12, desktop: 16)),
            Text(
              'Select your occasion and mood, then tap "Get AI Recommendations"',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 24, tablet: 32, desktop: 40)),
            
            if (provider.totalItems == 0) ...[
              Container(
                padding: ResponsiveUtils.getResponsivePadding(context),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: ResponsiveUtils.getResponsiveValue(context, mobile: 32, tablet: 40, desktop: 48),
                      color: Colors.orange[700],
                    ),
                    SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 8, tablet: 12, desktop: 16)),
                    Text(
                      'Add clothing items first!',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.orange[700],
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 8, tablet: 12, desktop: 16)),
                    Text(
                      'You need at least a few clothing items in your wardrobe before we can create outfit recommendations.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.orange[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 16, tablet: 20, desktop: 24)),
                    ResponsiveButton(
                      text: 'Add Clothes to Wardrobe',
                      icon: Icons.add,
                      size: ResponsiveUtils.getDeviceType(context) == DeviceType.mobile 
                          ? ButtonSize.medium 
                          : ButtonSize.large,
                      fullWidth: true,
                      onPressed: () => _navigateToWardrobe(context),
                    ),
                  ],
                ),
              ),
            ] else ...[
              ResponsiveWidget(
                mobile: Column(
                  children: [
                    ResponsiveButton(
                      text: 'Get AI Recommendations',
                      icon: Icons.auto_awesome,
                      variant: ButtonVariant.gradient,
                      fullWidth: true,
                      onPressed: () => _generateRecommendations(provider),
                    ),
                    SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 12, tablet: 16, desktop: 20)),
                    ResponsiveButton(
                      text: 'Add More Clothes',
                      icon: Icons.add,
                      variant: ButtonVariant.secondary,
                      fullWidth: true,
                      onPressed: () => _navigateToWardrobe(context),
                    ),
                  ],
                ),
                tablet: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ResponsiveButton(
                      text: 'Get Recommendations',
                      icon: Icons.auto_awesome,
                      variant: ButtonVariant.gradient,
                      onPressed: () => _generateRecommendations(provider),
                    ),
                    SizedBox(width: ResponsiveUtils.getResponsiveValue(context, mobile: 12, tablet: 16, desktop: 20)),
                    ResponsiveButton(
                      text: 'Add Clothes',
                      icon: Icons.add,
                      variant: ButtonVariant.secondary,
                      onPressed: () => _navigateToWardrobe(context),
                    ),
                  ],
                ),
                desktop: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ResponsiveButton(
                      text: 'Get AI Recommendations',
                      icon: Icons.auto_awesome,
                      variant: ButtonVariant.gradient,
                      size: ButtonSize.large,
                      onPressed: () => _generateRecommendations(provider),
                    ),
                    SizedBox(width: ResponsiveUtils.getResponsiveValue(context, mobile: 12, tablet: 16, desktop: 20)),
                    ResponsiveButton(
                      text: 'Add More Clothes',
                      icon: Icons.add,
                      variant: ButtonVariant.secondary,
                      size: ButtonSize.large,
                      onPressed: () => _navigateToWardrobe(context),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showRecommendationDetails(BuildContext context, Outfit recommendation) {
    showDialog(
      context: context,
      builder: (context) => ResponsiveWidget(
        mobile: _buildMobileRecommendationDialog(context, recommendation),
        tablet: _buildTabletRecommendationDialog(context, recommendation),
        desktop: _buildDesktopRecommendationDialog(context, recommendation),
      ),
    );
  }

  Widget _buildMobileRecommendationDialog(BuildContext context, Outfit recommendation) {
    return Dialog(
      insetPadding: ResponsiveUtils.getResponsivePadding(context),
      shape: RoundedRectangleBorder(
        borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: _buildRecommendationDialogContent(context, recommendation),
      ),
    );
  }

  Widget _buildTabletRecommendationDialog(BuildContext context, Outfit recommendation) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.7,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: _buildRecommendationDialogContent(context, recommendation),
      ),
    );
  }

  Widget _buildDesktopRecommendationDialog(BuildContext context, Outfit recommendation) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context),
      ),
      child: Container(
        width: 600,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: _buildRecommendationDialogContent(context, recommendation),
      ),
    );
  }

  Widget _buildRecommendationDialogContent(BuildContext context, Outfit recommendation) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Container(
          padding: ResponsiveUtils.getResponsivePadding(context),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient.scale(0.3),
            borderRadius: BorderRadius.vertical(
              top: ResponsiveUtils.getResponsiveBorderRadius(context).topLeft,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: AppTheme.primaryColor,
                size: ResponsiveUtils.getResponsiveIconSize(context),
              ),
              SizedBox(width: ResponsiveUtils.getResponsiveValue(context, mobile: 8, tablet: 12, desktop: 16)),
              Expanded(
                child: Text(
                  recommendation.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              // AI Badge
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.getResponsiveValue(context, mobile: 8, tablet: 10, desktop: 12),
                  vertical: ResponsiveUtils.getResponsiveValue(context, mobile: 4, tablet: 6, desktop: 8),
                ),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.2),
                  borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context),
                ),
                child: Text(
                  'AI ✨',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveValue(context, mobile: 10, tablet: 12, desktop: 14),
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
              ),
              SizedBox(width: ResponsiveUtils.getResponsiveValue(context, mobile: 8, tablet: 12, desktop: 16)),
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
                // AI Reasoning (if available)
                if (recommendation.metadata?['ai_reasoning'] != null) ...[
                  ResponsiveCard(
                    color: Colors.purple.withOpacity(0.05),
                    border: true,
                    borderColor: Colors.purple.withOpacity(0.2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.psychology,
                              size: ResponsiveUtils.getResponsiveValue(context, mobile: 16, tablet: 18, desktop: 20),
                              color: Colors.purple,
                            ),
                            SizedBox(width: ResponsiveUtils.getResponsiveValue(context, mobile: 4, tablet: 6, desktop: 8)),
                            Text(
                              'AI Styling Insight',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.purple,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 8, tablet: 10, desktop: 12)),
                        Text(
                          recommendation.metadata!['ai_reasoning']!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 16, tablet: 20, desktop: 24)),
                ],
                
                // Style Tags (if available)
                if (recommendation.metadata?['style_tags'] != null && recommendation.metadata!['style_tags']!.isNotEmpty) ...[
                  Text(
                    'Style Tags:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 8, tablet: 12, desktop: 16)),
                  Wrap(
                    spacing: ResponsiveUtils.getResponsiveValue(context, mobile: 8, tablet: 10, desktop: 12),
                    runSpacing: ResponsiveUtils.getResponsiveValue(context, mobile: 4, tablet: 6, desktop: 8),
                    children: recommendation.metadata!['style_tags']!
                        .split(', ')
                        .map((tag) => Chip(
                              label: Text(
                                tag,
                                style: TextStyle(
                                  fontSize: ResponsiveUtils.getResponsiveValue(context, mobile: 10, tablet: 12, desktop: 14),
                                ),
                              ),
                              backgroundColor: Colors.blue.withOpacity(0.1),
                            ))
                        .toList(),
                  ),
                  SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 16, tablet: 20, desktop: 24)),
                ],
                
                // AI Confidence (if available)
                if (recommendation.metadata?['ai_confidence'] != null) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: ResponsiveUtils.getResponsiveValue(context, mobile: 16, tablet: 18, desktop: 20),
                        color: Colors.amber,
                      ),
                      SizedBox(width: ResponsiveUtils.getResponsiveValue(context, mobile: 4, tablet: 6, desktop: 8)),
                      Text(
                        'AI Confidence: ',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      Text(
                        '${(double.parse(recommendation.metadata!['ai_confidence']!) * 100).toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 16, tablet: 20, desktop: 24)),
                ],
                
                // Items
                Text(
                  'Items in this outfit (${recommendation.items.length}):',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 8, tablet: 12, desktop: 16)),
                
                ...recommendation.items.map((item) => ResponsiveCard(
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
                    trailing: Chip(
                      label: Text(
                        item.season,
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveValue(context, mobile: 10, tablet: 12, desktop: 14),
                        ),
                      ),
                      backgroundColor: _getSeasonColor(item.season).withOpacity(0.2),
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
                  text: 'Try Another',
                  icon: Icons.refresh,
                  variant: ButtonVariant.secondary,
                  fullWidth: true,
                  onPressed: () {
                    Navigator.pop(context);
                    _generateNewRecommendation();
                  },
                ),
                SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 12, tablet: 16, desktop: 20)),
                ResponsiveButton(
                  text: 'Save Outfit',
                  icon: Icons.favorite,
                  variant: ButtonVariant.gradient,
                  fullWidth: true,
                  onPressed: () {
                    Navigator.pop(context);
                    _saveRecommendation(context, recommendation, context.read<WardrobeProvider>());
                  },
                ),
              ],
            ),
            tablet: Row(
              children: [
                Expanded(
                  child: ResponsiveButton(
                    text: 'Try Another',
                    icon: Icons.refresh,
                    variant: ButtonVariant.secondary,
                    onPressed: () {
                      Navigator.pop(context);
                      _generateNewRecommendation();
                    },
                  ),
                ),
                SizedBox(width: ResponsiveUtils.getResponsiveValue(context, mobile: 12, tablet: 16, desktop: 20)),
                Expanded(
                  child: ResponsiveButton(
                    text: 'Save Outfit',
                    icon: Icons.favorite,
                    variant: ButtonVariant.gradient,
                    onPressed: () {
                      Navigator.pop(context);
                      _saveRecommendation(context, recommendation, context.read<WardrobeProvider>());
                    },
                  ),
                ),
              ],
            ),
            desktop: Row(
              children: [
                Expanded(
                  child: ResponsiveButton(
                    text: 'Try Another Recommendation',
                    icon: Icons.refresh,
                    variant: ButtonVariant.secondary,
                    size: ButtonSize.large,
                    onPressed: () {
                      Navigator.pop(context);
                      _generateNewRecommendation();
                    },
                  ),
                ),
                SizedBox(width: ResponsiveUtils.getResponsiveValue(context, mobile: 12, tablet: 16, desktop: 20)),
                Expanded(
                  child: ResponsiveButton(
                    text: 'Save to My Outfits',
                    icon: Icons.favorite,
                    variant: ButtonVariant.gradient,
                    size: ButtonSize.large,
                    onPressed: () {
                      Navigator.pop(context);
                      _saveRecommendation(context, recommendation, context.read<WardrobeProvider>());
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

  Color _getSeasonColor(String season) {
    switch (season) {
      case 'Spring':
        return Colors.green;
      case 'Summer':
        return Colors.orange;
      case 'Autumn':
        return Colors.brown;
      case 'Winter':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void _navigateToWardrobe(BuildContext context) {
    // Navigate to wardrobe screen
    DefaultTabController.of(context).animateTo(1);
  }

  void _generateRecommendations(WardrobeProvider provider) async {
    if (provider.totalItems == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please add some clothing items to your wardrobe first!'),
          action: SnackBarAction(
            label: 'Add Clothes',
            onPressed: () => _navigateToWardrobe(context),
          ),
        ),
      );
      return;
    }

    await provider.generateRecommendations(
      occasion: _selectedOccasion,
      mood: _selectedMood,
    );

    if (provider.recommendations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No suitable outfits found. Try adding more clothes or different preferences!'),
        ),
      );
    }
  }

  void _generateNewRecommendation() {
    final provider = context.read<WardrobeProvider>();
    provider.generateRecommendations(
      occasion: _selectedOccasion,
      mood: _selectedMood,
      maxRecommendations: 1,
    );
  }

  void _saveRecommendation(BuildContext context, Outfit recommendation, WardrobeProvider provider) {
    String outfitName = recommendation.name;
    final controller = TextEditingController(text: outfitName);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context),
        ),
        title: Text(
          'Save Outfit',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Give your outfit a memorable name:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 12, tablet: 16, desktop: 20)),
            ResponsiveTextField(
              controller: controller,
              hint: 'Enter outfit name',
              onChanged: (value) {
                outfitName = value;
              },
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
            text: 'Save',
            onPressed: () {
              if (outfitName.trim().isNotEmpty) {
                final savedOutfit = Outfit(
                  name: outfitName.trim(),
                  items: recommendation.items,
                  occasion: recommendation.occasion,
                  weather: recommendation.weather,
                  mood: recommendation.mood,
                  createdAt: DateTime.now(),
                );
                
                provider.addOutfit(savedOutfit);
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Outfit "$outfitName" saved to your collection!'),
                    backgroundColor: AppTheme.successColor,
                    action: SnackBarAction(
                      label: 'View',
                      textColor: Colors.white,
                      onPressed: () {
                        // Navigate to outfits screen
                        DefaultTabController.of(context).animateTo(2);
                      },
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
