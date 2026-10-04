# Hail Parks Guide

A Flutter app that guides tourists around the parks of Hail. All content is
hard-coded in the app, so it runs without a backend or any API keys.

## Features

- **Home**: park cards, plant of the day, and facts about Hail
- **Map**: park locations on an OpenStreetMap map, with your current location
- **Plants**: plants of the region with photos and details
- **Profile**: one built-in account with favorite parks and plants (saved on the device)

## Project structure

```
lib/
  main.dart      app entry point
  core/          shared constants, widgets, splash screen
  data/          hard-coded parks, plants, user, and facts (hail_data.dart)
  features/      one folder per feature (home, map, parks, plants, profile, settings)
  models/        park, plant, and user models
  providers/     favorites provider
```

To change parks, plants, the account, or the facts, edit `lib/data/hail_data.dart`.

## Run

```bash
flutter pub get
flutter run
```
