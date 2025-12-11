# Project Coding Rules for "Millime" Flutter App

## Overview
This document defines the coding standards and architectural patterns for the "Millime" Flutter mobile banking application. These rules ensure consistency across AI-generated code sessions and maintain the project's architectural integrity.

## 1. Project Structure

### Directory Hierarchy
Follow the structure defined in `hierarchy.txt`:

```
lib/
├── core/
│   ├── utils/
│   │   ├── image_constant.dart
│   │   ├── navigator_service.dart
│   │   └── size_utils.dart
│   └── app_export.dart
├── presentation/
│   └── [screen_name]_screen/
│       ├── models/
│       │   └── [screen_name]_model.dart
│       ├── provider/
│       │   └── [screen_name]_provider.dart
│       ├── widgets/ (optional)
│       │   └── [widget_name]_widget.dart
│       └── [screen_name]_screen.dart
├── routes/
│   └── app_routes.dart
├── theme/
│   ├── text_style_helper.dart
│   └── theme_helper.dart
├── widgets/
│   └── custom_[widget_name].dart
└── main.dart
```

### File Naming Conventions
- **Directories**: snake_case (e.g., `account_dashboard_screen`)
- **Dart files**: snake_case with `.dart` extension
- **Classes**: PascalCase (e.g., `AccountTypeSelectionScreen`)
- **Enums**: PascalCase (e.g., `AccountType`)
- **Methods/Functions**: camelCase (e.g., `selectAccountType`)
- **Variables**: camelCase (e.g., `selectedAccountType`)
- **Constants**: UPPER_SNAKE_CASE (e.g., `ImageConstant.imgPP`)

## 2. State Management

### Provider Pattern Usage
Use the Provider pattern only when necessary:
- **Use Provider for**: Complex state management, shared state between widgets, data persistence, network operations
- **Don't use Provider for**: Simple form inputs, local widget state, static content display

```dart
class [ScreenName]Provider extends ChangeNotifier {
  [ScreenName]Model [screenName]Model = [ScreenName]Model();

  void initialize() {
    // Initialize default values
    notifyListeners();
  }

  void [actionMethod]() {
    // Update model
    notifyListeners();
  }

  void navigateToNextScreen(BuildContext context) {
    // Navigation logic
  }
}
```

### Screen Structure
Screens MUST follow this pattern:

```dart
class [ScreenName]Screen extends StatefulWidget {
  static Widget builder(BuildContext context) {
    return ChangeNotifierProvider<[ScreenName]Provider>(
      create: (context) => [ScreenName]Provider(),
      child: [ScreenName]Screen(),
    );
  }

  @override
  State<[ScreenName]Screen> createState() => _[ScreenName]ScreenState();
}

class _[ScreenName]ScreenState extends State<[ScreenName]Screen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<[ScreenName]Provider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<[ScreenName]Provider>(
        builder: (context, provider, child) {
          return // UI components
        },
      ),
    );
  }
}
```

## 3. Models

### Model Structure
Models MUST be simple data classes:

```dart
// ignore_for_file: must_be_immutable
class [ModelName]Model {
  [ModelName]Model({
    this.[property],
  }) {
    [property] = [property] ?? [defaultValue];
  }

  [DataType]? [property];
}
```

### Enums
Use enums for fixed sets of values:

```dart
enum [EnumName] {
  [value1],
  [value2],
}
```

## 4. Theming and Styling

### Colors
- **PRIMARY RULE**: Use semantic color names from `appTheme` (e.g., `appTheme.primaryColor`, `appTheme.onBackground`)
- **AVOID**: Direct usage of raw color names like `cyan_900`, `black_900` - use semantic equivalents instead
- **SEMANTIC COLOR SYSTEM**:
  - `primaryColor`: Main brand color (dark teal)
  - `primaryVariant`: Secondary brand color (medium teal)
  - `secondaryColor`: Alternative accent color
  - `backgroundColor`: Main app background (white)
  - `surfaceColor`: Card/surface backgrounds (light gray)
  - `onBackground`: Primary text on backgrounds (black)
  - `onSurface`: Secondary text on surfaces (medium gray)
  - `onSurfaceVariant`: Tertiary text (dark gray)
  - `errorColor`: Error states (bright red)
  - `errorContainer`: Error backgrounds (light pink)
  - `successColor`: Success states (teal)
  - `borderColor`: Borders and outlines (light gray)
  - `dividerColor`: Dividers and separators (medium gray)
  - `disabledColor`: Disabled elements (medium gray)
  - `overlayLight`: Light overlays (semi-transparent white)
  - `overlayDark`: Dark overlays (semi-transparent black)
  - `transparent`: Full transparency
- **LEGACY COLORS**: Raw color names (e.g., `cyan_900`, `white_A700`) are deprecated but kept for backward compatibility
- **CUSTOM COLORS**: Follow pattern `color[HexValue]` or `color[Name]` for app-specific colors
- **OPACITY COLORS**: Pattern `color[Name][Opacity]` (e.g., `color7FFFFF` for 50% white)

### Text Styles
- Use `TextStyleHelper.instance.[styleName]` from `text_style_helper.dart`
- Style naming: `[category][Size][Weight][FontFamily]`
  - Categories: display, headline, title, body, label
  - Sizes: numeric (e.g., 14, 16, 18)
  - Weights: Regular, Medium, SemiBold, Bold, ExtraBold
  - Fonts: Manrope, Quicksand, Syne, etc.

### Responsive Sizing
- Use `.h` for height/width (e.g., `16.h`)
- Use `.fSize` for font sizes (e.g., `14.fSize`)
- Import from `size_utils.dart`

## 5. Navigation

