# AI Clothing App — Frontend

A Flutter mobile app for AI-powered virtual clothing try-on. Users pick a
photo of a model/person and a photo of a garment, send both to the
[ai_clothing_app backend](../ai_clothing_app), and view the generated
try-on result.

## Features

- Pick a model photo and a garment photo from the device gallery
- Upload both photos to the backend's `/try-on` endpoint
- Display a loading indicator while the try-on request is in progress
- Show the resulting try-on image once it's ready
- Basic error handling with in-app snack bar messages

## Requirements

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart SDK
  `^3.12.2`, see `pubspec.yaml`)
- A running instance of the `ai_clothing_app` backend (see the backend
  project's README)

## Getting started

1. Install dependencies:

   ```bash
   flutter pub get
   ```

2. Point the app at your backend server. The backend URL is currently
   hardcoded in `lib/main.dart`:

   ```dart
   var uri = Uri.parse("http://192.168.100.14:8000/try-on");
   ```

   Replace `192.168.100.14:8000` with the IP address and port where your
   backend is running (e.g. your computer's LAN IP if testing on a physical
   device, or `10.0.2.2:8000` for the Android emulator).

3. Run the app:

   ```bash
   flutter run
   ```

## Project structure

```
lib/main.dart   App entry point and UI (single-screen app)
android/        Android platform project
ios/            iOS platform project
macos/          macOS platform project
windows/        Windows platform project
linux/          Linux platform project
web/            Web platform project
```

## How it works

1. The user taps the model photo box and the garment photo box to pick two
   images from the gallery (via `image_picker`).
2. Once both images are selected, the "Start Try-On" button becomes active.
3. Tapping the button sends both images as a multipart POST request to the
   backend's `/try-on` endpoint (via the `http` package).
4. The backend runs the IDM-VTON model on Replicate and returns the
   generated image, which is displayed at the bottom of the screen.

## Dependencies

- [`image_picker`](https://pub.dev/packages/image_picker) — pick images
  from the gallery
- [`http`](https://pub.dev/packages/http) — send multipart requests to the
  backend

## Notes

- This app currently supports only picking images from the gallery (no
  camera capture).
- The backend URL is hardcoded for local development; consider moving it
  to a config file or environment-based setting before shipping to
  production.
