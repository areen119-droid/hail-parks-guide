# Hail Parks Guide

A Flutter app that guides tourists around the Hail region of Saudi Arabia:
parks, mountains and nature, and heritage sites. All content is hard-coded in
the app; only the AI guide needs internet and an API key.

## Features

- **Home**: place cards by category, plant of the day, facts about Hail
- **Map**: places on an OpenStreetMap map, filtered by category, with your location
- **Guide (المرشد)**: AI chat about Hail and an AI trip planner (Claude API)
- **Plants**: plants of the region with photos and details
- **Profile**: one built-in account with favorite places and plants (saved on the device)

## Project structure

```
lib/
  main.dart      app entry point
  app/           theme and fonts
  core/          shared constants, widgets, helpers, welcome screen
  data/          hard-coded places, plants, user, facts (hail_data.dart) and the guide prompt
  features/      one folder per feature (home, map, guide, places, plants, profile, settings)
  models/        place, plant, user, and chat models
  providers/     favorites, navigation, and guide state
  services/      Claude API client for the guide
```

To change places, plants, the account, or the facts, edit `lib/data/hail_data.dart`.

## Run

```bash
flutter pub get
flutter run
```

### Turning on the AI guide

1. Copy `api_keys.example.json` to `api_keys.json` and paste your Claude API key
   (from console.anthropic.com) into it. `api_keys.json` is gitignored.
2. Run with the key file:

   ```bash
   flutter run --dart-define-from-file=api_keys.json
   ```

   In Android Studio: Run > Edit Configurations > Additional run args:
   `--dart-define-from-file=api_keys.json`

The key is built into the app, so set a low monthly spending limit on it.
