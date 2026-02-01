# Playcado

Playcado is a Jellyfin client built with Flutter.

<img src="https://github.com/JchrisM12/playcado-dev/blob/main/demo/demo.gif" width="250" />      <img src="https://github.com/JchrisM12/playcado-dev/blob/main/demo/demo 2.gif" width="250" />


## Features

### Library Browsing
* Dashboard including Continue Watching, Next Up, and Recently Added.
* Paginated grids for Movies and TV Shows with multiple sorting options.
* Full series support including season navigation and episode metadata.
* Integrated search for movies, series, and individual episodes.

### Playback
* Hardware-accelerated video playback via media_kit and mpv.
* On-the-fly selection for audio tracks and subtitles.
* Automated playback reporting to the Jellyfin server.
* Skip intro support for compatible TV episodes.

### Casting
* Google Cast integration for streaming to Chromecast and Android TV devices.
* Remote control interface for managing playback on casted devices.
* Automatic discovery of cast-enabled devices on the local network.

### Offline Media
* Download manager for movies and episodes using background_downloader.
* Persistent downloads that continue even when the app is minimized.
* Dedicated offline mode for accessing local media without a server connection.

### Customization and Security
* Secure credential storage using the device's hardware keystore.
* Support for multiple server accounts and easy account switching.
* Dynamic theme engine with custom seed color selection.
* Developer tools for connectivity testing and storage management.

## Tech Stack

* Framework: Flutter 3.8.0+
* State Management: Bloc (flutter_bloc)
* Navigation: go_router
* Video Engine: media_kit (mpv-based)
* API Client: [jellyfin_dart](https://github.com/JchrisM12/jellyfin-dart) (Custom fork based on [devaryakjha/jellyfin-dart](https://github.com/devaryakjha/jellyfin-dart))
* Persistence: [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage) & custom JSON-based `PreferencesService`
* Downloads: [background_downloader](https://pub.dev/packages/background_downloader)
* Casting: [flutter_chrome_cast](https://pub.dev/packages/flutter_chrome_cast)
* Error Tracking: [Sentry](https://sentry.io/)
* Design: Material 3 with Google Fonts (Plus Jakarta Sans)

## Setup and Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/JchrisM12/playcado.git
   cd playcado
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Configure secrets:
   Copy the example secrets file and add your configuration:
   ```bash
   mkdir -p config
   cp config/secrets_dev.json.example config/secrets_dev.json
   # Edit config/secrets_dev.json with your SENTRY_DSN
   ```

4. Generate serialized models:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

5. Configure environment:
   The project uses Flutter flavors and environment-mapped secrets via `--dart-define-from-file`.

## Development

### Running the App
To run the development build with secrets:
```bash
flutter run --flavor dev --dart-define-from-file=config/secrets_dev.json
```

### Build Commands
To build release versions for production:

Android:
```bash
flutter build appbundle --flavor prod --release --dart-define-from-file=config/secrets_prod.json
```

iOS:
```bash
flutter build ios --flavor prod --release --dart-define-from-file=config/secrets_prod.json
```

### Sort Arb Files
```bash
dart pub global activate arb_utils
arb_utils sort -n lib/l10n/app_en.arb
```

## Requirements

* Flutter SDK: ^3.6.0
* Jellyfin Server: v10.8.0 or higher
* Android: API Level 21+
* iOS: iOS 14.0+

## Permissions
Playcado requires the following permissions for full functionality:
* Local Network: Used to discover Google Cast devices.
* Notifications: Used to display download progress on Android.
* Storage: Used for saving offline media files.

## License
This project is licensed under the MIT License. See the LICENSE file for details.