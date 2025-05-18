# Secure Notes App

A minimal yet secure Flutter application that allows users to store and manage personal text notes protected by a 4-digit PIN.

## Features

- 🔒 Secure PIN Authentication
  - 4-digit PIN setup on first launch
  - Secure PIN storage using encryption
  - Session-based authentication
- 📝 Notes Management
  - Create, edit, and delete notes
  - Title and content support
  - Responsive grid layout
  - Local data persistence
- 🎨 User Interface
  - Clean and minimal design
  - Dark/Light theme toggle
  - Intuitive navigation
  - Smooth animations
- 🔄 Additional Features
  - "Forgot PIN?" option with data reset
  - Last modified timestamps
  - Unsaved changes detection
  - Responsive layout for different screen sizes

## Setup Instructions

1. Make sure you have Flutter installed on your machine. If not, follow the [official installation guide](https://flutter.dev/docs/get-started/install).

2. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/secure_notes_app.git
   cd secure_notes_app
   ```

3. Install dependencies:
   ```bash
   flutter pub get
   ```

4. Run the app:
   ```bash
   flutter run
   ```

## Dependencies

- `provider`: ^6.0.5 - State management
- `flutter_secure_storage`: ^8.0.0 - Secure PIN storage
- `shared_preferences`: ^2.2.2 - Theme preference storage
- `sqflite`: ^2.3.2 - Local database for notes
- `path`: ^1.8.3 - Database path handling
- `uuid`: ^4.1.0 - Unique ID generation
- `flutter_staggered_grid_view`: ^0.7.0 - Responsive grid layout
- `intl`: ^0.19.0 - Date formatting
- `crypto`: ^3.0.3 - PIN hashing
- `google_fonts`: ^6.1.0 - Custom fonts

## Security Features

- PIN is hashed using SHA-256 before storage
- Notes are stored in a local SQLite database
- PIN is stored in secure storage (Keychain for iOS, EncryptedSharedPreferences for Android)
- Session-based authentication
- No cloud sync to ensure data stays on device

## Architecture

The app follows a clean architecture pattern with:
- Models: Data structures
- Providers: State management
- Services: Business logic
- Screens: UI components

## Assumptions & Decisions

1. PIN Requirements:
   - Exactly 4 digits
   - Numeric only
   - No biometric authentication (for simplicity)

2. Data Storage:
   - Local storage only for privacy
   - SQLite for notes
   - Secure storage for PIN

3. User Experience:
   - Grid layout for better note overview
   - Dark mode support
   - Relative timestamps for better readability

## Contributing

Feel free to submit issues and enhancement requests!
