import "package:flutter/material.dart";
import "package:photos/core/constants.dart";
import "package:photos/models/typedefs.dart";
import "package:photos/utils/debouncer.dart";

class LocationTagStateProvider extends StatefulWidget {
  final Widget child;
  const LocationTagStateProvider(this.child, {super.key});

  @override
  State<LocationTagStateProvider> createState() =>
      _LocationTagStateProviderState();
}

class _LocationTagStateProviderState extends State<LocationTagStateProvider> {
  int selectedRaduisIndex = defaultRadiusValueIndex;
  final Debouncer _selectedRadiusDebouncer =
      Debouncer(const Duration(milliseconds: 300));

  void _updateSelectedIndex(int index) {
    _selectedRadiusDebouncer.cancelDebounce();
    _selectedRadiusDebouncer.run(() async {
      if (mounted) {
        setState(() {
          selectedRaduisIndex = index;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return InheritedLocationTagData(
      selectedRaduisIndex,
      _updateSelectedIndex,
      child: widget.child,
    );
  }
}

class InheritedLocationTagData extends InheritedWidget {
  final int selectedRadiusIndex;
  final VoidCallbackParamInt updateSelectedIndex;
  const InheritedLocationTagData(
    this.selectedRadiusIndex,
    this.updateSelectedIndex, {
    required super.child,
    super.key,
  });

  static InheritedLocationTagData of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<InheritedLocationTagData>()!;
  }

  @override
  bool updateShouldNotify(InheritedLocationTagData oldWidget) {
    return oldWidget.selectedRadiusIndex != selectedRadiusIndex;
  }
}
