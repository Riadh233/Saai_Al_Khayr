import "package:flutter/material.dart";


ButtonStyle customButtonStyle({
  required BuildContext context,
  Size size = const Size(300, 48),
  Color? backgroundColor,
  Color? shadowColor,
  double borderRadius = 15.0,
  double elevation = 5.0,
}) {
  final theme = Theme.of(context);

  return ButtonStyle(
    fixedSize: WidgetStateProperty.all<Size>(size),
    backgroundColor: WidgetStateProperty.all<Color>(
      backgroundColor ?? theme.colorScheme.primary,
    ),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    ),
    elevation: WidgetStateProperty.all(elevation),
    shadowColor: WidgetStateProperty.all<Color>(
      shadowColor ?? theme.colorScheme.primary.withOpacity(0.5),
    ),
  );
}

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return  ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF4EC7A6),
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFBFF1E0),
      onPrimaryContainer: Color(0xFF00382C),
      secondary: Color(0xFF2A9D8F),
      onSecondary: Colors.white,
      surface: Colors.white,
      onSurface: Colors.black,
      onSurfaceVariant: Colors.blueGrey[700],
      error: Colors.red,
      onError: Colors.white,
      surfaceTint: Color(0xFF4EC7A6),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }
  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF4EC7A6),
      onPrimary: Colors.black,
      primaryContainer: Color(0xFF00382C),
      onPrimaryContainer: Color(0xFFBFF1E0),
      secondary: Color(0xFF2A9D8F),
      onSecondary: Colors.black,
      surface: Color(0xFF1C1C1E),
      onSurface: Colors.white,
      error: Color(0xFFCF6679),
      onError: Colors.black,
      surfaceTint: Color(0xFF4EC7A6),
      outline: Color(0xFF7A8C89),
      onSurfaceVariant: Color(0xFFC2C2C2),
      outlineVariant: Color(0xFF3A3A3C),
      inverseSurface: Color(0xFFE5E5E5),
      inversePrimary: Color(0xFFBFF1E0),
      shadow: Colors.black,
      scrim: Colors.black,
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }
  ThemeData theme(ColorScheme colorScheme) => ThemeData(
    useMaterial3: true,
    brightness: colorScheme.brightness,
    colorScheme: colorScheme,
    textTheme: textTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    ),
    scaffoldBackgroundColor: colorScheme.surface,
    canvasColor: colorScheme.surface,
  );


  List<ExtendedColor> get extendedColors => [
  ];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}