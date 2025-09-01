import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/weather.dart';
import '../utils/responsive_utils.dart';

class WeatherCard extends StatelessWidget {
  final Weather weather;
  final VoidCallback? onRefresh;
  final VoidCallback? onLocationUpdate;
  final bool showLocationButton;

  const WeatherCard({
    super.key,
    required this.weather,
    this.onRefresh,
    this.onLocationUpdate,
    this.showLocationButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context),
        gradient: _getWeatherGradient(),
        boxShadow: [
          BoxShadow(
            color: _getWeatherGradient().colors[0].withOpacity(0.3),
            blurRadius: ResponsiveUtils.getResponsiveElevation(context),
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: ResponsiveUtils.getResponsivePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with location and actions
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(ResponsiveUtils.getResponsiveValue(context, mobile: 12, tablet: 16, desktop: 20)),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context),
                  ),
                  child: Icon(
                    _getWeatherIcon(),
                    size: ResponsiveUtils.getResponsiveValue(context, mobile: 28, tablet: 32, desktop: 36),
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: ResponsiveUtils.getResponsiveValue(context, mobile: 16, tablet: 20, desktop: 24)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        weather.location,
                        style: GoogleFonts.inter(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(context, base: 16, tablet: 18, desktop: 20),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 4, tablet: 6, desktop: 8)),
                      Row(
                        children: [
                          Text(
                            weather.description.toUpperCase(),
                            style: GoogleFonts.inter(
                              fontSize: ResponsiveUtils.getResponsiveFontSize(context, base: 11, tablet: 12, desktop: 13),
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(width: ResponsiveUtils.getResponsiveValue(context, mobile: 8, tablet: 10, desktop: 12)),
                          Text(
                            weather.emoji,
                            style: TextStyle(fontSize: ResponsiveUtils.getResponsiveFontSize(context, base: 14, tablet: 16, desktop: 18)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (showLocationButton && onLocationUpdate != null)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveValue(context, mobile: 12, tablet: 14, desktop: 16)),
                    ),
                    child: IconButton(
                      onPressed: onLocationUpdate,
                      icon: Icon(
                        Icons.my_location_rounded, 
                        color: Colors.white,
                        size: ResponsiveUtils.getResponsiveIconSize(context),
                      ),
                      tooltip: 'Use current location',
                    ),
                  ),
                SizedBox(width: ResponsiveUtils.getResponsiveValue(context, mobile: 8, tablet: 10, desktop: 12)),
                if (onRefresh != null)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveValue(context, mobile: 12, tablet: 14, desktop: 16)),
                    ),
                    child: IconButton(
                      onPressed: onRefresh,
                      icon: Icon(
                        Icons.refresh_rounded, 
                        color: Colors.white,
                        size: ResponsiveUtils.getResponsiveIconSize(context),
                      ),
                      tooltip: 'Refresh weather',
                    ),
                  ),
              ],
            ),
            
            SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 24, tablet: 28, desktop: 32)),
            
            // Temperature and details
            ResponsiveWidget(
              mobile: _buildMobileTemperatureLayout(context),
              tablet: _buildTabletTemperatureLayout(context),
              desktop: _buildDesktopTemperatureLayout(context),
            ),
            
            SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 24, tablet: 28, desktop: 32)),
            
            // Weather suggestion
            _buildResponsiveWeatherSuggestion(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileTemperatureLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                weather.temperatureInCelsius,
                style: GoogleFonts.inter(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, base: 42),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1,
                ),
              ),
              SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 8, tablet: 10, desktop: 12)),
              Text(
                'Feels like ${weather.temperatureInCelsius}',
                style: GoogleFonts.inter(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, base: 13),
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [
              _buildWeatherDetail(
                context,
                Icons.water_drop_rounded,
                'Humidity',
                '${weather.humidity}%',
              ),
              SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 16, tablet: 18, desktop: 20)),
              _buildWeatherDetail(
                context,
                Icons.thermostat_rounded,
                'Feels Like',
                weather.temperatureInCelsius,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabletTemperatureLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                weather.temperatureInCelsius,
                style: GoogleFonts.inter(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, base: 48),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1,
                ),
              ),
              SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 8, tablet: 10, desktop: 12)),
              Text(
                'Feels like ${weather.temperatureInCelsius}',
                style: GoogleFonts.inter(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, base: 14),
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildWeatherDetail(
                context,
                Icons.water_drop_rounded,
                'Humidity',
                '${weather.humidity}%',
              ),
              _buildWeatherDetail(
                context,
                Icons.thermostat_rounded,
                'Feels Like',
                weather.temperatureInCelsius,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopTemperatureLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                weather.temperatureInCelsius,
                style: GoogleFonts.inter(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, base: 54),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1,
                ),
              ),
              SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 8, tablet: 10, desktop: 12)),
              Text(
                'Feels like ${weather.temperatureInCelsius}',
                style: GoogleFonts.inter(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, base: 16),
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildWeatherDetail(
                context,
                Icons.water_drop_rounded,
                'Humidity',
                '${weather.humidity}%',
              ),
              _buildWeatherDetail(
                context,
                Icons.thermostat_rounded,
                'Feels Like',
                weather.temperatureInCelsius,
              ),
              _buildWeatherDetail(
                context,
                Icons.air_rounded,
                'Wind',
                'Light',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherDetail(BuildContext context, IconData icon, String label, String value) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(ResponsiveUtils.getResponsiveValue(context, mobile: 8, tablet: 10, desktop: 12)),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveValue(context, mobile: 12, tablet: 14, desktop: 16)),
          ),
          child: Icon(
            icon, 
            color: Colors.white, 
            size: ResponsiveUtils.getResponsiveValue(context, mobile: 18, tablet: 20, desktop: 22),
          ),
        ),
        SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 8, tablet: 10, desktop: 12)),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, base: 13, tablet: 14, desktop: 15),
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, base: 9, tablet: 10, desktop: 11),
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildResponsiveWeatherSuggestion(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: ResponsiveUtils.getResponsivePadding(context),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(ResponsiveUtils.getResponsiveValue(context, mobile: 8, tablet: 10, desktop: 12)),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveValue(context, mobile: 8, tablet: 10, desktop: 12)),
            ),
            child: Icon(
              Icons.lightbulb_rounded,
              color: Colors.white,
              size: ResponsiveUtils.getResponsiveValue(context, mobile: 16, tablet: 18, desktop: 20),
            ),
          ),
          SizedBox(width: ResponsiveUtils.getResponsiveValue(context, mobile: 12, tablet: 16, desktop: 20)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Style Tip',
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, base: 12, tablet: 13, desktop: 14),
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: ResponsiveUtils.getResponsiveValue(context, mobile: 2, tablet: 4, desktop: 6)),
                Text(
                  weather.clothingAdvice,
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, base: 11, tablet: 12, desktop: 13),
                    fontWeight: FontWeight.w400,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  LinearGradient _getWeatherGradient() {
    if (weather.isSunny) {
      return const LinearGradient(
        colors: [Color(0xFFFFB74D), Color(0xFFFF8A50)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (weather.isRainy) {
      return const LinearGradient(
        colors: [Color(0xFF64B5F6), Color(0xFF1976D2)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (weather.isSnowy) {
      return const LinearGradient(
        colors: [Color(0xFF90A4AE), Color(0xFF546E7A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (weather.isCloudy) {
      return const LinearGradient(
        colors: [Color(0xFF78909C), Color(0xFF455A64)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else {
      return const LinearGradient(
        colors: [Color(0xFF42A5F5), Color(0xFF1565C0)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
  }

  IconData _getWeatherIcon() {
    if (weather.isSunny) {
      return Icons.wb_sunny_rounded;
    } else if (weather.isRainy) {
      return Icons.umbrella_rounded;
    } else if (weather.isSnowy) {
      return Icons.ac_unit_rounded;
    } else if (weather.isCloudy) {
      return Icons.cloud_rounded;
    } else {
      return Icons.wb_cloudy_rounded;
    }
  }
}
