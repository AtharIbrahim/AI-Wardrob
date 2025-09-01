import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:reco_outfit/bloc/theme/theme_bloc.dart';
import 'package:reco_outfit/bloc/wardrobe/wardrobe_bloc.dart';
import 'package:reco_outfit/models/clothing_item.dart';
import 'package:reco_outfit/bloc/wardrobe/wardrobe_state.dart';

void main() {
  group('ThemeBloc Tests', () {
    late ThemeBloc themeBloc;

    setUp(() {
      themeBloc = ThemeBloc();
    });

    tearDown(() {
      themeBloc.close();
    });

    test('initial state is light theme', () {
      expect(
        themeBloc.state,
        equals(const ThemeState(
          isDarkMode: false,
          isDark: false,
          themeData: ThemeData.light(), // Provide a valid ThemeData instance
        )),
      );
    });

    blocTest<ThemeBloc, ThemeState>(
      'emits dark theme when ToggleThemeEvent is added',
      build: () => themeBloc,
      act: (bloc) => bloc.add(ToggleThemeEvent()),
      expect: () => [
        const ThemeState(
          isDarkMode: true,
          isDark: true,
          themeData: ThemeData.dark(),
        )
      ],
    );
  });

  group('WardrobeBloc Tests', () {
    late WardrobeBloc wardrobeBloc;

    setUp(() {
      wardrobeBloc = WardrobeBloc();
    });

    tearDown(() {
      wardrobeBloc.close();
    });

    test('initial state is WardrobeInitial', () {
      expect(wardrobeBloc.state, isA<WardrobeInitial>());
    });

    blocTest<WardrobeBloc, WardrobeState>(
      'loads wardrobe items',
      build: () => wardrobeBloc,
      act: (bloc) => bloc.add(LoadWardrobeEvent()),
      expect: () => [
        WardrobeLoading(),
        isA<WardrobeLoaded>(),
      ],
    );

    blocTest<WardrobeBloc, WardrobeState>(
      'adds clothing item',
      build: () => wardrobeBloc,
      act: (bloc) {
        // First load wardrobe
        bloc.add(LoadWardrobeEvent());
        // Then add item
        bloc.add(AddClothingItemEvent(ClothingItem(
          name: 'Test Item',
          category: ClothingCategory.tops,
          color: 'Blue',
          season: Season.allSeason,
          imagePath: '/test/path',
          tags: ['test'],
          createdAt: DateTime.now(),
        )));
      },
      skip: 2, // Skip initial loading states
      expect: () => [
        isA<WardrobeLoaded>(),
      ],
    );
  });
}
