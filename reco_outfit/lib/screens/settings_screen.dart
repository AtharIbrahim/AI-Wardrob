import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import '../utils/responsive_utils.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: ResponsiveWidget(
          mobile: _buildMobileLayout(context),
          tablet: _buildTabletLayout(context),
          desktop: _buildDesktopLayout(context),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        'Settings',
        style: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: false,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Appearance'),
          const SizedBox(height: 16),
          _buildThemeToggleCard(context),
          const SizedBox(height: 32),
          _buildSectionHeader('About'),
          const SizedBox(height: 16),
          _buildAboutCard(context),
          const SizedBox(height: 32),
          _buildSectionHeader('Support'),
          const SizedBox(height: 16),
          _buildSupportCard(context),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Appearance'),
                    const SizedBox(height: 16),
                    _buildThemeToggleCard(context),
                    const SizedBox(height: 32),
                    _buildSectionHeader('About'),
                    const SizedBox(height: 16),
                    _buildAboutCard(context),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Support'),
                    const SizedBox(height: 16),
                    _buildSupportCard(context),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Appearance'),
                    const SizedBox(height: 16),
                    _buildThemeToggleCard(context),
                  ],
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('About'),
                    const SizedBox(height: 16),
                    _buildAboutCard(context),
                  ],
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Support'),
                    const SizedBox(height: 16),
                    _buildSupportCard(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildThemeToggleCard(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                      color: AppTheme.primaryColor,
                      size: 28,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Theme',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Current: ${themeProvider.currentThemeName}',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: themeProvider.isDarkMode,
                      onChanged: (value) {
                        themeProvider.toggleTheme();
                      },
                      activeColor: AppTheme.primaryColor,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  'Choose your preferred appearance. Dark mode is easier on the eyes in low-light conditions and may help save battery.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildThemeOption(
                      context,
                      'Light',
                      Icons.light_mode,
                      themeProvider.isLightMode,
                      () => themeProvider.setLightTheme(),
                    ),
                    _buildThemeOption(
                      context,
                      'Dark',
                      Icons.dark_mode,
                      themeProvider.isDarkMode,
                      () => themeProvider.setDarkTheme(),
                    ),
                    _buildThemeOption(
                      context,
                      'System',
                      Icons.brightness_auto,
                      themeProvider.isSystemMode,
                      () => themeProvider.setSystemTheme(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected 
              ? AppTheme.primaryColor.withOpacity(0.1)
              : Colors.transparent,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? AppTheme.primaryColor : Colors.grey[600],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppTheme.primaryColor : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutCard(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppTheme.primaryColor,
                  size: 28,
                ),
                const SizedBox(width: 16),
                Text(
                  'About StyleSense',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            _buildInfoRow('Version', '1.0.0'),
            const SizedBox(height: 12),
            _buildInfoRow('Build', '2024.08.29'),
            const SizedBox(height: 12),
            _buildInfoRow('Developer', 'AI Fashion Assistant'),
            const SizedBox(height: 16),
            Text(
              'StyleSense is your intelligent wardrobe companion that helps you organize your clothes and get personalized outfit recommendations based on weather, occasion, and your unique style preferences.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportCard(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.support_agent,
                  color: AppTheme.primaryColor,
                  size: 28,
                ),
                const SizedBox(width: 16),
                Text(
                  'Support & Feedback',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            _buildSupportItem(
              icon: Icons.bug_report,
              title: 'Report a Bug',
              subtitle: 'Found something that doesn\'t work?',
              onTap: () => _showComingSoonDialog(context, 'Bug Reporting'),
            ),
            const SizedBox(height: 16),
            _buildSupportItem(
              icon: Icons.lightbulb_outline,
              title: 'Suggest a Feature',
              subtitle: 'Have an idea to improve the app?',
              onTap: () => _showComingSoonDialog(context, 'Feature Suggestions'),
            ),
            const SizedBox(height: 16),
            _buildSupportItem(
              icon: Icons.star_outline,
              title: 'Rate the App',
              subtitle: 'Enjoying StyleSense? Leave a review!',
              onTap: () => _showComingSoonDialog(context, 'App Rating'),
            ),
            const SizedBox(height: 16),
            _buildSupportItem(
              icon: Icons.help_outline,
              title: 'Help & FAQ',
              subtitle: 'Get answers to common questions',
              onTap: () => _showComingSoonDialog(context, 'Help Center'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSupportItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Coming Soon!',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        content: Text(
          '$feature will be available in a future update. Stay tuned!',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
