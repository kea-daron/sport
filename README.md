# Sport App

A Flutter application for live sports scores and news.

## Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK
- A RapidAPI account

### Setup

1. **Get an API Key**
   - Sign up for RapidAPI (or log in)
   - Subscribe to the LiveScore API this app is configured for
   - Copy your API key from the RapidAPI dashboard

2. **Run the App with Your API Key**
   ```bash
   flutter run --dart-define=LIVE_SCORE_API_KEY=your_api_key_here
   ```

3. **For Development (Alternative)**
   - Create a `.env` file in your project root with:
     ```
     LIVE_SCORE_API_KEY=your_api_key_here
     ```

### Features

- Live sports scores and match updates
- Popular leagues and competitions
- Sports news and highlights
- Search functionality
- Multi-sport support

## Troubleshooting

**Getting "403 Forbidden" error?**
- Make sure your API key is valid and active
- Check that you've subscribed to the LiveScore API on RapidAPI
- If you were using the old built-in demo key, it has been removed and you now need your own key
- Verify the key is being passed correctly: `flutter run --dart-define=LIVE_SCORE_API_KEY=your_key`

**API Key Missing error?**
- You must provide an API key to run the app
- Follow the Setup section above to get and configure your key

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [RapidAPI - API Football](https://rapidapi.com/api-sports/api/api-football)
- [Flutter Learning Resources](https://docs.flutter.dev/reference/learning-resources)

