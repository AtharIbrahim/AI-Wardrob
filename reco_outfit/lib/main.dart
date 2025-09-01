import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'providers/wardrobe_provider.dart';
import 'providers/theme_provider.dart';
import 'bloc/theme/theme_bloc.dart';
import 'bloc/wardrobe/wardrobe_bloc.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/wardrobe_screen.dart';
import 'screens/recommendations_screen.dart';
import 'screens/outfits_screen.dart';
import 'screens/add_clothing_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print('Warning: Could not load .env file: $e');
  }
  
  runApp(const RecoOutfitApp());
}

class RecoOutfitApp extends StatelessWidget {
  const RecoOutfitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Theme Provider
        ChangeNotifierProvider(
          create: (context) => ThemeProvider()..initialize(),
        ),
        // Wardrobe Provider
        ChangeNotifierProvider(
          create: (context) => WardrobeProvider()..initialize(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          // Theme BLoC
          BlocProvider(
            create: (context) => ThemeBloc()..add(LoadThemeEvent()),
          ),
          // Wardrobe BLoC
          BlocProvider(
            create: (context) => WardrobeBloc()..add(LoadWardrobeEvent()),
          ),
        ],
        child: Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return MaterialApp(
              title: 'RecoOutfit - AI Digital Wardrobe',
              debugShowCheckedModeBanner: false,
              themeMode: themeProvider.themeMode,
              theme: themeProvider.lightTheme,
              darkTheme: themeProvider.darkTheme,
              home: const SplashScreen(),
              routes: {
                '/home': (context) => const HomeScreen(),
                '/wardrobe': (context) => const WardrobeScreen(),
                '/recommendations': (context) => const RecommendationsScreen(),
                '/outfits': (context) => const OutfitsScreen(),
                '/add-clothing': (context) => const AddClothingScreen(),
                '/settings': (context) => const SettingsScreen(),
              },
            );
          },
        ),
      ),
    );
  }
}
