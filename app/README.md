# Kendo Companion app

Flutter application for Kendo Companion, targeting Android and Windows.

## Structure

```text
lib/src/
├── app/       Application composition
├── core/      Database, navigation, theme, and shared UI
└── features/  Feature-first presentation and future feature layers
```

## Development

Use Flutter stable and run:

```sh
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --release
flutter build windows --release
```

Windows development requires Developer Mode so Flutter can create plugin
symlinks.
