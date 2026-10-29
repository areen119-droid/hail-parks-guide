import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hail_parks_guide/models/place_model.dart';
import 'package:hail_parks_guide/models/plant_model.dart';
import 'package:hail_parks_guide/providers/favorites_provider.dart';
import 'package:hail_parks_guide/providers/navigation_provider.dart';

/// Toggles a favorite place and tells the user what happened.
void toggleFavoritePlace(BuildContext context, PlaceModel place) {
  final favorites = context.read<FavoritesProvider>();
  final adding = !favorites.isFavoritePlace(place.id);
  favorites.togglePlace(place.id);
  _confirm(context, place.name, adding,
      undo: () => favorites.togglePlace(place.id));
}

/// Toggles a favorite plant and tells the user what happened.
void toggleFavoritePlant(BuildContext context, Plant plant) {
  final favorites = context.read<FavoritesProvider>();
  final adding = !favorites.isFavoritePlant(plant.id);
  favorites.togglePlant(plant.id);
  _confirm(context, plant.name, adding,
      undo: () => favorites.togglePlant(plant.id));
}

void _confirm(BuildContext context, String name, bool added,
    {required VoidCallback undo}) {
  final messenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);
  final nav = context.read<NavigationProvider>();

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      duration: const Duration(seconds: 3),
      content: Text(added ? 'أُضيف «$name» إلى مفضلتك' : 'أُزيل «$name» من مفضلتك'),
      action: added
          ? SnackBarAction(
              label: 'عرض المفضلة',
              onPressed: () {
                navigator.popUntil((route) => route.isFirst);
                nav.selectTab(NavigationProvider.profileTab);
              },
            )
          : SnackBarAction(label: 'تراجع', onPressed: undo),
    ));
}
