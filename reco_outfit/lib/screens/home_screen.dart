import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/wardrobe_provider.dart';
import '../widgets/weather_card.dart';
import '../widgets/outfit_card.dart';
import '../utils/responsive_utils.dart';
import '../theme/app_theme.dart';
import 'recommendations_screen.dart';
import 'wardrobe_screen.dart';
import 'outfits_screen.dart';
import 'add_clothing_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late TabController _tabController;
  
  final PageController _pageController = PageController();

  final List<Widget> _screens = [
    const HomeTab(),
    const WardrobeScreen(),
    const OutfitsScreen(),
    const RecommendationsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: AppTheme.normalAnimation,
      curve: AppTheme.defaultCurve,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: _screens,
      ),
      bottomNavigationBar: _buildResponsiveBottomNav(context),
    );
  }

  Widget _buildResponsiveBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: ResponsiveUtils.getResponsiveElevation(context),
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedFontSize: ResponsiveUtils.getResponsiveFontSize(context, base: 12),
        unselectedFontSize: ResponsiveUtils.getResponsiveFontSize(context, base: 11),
        elevation: 0,
        backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor ?? Theme.of(context).colorScheme.surface,
        selectedItemColor: Theme.of(context).bottomNavigationBarTheme.selectedItemColor ?? Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor ?? Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded, size: ResponsiveUtils.getResponsiveIconSize(context)),
            activeIcon: Icon(Icons.home_rounded, size: ResponsiveUtils.getResponsiveIconSize(context) + 2),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checkroom_rounded, size: ResponsiveUtils.getResponsiveIconSize(context)),
            activeIcon: Icon(Icons.checkroom_rounded, size: ResponsiveUtils.getResponsiveIconSize(context) + 2),
            label: 'Wardrobe',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.style_rounded, size: ResponsiveUtils.getResponsiveIconSize(context)),
            activeIcon: Icon(Icons.style_rounded, size: ResponsiveUtils.getResponsiveIconSize(context) + 2),
            label: 'Outfits',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb_outline, size: ResponsiveUtils.getResponsiveIconSize(context)),
            activeIcon: Icon(Icons.lightbulb, size: ResponsiveUtils.getResponsiveIconSize(context) + 2),
            label: 'AI Stylist',
          ),
        ],
      ),
    );
  }
}

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Responsive App Bar
          _buildResponsiveAppBar(context),

          // Main Content
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Consumer<WardrobeProvider>(
                builder: (context, provider, child) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      await provider.initialize();
                    },
                    child: ResponsiveContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 16, tablet: 24, desktop: 32)),
                          
                          // Weather Card
                          if (provider.currentWeather != null)
                            _buildResponsiveWeatherCard(provider),
                          
                          SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 24, tablet: 32, desktop: 40)),
                          
                          // Quick Stats
                          _buildResponsiveStatsSection(provider),
                          
                          SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 32, tablet: 40, desktop: 48)),
                          
                          // Quick Actions
                          _buildResponsiveQuickActionsSection(context),
                          
                          SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 32, tablet: 40, desktop: 48)),
                          
                          // Recent Outfits
                          _buildResponsiveRecentOutfitsSection(provider),
                          
                          SizedBox(height: ResponsiveUtils.getBottomNavHeight(context) + 20),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: ResponsiveUtils.getResponsiveValue(context, mobile: 120, tablet: 140, desktop: 160),
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: FlexibleSpaceBar(
          title: Text(
            'StyleSense',
            style: GoogleFonts.inter(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, base: 20, tablet: 24, desktop: 28),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: false,
          titlePadding: EdgeInsets.only(
            left: ResponsiveUtils.getResponsiveValue(context, mobile: 20, tablet: 24, desktop: 32),
            bottom: ResponsiveUtils.getResponsiveValue(context, mobile: 16, tablet: 20, desktop: 24),
          ),
          background: Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.primaryGradient,
            ),
            child: Stack(
              children: [
                // Animated background elements
                _buildBackgroundCircle(
                  top: -50,
                  right: -50,
                  size: ResponsiveUtils.getResponsiveValue(context, mobile: 150, tablet: 180, desktop: 220),
                  opacity: 0.1,
                ),
                _buildBackgroundCircle(
                  bottom: -30,
                  left: -30,
                  size: ResponsiveUtils.getResponsiveValue(context, mobile: 100, tablet: 120, desktop: 150),
                  opacity: 0.08,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.notifications_rounded,
            color: Colors.white,
            size: ResponsiveUtils.getResponsiveIconSize(context),
          ),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(
            Icons.settings,
            color: Colors.white,
            size: ResponsiveUtils.getResponsiveIconSize(context),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          },
        ),
        SizedBox(width: ResponsiveUtils.getResponsiveValue(context, mobile: 8, tablet: 12, desktop: 16)),
      ],
    );
  }

  Widget _buildBackgroundCircle({
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

  Widget _buildResponsiveWeatherCard(WardrobeProvider provider) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppTheme.infoGradient,
        borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context),
        boxShadow: [
          BoxShadow(
            color: AppTheme.infoColor.withOpacity(0.3),
            blurRadius: ResponsiveUtils.getResponsiveElevation(context),
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: WeatherCard(
        weather: provider.currentWeather!,
        onRefresh: () => provider.loadWeather(),
        onLocationUpdate: () => provider.loadCurrentLocationWeather(),
        showLocationButton: true,
      ),
    );
  }

  Widget _buildResponsiveStatsSection(WardrobeProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Wardrobe',
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
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Items',
                  provider.totalItems.toString(),
                  Icons.checkroom_rounded,
                  AppTheme.primaryColor,
                ),
              ),
              SizedBox(width: ResponsiveUtils.getGridSpacing(context)),
              Expanded(
                child: _buildStatCard(
                  'Outfits',
                  provider.totalOutfits.toString(),
                  Icons.style_rounded,
                  AppTheme.secondaryColor,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: ResponsiveUtils.getGridSpacing(context)),
        _buildStatCard(
          'Categories',
          provider.getCategoryStats().keys.length.toString(),
          Icons.category_rounded,
          AppTheme.tertiaryColor,
          isFullWidth: true,
        ),
      ],
    );
  }

  Widget _buildTabletStatsLayout(WardrobeProvider provider) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Items',
              provider.totalItems.toString(),
              Icons.checkroom_rounded,
              AppTheme.primaryColor,
            ),
          ),
          SizedBox(width: ResponsiveUtils.getGridSpacing(context)),
          Expanded(
            child: _buildStatCard(
              'Outfits',
              provider.totalOutfits.toString(),
              Icons.style_rounded,
              AppTheme.secondaryColor,
            ),
          ),
          SizedBox(width: ResponsiveUtils.getGridSpacing(context)),
          Expanded(
            child: _buildStatCard(
              'Categories',
              provider.getCategoryStats().keys.length.toString(),
              Icons.category_rounded,
              AppTheme.tertiaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopStatsLayout(WardrobeProvider provider) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Items',
              provider.totalItems.toString(),
              Icons.checkroom_rounded,
              AppTheme.primaryColor,
            ),
          ),
          SizedBox(width: ResponsiveUtils.getGridSpacing(context)),
          Expanded(
            child: _buildStatCard(
              'Outfits',
              provider.totalOutfits.toString(),
              Icons.style_rounded,
              AppTheme.secondaryColor,
            ),
          ),
          SizedBox(width: ResponsiveUtils.getGridSpacing(context)),
          Expanded(
            child: _buildStatCard(
              'Categories',
              provider.getCategoryStats().keys.length.toString(),
              Icons.category_rounded,
              AppTheme.tertiaryColor,
            ),
          ),
          SizedBox(width: ResponsiveUtils.getGridSpacing(context)),
          Expanded(
            child: _buildStatCard(
              'Favorites',
              '0', // Add favorites count when available
              Icons.favorite_rounded,
              AppTheme.warningColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, {bool isFullWidth = false}) {
    return Container(
      padding: ResponsiveUtils.getResponsivePadding(context),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: ResponsiveUtils.getResponsiveElevation(context),
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(ResponsiveUtils.getResponsiveValue(context, mobile: 8, tablet: 12, desktop: 16)),
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
          SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 8, tablet: 10, desktop: 12)),
          Flexible(
            child: Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[800],
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 4, tablet: 6, desktop: 8)),
          Flexible(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveQuickActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 16, tablet: 20, desktop: 24)),
        ResponsiveWidget(
          mobile: _buildMobileActionsLayout(context),
          tablet: _buildTabletActionsLayout(context),
          desktop: _buildDesktopActionsLayout(context),
        ),
      ],
    );
  }

  Widget _buildMobileActionsLayout(BuildContext context) {
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  'Get AI Stylist',
                  'Personal style recommendations',
                  Icons.psychology_rounded,
                  AppTheme.warningColor,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RecommendationsScreen(),
                    ),
                  ),
                ),
              ),
              SizedBox(width: ResponsiveUtils.getGridSpacing(context)),
              Expanded(
                child: _buildActionCard(
                  'Add Items',
                  'Build your wardrobe',
                  Icons.add_circle_outline,
                  AppTheme.successColor,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddClothingScreen(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabletActionsLayout(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
            child: _buildActionCard(
              'Get AI Ideas',
              'Smart outfit suggestions',
              Icons.auto_awesome_rounded,
              AppTheme.warningColor,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RecommendationsScreen(),
                ),
              ),
            ),
          ),
          SizedBox(width: ResponsiveUtils.getGridSpacing(context)),
          Expanded(
            child: _buildActionCard(
              'Add Clothes',
              'Expand your wardrobe',
              Icons.add_photo_alternate_rounded,
              AppTheme.successColor,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddClothingScreen(),
                ),
              ),
            ),
          ),
          SizedBox(width: ResponsiveUtils.getGridSpacing(context)),
          Expanded(
            child: _buildActionCard(
              'Browse Items',
              'View your wardrobe',
              Icons.visibility_outlined,
              AppTheme.infoColor,
              () {
                // Navigate to wardrobe screen
                if (context.mounted) {
                  Navigator.pushNamed(context, '/wardrobe');
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopActionsLayout(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
            child: _buildActionCard(
              'Get AI Stylist',
              'Personal style recommendations',
              Icons.psychology_rounded,
              AppTheme.warningColor,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RecommendationsScreen(),
                ),
              ),
            ),
          ),
          SizedBox(width: ResponsiveUtils.getGridSpacing(context)),
          Expanded(
            child: _buildActionCard(
              'Add Items',
              'Build your wardrobe',
              Icons.add_circle_outline,
              AppTheme.successColor,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddClothingScreen(),
                ),
              ),
            ),
          ),
          SizedBox(width: ResponsiveUtils.getGridSpacing(context)),
          Expanded(
            child: _buildActionCard(
              'Outfits',
              'Your saved combinations',
              Icons.palette_outlined,
              AppTheme.tertiaryColor,
              () {
                // Navigate to outfits screen
                Navigator.pushNamed(context, '/outfits');
              },
            ),
          ),
          SizedBox(width: ResponsiveUtils.getGridSpacing(context)),
          Expanded(
            child: _buildActionCard(
              'Analytics',
              'View style insights',
              Icons.analytics_rounded,
              AppTheme.infoColor,
              () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap, {
    bool isFullWidth = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isFullWidth ? double.infinity : null,
        padding: ResponsiveUtils.getResponsivePadding(context),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: ResponsiveUtils.getResponsiveElevation(context),
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: isFullWidth
            ? Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(ResponsiveUtils.getResponsiveValue(context, mobile: 12, tablet: 16, desktop: 20)),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: ResponsiveUtils.getResponsiveIconSize(context)),
                  ),
                  SizedBox(width: ResponsiveUtils.getResponsiveValue(context, mobile: 16, tablet: 20, desktop: 24)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 4, tablet: 6, desktop: 8)),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: ResponsiveUtils.getResponsiveIconSize(context) - 4,
                    color: Colors.grey[400],
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(ResponsiveUtils.getResponsiveValue(context, mobile: 8, tablet: 12, desktop: 16)),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: ResponsiveUtils.getResponsiveIconSize(context)),
                  ),
                  SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 8, tablet: 10, desktop: 12)),
                  Flexible(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.grey[800],
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 4, tablet: 6, desktop: 8)),
                  Flexible(
                    child: Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildResponsiveRecentOutfitsSection(WardrobeProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Outfits',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.grey[800],
              ),
            ),
            if (provider.outfits.isNotEmpty)
              TextButton(
                onPressed: () {
                  // Navigate to all outfits
                },
                child: Text(
                  'View All',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 16, tablet: 20, desktop: 24)),
        _buildResponsiveRecentOutfits(provider),
      ],
    );
  }

  Widget _buildResponsiveRecentOutfits(WardrobeProvider provider) {
    if (provider.outfits.isEmpty) {
      return Container(
        width: double.infinity,
        padding: ResponsiveUtils.getResponsivePadding(context),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(ResponsiveUtils.getResponsiveValue(context, mobile: 20, tablet: 24, desktop: 28)),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.style_rounded,
                size: ResponsiveUtils.getResponsiveValue(context, mobile: 48, tablet: 56, desktop: 64),
                color: Colors.grey[400],
              ),
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 20, tablet: 24, desktop: 28)),
            Text(
              'No outfits yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 8, tablet: 12, desktop: 16)),
            Text(
              'Get AI-powered outfit recommendations\nto create your first look!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 20, tablet: 24, desktop: 28)),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RecommendationsScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.auto_awesome_rounded),
              label: const Text('Get Ideas'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.getResponsiveValue(context, mobile: 24, tablet: 28, desktop: 32),
                  vertical: ResponsiveUtils.getResponsiveValue(context, mobile: 12, tablet: 16, desktop: 20),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final recentOutfits = provider.outfits.take(3).toList();
    
    return Column(
      children: recentOutfits.map((outfit) {
        return Container(
          margin: EdgeInsets.only(bottom: ResponsiveUtils.getGridSpacing(context)),
          child: OutfitCard(
            outfit: outfit,
            showActions: false,
            onTap: () {
              // Navigate to outfit details
            },
          ),
        );
      }).toList(),
    );
  }
}
