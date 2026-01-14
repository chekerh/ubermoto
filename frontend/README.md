# UberTaxi Frontend

Flutter frontend application for UberTaxi with JWT authentication and delivery management.

## Features

- JWT Authentication (Login/Register)
- Delivery Management (Create, List, Track)
- State Management with Riverpod
- Secure Token Storage
- Clean Architecture
- Material Design UI

## Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)

### Installation

```bash
cd frontend
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Configuration

Update the API base URL in `lib/config/app_config.dart`:

```dart
static const String baseUrl = 'http://localhost:3000';
```

For Android emulator, use: `http://10.0.2.2:3000`
For iOS simulator, use: `http://localhost:3000`

### Run the App

```bash
flutter run
```

## Project Structure

```
lib/
├── config/           # App configuration
├── core/             # Core utilities
│   ├── constants/
│   ├── errors/
│   └── utils/
├── features/
│   ├── auth/         # Authentication feature
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── delivery/     # Delivery feature
│       ├── data/
│       ├── domain/
│       └── presentation/
├── models/           # Data models
├── services/         # API services
└── widgets/          # Reusable widgets
```

## Testing

```bash
flutter test
```

## Code Generation

After adding new models or Riverpod providers:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## License

MIT
