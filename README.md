# Hail Parks Guide

A Flutter app that guides tourists around the Hail region of Saudi Arabia:
parks first, plus mountains and nature, heritage sites, restaurants and cafes.
Everything runs on the device; no backend, no API keys.

## Features

- **Home**: parks first, other places by category, where to eat, plant of the day, facts
- **Map**: places on an OpenStreetMap map, filtered by category, with your location
- **Guide (المرشد)**: a chatbot trained on Hail questions, and a trip planner
- **Plants**: plants of the region with photos and details
- **Profile**: one built-in account with favorite places and plants (saved on the device)

## The guide's AI model

The guide uses a small neural network trained on our own data to recognize
what a visitor is asking (an "intent"), then answers with our text and places.
It runs on the phone with TensorFlow Lite, so it works offline.

```
ml/
  intents.json        training data: intents, example questions, replies, places to show
  features.py         turns text into model inputs (repeated exactly in Dart)
  train_guide.ipynb   Colab notebook that trains and exports the model
  build_notebook.py   regenerates the notebook from features.py
assets/ml/            the trained model and its vocabulary (from the notebook)
```

To retrain after editing `ml/intents.json`:

1. Open `ml/train_guide.ipynb` in Google Colab and run all cells.
2. Upload `ml/intents.json` when asked.
3. Unzip the downloaded `hail_guide_model.zip` into `assets/ml/`.
4. Run `flutter test`. `guide_features_test.dart` checks the app processes
   text exactly like the training code did.

The trip planner doesn't use the model: it picks places from the answers with
rules (interests, who's coming, distance) in `lib/services/trip_planner.dart`.

## Project structure

```
lib/
  main.dart      app entry point
  app/           theme and fonts
  core/          shared constants, widgets, helpers, welcome screen
  data/          hard-coded places, plants, user and facts (hail_data.dart)
  features/      one folder per feature (home, map, guide, places, plants, profile, settings)
  models/        place, plant, user, and chat models
  providers/     favorites, navigation, and guide state
  services/      the guide's model, chatbot replies and trip planner
```

To change places, plants, the account, or the facts, edit `lib/data/hail_data.dart`.

## Run

```bash
flutter pub get
flutter run
```
