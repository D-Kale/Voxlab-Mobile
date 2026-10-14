# Voxlab

Gamified public-speaking trainer built with Flutter. Users follow a learning
path of reading, quiz, writing and oratory exercises, earn XP, and get
AI feedback on writing exercises from the Voxlab backend.

## Run

```sh
flutter pub get
flutter run
```

The app talks to `https://tvoxlab.tech/api/v1` by default. To use a local
backend:

```sh
flutter run --dart-define=API_BASE_URL=http://<host>:3000/api/v1
```

## Develop

```sh
dart run build_runner build --delete-conflicting-outputs   # after editing lib/domain/models
flutter analyze
flutter test
```

See [AGENTS.md](AGENTS.md) for architecture, conventions and testing notes.
