<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

# Elevator

A Flutter package that provides a widget for elevating a widget.

## Features

- Elevate a widget
- Clean elevation removal on mouse exit

## Installation

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  elevator: ^1.0.0
```

## Usage

Here's a simple example of how to use the `Elevator` widget:

```dart
Elevator(
  builder: (elevated) {
    return Card(
      elevation: elevated ? 4 : 1,
      child: Text(
        'Item $index',
      ),
    );
  },
)
```