### Route Definitions
- Define routes in `app_routes.dart` using constants
- Use builder pattern for screen constructors
- Initial route: `AppRoutes.initialRoute`

```dart
class AppRoutes {
  static const String [screenName]Screen = '/[screen_name]_screen';

  static Map<String, WidgetBuilder> get routes => {
    [screenName]Screen: [ScreenName]Screen.builder,
  };
}
```

### Navigation Service
- Use `NavigatorService.pushNamed()` for navigation
- Avoid direct `Navigator.of(context)` calls

## 6. Widgets

### Custom Widgets
- Place reusable widgets in `widgets/` directory
- Name: `custom_[widget_name].dart`
- Follow Flutter widget conventions

### Screen-Specific Widgets
- Place in `presentation/[screen_name]_screen/widgets/`
- Name: `[widget_name]_widget.dart`

## 7. Assets and Images

### Image Constants
- Define all image paths in `core/utils/image_constant.dart`
- Use `ImageConstant.[imageName]` in code
- Follow naming: `img_[description]`

### Asset Organization
- Images in `assets/images/`
- Subdirectories: `svg/`, `png/`, `empty/`, `Icons/`

### App Icon and Branding
- **App Name**: "Millime"
- **App Icon**: `assets/images/millime_logo.png`
- **Icon Generation**: Uses `flutter_launcher_icons` package
- **Icon Command**: `flutter pub run flutter_launcher_icons`
- **Supported Platforms**: Android, iOS, Web

## 8. Imports

### App Export
- Import `core/app_export.dart` in all files
- This provides access to: provider, navigator_service, theme, text_styles, image_constants, size_utils, custom_image_view

### Specific Imports
- Import models, providers, and widgets as needed
- Use relative imports within the same feature directory

## 9. Code Patterns

### Builder Methods
- Use static `builder` methods for screen constructors
- Wrap with `ChangeNotifierProvider`

### Initialization
- Always call `initialize()` in `initState` with `addPostFrameCallback`

### Consumer Pattern
- Wrap UI components with `Consumer<ProviderType>`
- Access provider data through the `provider` parameter

### Error Handling
- Use `ScaffoldMessenger` for snackbars
- Handle null values with default assignments

### Layout Patterns
- Use `Column` with `Expanded` and `SingleChildScrollView` for scrollable content
- Use `SizedBox` with `.h` for spacing
- Use `Padding` with `.h` values
#### Form Button Placement
- Place form action buttons at the bottom of the screen within a `SafeArea`
- Use `ElevatedButton` for primary actions, `OutlinedButton` for secondary actions
- Ensure buttons remain visible and accessible when the keyboard is shown
- Maintain consistent spacing (16.h) between form fields and buttons
- For forms with multiple buttons, place the primary action button first (rightmost in LTR layouts)

## 10. Localization

### Language
- Primary language: French
- Use French text in UI strings
- Keep code comments in English

## 11. Critical Sections

### Orientation Lock
- Device orientation MUST be locked to portrait in `main.dart`
- Comment: `// 🚨 CRITICAL: Device orientation lock - DO NOT REMOVE`

### Text Scaling
- Text scaling MUST be disabled in `main.dart`
- Comment: `// 🚨 CRITICAL: NEVER REMOVE OR MODIFY`

## 12. Dependencies

### Core Dependencies
- flutter: SDK
- provider: ^6.1.2 (state management)
- flutter_svg: ^2.0.12 (SVG support)
- cached_network_image: ^3.4.1 (image caching)
- shared_preferences: ^2.3.3 (local storage)
- connectivity_plus: ^6.1.0 (network status)
- gradient_borders: ^1.0.2 (gradient borders)
- flutter_localizations: SDK (localization)

### Development Dependencies
- flutter_lints: ^5.0.0 (linting)

## 13. Analysis and Linting

### analysis_options.yaml
- Include `package:flutter_lints/flutter.yaml`
- Add custom rules as needed
- Use `// ignore: [rule_name]` for exceptions

## 14. Testing

### Widget Tests
- Place tests in `test/` directory
- Follow Flutter testing patterns
- Test critical user flows

## 15. Documentation

### Code Comments
- Use `///` for class documentation
- Use `//` for implementation comments
- Document complex business logic

### README
- Keep `README.md` updated with project information
- Include setup and development instructions

## 16. Version Control

### Git
- Use descriptive commit messages
- Follow conventional commit format
- Keep sensitive data out of repository

## 17. Performance Considerations

### Image Optimization
- Use appropriate image formats (SVG for icons, PNG for photos)
- Implement image caching with `cached_network_image`

### State Management
- Avoid unnecessary `notifyListeners()` calls
- Dispose providers properly

### Build Optimization
- Use `const` constructors where possible
- Minimize widget rebuilds

## 18. Security

### Data Handling
- Never log sensitive information
- Use secure storage for sensitive data
- Validate user inputs

### Network Security
- Use HTTPS for all network requests
- Implement proper error handling

## Compliance Rules

### MUST Rules (Critical)
1. Follow the exact directory structure in `hierarchy.txt`
2. Use Provider pattern for state management only when necessary
3. Use `appTheme` and `TextStyleHelper.instance` for styling
4. Lock device orientation and disable text scaling
5. Use `NavigatorService` for navigation
6. Follow naming conventions strictly

### SHOULD Rules (Recommended)
1. Use builder pattern for screen constructors
2. Implement proper error handling
3. Write descriptive comments for complex logic
4. Keep code DRY (Don't Repeat Yourself)
5. Test critical functionality

### MAY Rules (Optional)
1. Add custom widgets for reusability
2. Implement additional themes
3. Add more comprehensive testing

---

This document serves as the authoritative guide for maintaining code consistency in the "Millime" project. All AI-generated code must adhere to these rules to ensure homogeneity across development sessions.