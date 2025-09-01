# 🤖 AI-Powered Digital Wardrobe & Outfit Recommendation App

An intelligent Flutter application that uses **Mistral AI** to provide personalized outfit recommendations based on your wardrobe, weather conditions, occasion, and mood preferences.

## ✨ Features

### 🧠 AI-Powered Recommendations
- **Smart Outfit Generation**: AI analyzes your wardrobe to create stylish combinations
- **Weather-Aware Styling**: Considers current weather for appropriate clothing suggestions
- **Occasion-Specific Outfits**: Tailored recommendations for work, casual, party, formal events
- **Mood-Based Styling**: Adapts to your desired mood and confidence level
- **AI Insights**: Detailed reasoning behind each recommendation with confidence scores

### 📱 Core Features
- **Digital Wardrobe Management**: Add, organize, and categorize clothing items
- **Smart Categorization**: Automatic sorting by type, season, color, and tags
- **Weather Integration**: Real-time weather data influences styling decisions
- **Saved Outfits**: Save and organize your favorite combinations
- **Responsive Design**: Optimized for phones, tablets, and desktops

### 🎯 User Experience
- **Intuitive Interface**: Clean, modern Material Design 3 UI
- **Quick Setup**: Load sample data or add items via camera
- **Flexible Filtering**: Browse by category, season, or search
- **Offline Capable**: Smart fallback system when AI is unavailable

## 🚀 Quick Setup

### 1. Get Your Mistral AI API Key (Free)
1. Visit [Mistral AI Console](https://console.mistral.ai/)
2. Create a free account
3. Generate an API key
4. Copy your key

### 2. Configure the App
1. Open `.env` file in the project root
2. Replace the placeholder with your actual API key:
   ```env
   MISTRAL_API_KEY=your_actual_api_key_here
   ```

### 3. Run the App
```bash
flutter pub get
flutter run
```

## 📖 How to Use

### Getting Started
1. **Load Sample Data**: Tap "Load Test Data" for instant setup
2. **Add Your Items**: Use "Add Clothing" to build your wardrobe
3. **Get Recommendations**: Choose occasion & mood, then tap "Get Recommendations"

### AI Recommendations Process
1. **Set Context**: Select occasion (Casual, Work, Party, etc.) and mood (Confident, Comfortable, etc.)
2. **AI Analysis**: Mistral AI analyzes your wardrobe, weather, and preferences
3. **Smart Suggestions**: Receive 3-5 personalized outfit combinations
4. **Detailed Insights**: Each recommendation includes:
   - AI reasoning and style analysis
   - Confidence score (0-100%)
   - Style tags and fashion tips
   - Weather appropriateness

### Managing Your Wardrobe
- **Categories**: Tops, Bottoms, Dresses, Outerwear, Shoes, Accessories
- **Seasons**: Spring, Summer, Autumn, Winter, All Season
- **Tags**: Add descriptive tags like "formal", "casual", "warm", "breathable"
- **Colors**: Accurate color information helps with coordination

## 🔧 Technical Details

### Architecture
- **Frontend**: Flutter with Material Design 3
- **AI Service**: Mistral AI integration with fallback system
- **Storage**: Local SQLite database with SharedPreferences backup
- **State Management**: Provider pattern for reactive UI

### AI Integration
- **Primary**: Mistral AI API for intelligent recommendations
- **Fallback**: Enhanced rule-based system for offline/API-unavailable scenarios
- **Smart Prompting**: Context-aware prompts for better AI responses
- **Error Handling**: Graceful degradation with informative user feedback

### Data Storage
- **Local Database**: SQLite for persistent wardrobe data
- **Metadata Support**: AI insights and user preferences
- **Backup System**: SharedPreferences fallback for reliability

## 🛠️ Development

### Prerequisites
- Flutter 3.8.1 or higher
- Dart 3.0+
- Android Studio / VS Code
- Mistral AI API key (free tier available)

### Project Structure
```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
├── services/                 # AI, storage, weather services
├── providers/                # State management
├── screens/                  # UI screens
└── widgets/                  # Reusable components
```

### Key Services
- `AIRecommendationService`: Mistral AI integration
- `StorageService`: Local data persistence
- `WeatherService`: Weather data for styling
- `WardrobeProvider`: Central state management

## 🚨 Troubleshooting

### No Recommendations Generated
- ✅ Check API key is correctly set in `.env`
- ✅ Ensure you have clothing items in your wardrobe
- ✅ Verify internet connection
- ✅ App automatically falls back to smart rules if AI unavailable

### Performance Issues
- ✅ Reduce number of clothing items if app is slow
- ✅ Clear app data and reload if needed
- ✅ Check device storage space

### API Errors
- ✅ Verify Mistral AI account has available credits
- ✅ Check API key permissions
- ✅ App continues working with fallback system

## 🌟 Advanced Features

### Customization Options
- **AI Prompts**: Modify prompts in `ai_recommendation_service.dart`
- **Styling Rules**: Adjust fallback logic for your preferences
- **UI Themes**: Customize colors and layouts
- **Categories**: Add new clothing types or seasons

### Future Enhancements
- [ ] Machine learning for user preference learning
- [ ] Social sharing of outfits
- [ ] Shopping suggestions for missing items
- [ ] Advanced weather integration
- [ ] Voice-controlled outfit requests

## 📱 Supported Platforms
- ✅ Android
- ✅ iOS  
- ✅ Web (PWA)
- ✅ Windows
- ✅ macOS
- ✅ Linux

## 🎉 Getting the Best Results

### Wardrobe Tips
- Add detailed, descriptive tags to items
- Include accurate colors and seasons
- Organize by categories for better matching
- Keep wardrobe updated with new purchases

### AI Optimization
- Try different mood combinations
- Experiment with various occasions
- Save outfits you love for future reference
- Provide feedback through rating system

## 📝 License
This project is for educational and personal use. Please respect Mistral AI's terms of service when using their API.

## 🤝 Contributing
Contributions are welcome! Please feel free to submit issues, feature requests, or pull requests.

---

**Start building your intelligent wardrobe today!** 🌟

With AI-powered recommendations, you'll never have to wonder "what to wear" again. The app learns your style preferences and helps you create amazing outfits from your existing wardrobe.

*Powered by Mistral AI* 🤖
