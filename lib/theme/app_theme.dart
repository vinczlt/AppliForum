import 'package:material_ui/material_ui.dart';

// Couleurs partagées : une modification ici se répercute sur les écrans.
const background = Color(0xFF0C0C0C);
const panel = Color(0xFF141416);
const outline = Color(0xFF29292E);
const muted = Color(0xFF9999A3);

// Règles visuelles communes : champs, boutons, fond et barre du haut.
ThemeData buildAppTheme() => ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: background,
  colorScheme: const ColorScheme.dark(
    primary: Colors.white,
    onPrimary: background,
    surface: panel,
    outline: outline,
  ),
  useMaterial3: true,
  appBarTheme: const AppBarTheme(
    backgroundColor: background,
    surfaceTintColor: Colors.transparent,
  ),
  dividerColor: outline,
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: panel,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: outline),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: outline),
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 17),
      textStyle: const TextStyle(fontWeight: FontWeight.w600),
    ),
  ),
);
