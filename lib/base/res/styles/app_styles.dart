import 'package:flutter/material.dart';

/// **Centralized design system and theme management for Item Minder app.**
///
/// [AppStyles] provides a singleton-based theming system that ensures consistent
/// visual design across the entire application. It defines the **complete design
/// language** including colors, typography, button styles, and component styling.
///
/// **Design System Features:**
/// * **Primary Brand Color**: Orange (#FF914D) used for primary actions and branding
/// * **Consistent Typography**: Predefined text styles for different UI contexts
/// * **Standardized Components**: Button styles and form field appearances
/// * **Singleton Pattern**: Ensures single source of truth for all styling
///
/// **Key Benefits:**
/// * **Design Consistency**: All UI components use the same visual language
/// * **Easy Theming**: Centralized color and style management
/// * **Maintainability**: Single location for design system updates
/// * **Performance**: Singleton prevents repeated style object creation
///
/// The design system supports the app's **inventory management context** with
/// clear visual hierarchy, readable typography, and intuitive interactive elements.
///
/// {@tool snippet}
/// ```dart
/// // Apply consistent primary color
/// Container(
///   color: AppStyles().getPrimaryColor(),
///   child: Text(
///     'Inventory Items',
///     style: AppStyles().catTitleStyle,
///   ),
/// )
///
/// // Use standardized button styling
/// ElevatedButton(
///   style: AppStyles().buttonStyle,
///   onPressed: () => {},
///   child: Text(
///     'Add Item',
///     style: AppStyles().buttonTextStyle,
///   ),
/// )
/// ```
/// {@end-tool}
class AppStyles {
  /// **Primary brand color** - Orange (#FF914D) used for key UI elements.
  ///
  /// This color defines the app's visual identity and is used for:
  /// * Primary action buttons and CTAs
  /// * Navigation elements and highlights
  /// * Item card borders and accents
  /// * Form field labels and active states
  static const Color _primaryColor = Color(0xFFFF914D);

  /// **Secondary color** - Semi-transparent orange for subtle UI elements.
  ///
  /// Used for backgrounds, disabled states, and overlay effects.
  /// Provides visual hierarchy while maintaining brand consistency.
  static final Color _secondaryColor = Color.fromRGBO(255, 145, 77, 0.5);

  /// **Small label text style** for compact UI elements.
  ///
  /// Applied to: item quantities, category labels, metadata text.
  /// Size: 12.0px, Weight: Bold, Color: Primary orange.
  static const TextStyle _titleStyle = TextStyle(
    fontWeight: FontWeight.bold, // Example font weight
    fontSize: 12.0,
    color: _primaryColor,
  );

  /// **Category title text style** for section headings.
  ///
  /// Applied to: category names, section headers, prominent labels.
  /// Size: 18.0px, Weight: Bold, Color: Primary orange.
  static const TextStyle _catTitleStyle = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.bold, // Example font weight
    color: _primaryColor,
  );

  /// **Dropdown text style** for dropdown menu items.
  ///
  /// Applied to: dropdown options, menu items on dark backgrounds.
  /// Size: 14.0px, Weight: Bold, Color: White for contrast.
  static const TextStyle _dropTextStyle = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.bold, // Example font weight
    color: Colors.white,
  );

  /// **Form label text style** for input field labels.
  ///
  /// Applied to: form labels, input hints, field descriptions.
  /// Size: 12.0px, Weight: Bold, Color: Primary orange.
  static const TextStyle _formTextStyle = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.bold, // Example font weight
    color: _primaryColor,
  );

  /// **Form field content text style** for user input text.
  ///
  /// Applied to: input field content, editable text, user-entered data.
  /// Size: 14.0px, Weight: Bold, Color: Black for readability.
  static const TextStyle _formFillTextStyle = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.bold, // Example font weight
    color: Colors.black,
  );

  /// **App bar text style** for navigation and header text.
  ///
  /// Applied to: app bar titles, navigation labels, header content.
  /// Size: 16.0px, Weight: Bold, Color: Black for clear hierarchy.
  static const TextStyle _appBartTextStyle = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.bold, // Example font weight
    color: Colors.black,
  );

  /// **Body text style** for general content and descriptions.
  ///
  /// Applied to: descriptions, content text, general body copy.
  /// Size: 14.0px, Weight: Normal, Color: Dark grey for readability.
  static const TextStyle _bodyTextStyle = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
    color: Colors.black87,
  );

  /// **Standard button style** for primary actions.
  ///
  /// Defines the visual appearance of primary action buttons throughout the app.
  /// Features rounded corners, primary color background, and consistent border.
  /// Used for: Add item, Save, Edit, and other primary user actions.
  final ButtonStyle _buttonStyle = ElevatedButton.styleFrom(
    backgroundColor: _primaryColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(32),
      side: const BorderSide(color: _primaryColor, width: 3),
    ),
  );

  /// **Button text style** for text displayed on buttons.
  ///
  /// Applied to: button labels, action text, call-to-action content.
  /// Size: 16.0px, Weight: Bold, Color: White for contrast on colored buttons.
  TextStyle buttonTexStyle = const TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.bold, // Example font weight
    color: Colors.white,
  );

  /// **Raised button style** for prominent secondary actions.
  ///
  /// Used for larger action buttons like "Create Group" and "Join Group".
  /// Features enhanced elevation, larger minimum size, and distinct padding
  /// to create visual prominence for important secondary actions.
  final ButtonStyle _raisedButtonStyleCustom = ElevatedButton.styleFrom(
    foregroundColor: Colors.white,
    backgroundColor: _primaryColor,
    minimumSize: Size(100, 80),
    shadowColor: Colors.black,
    elevation: 4,
    padding: EdgeInsets.symmetric(horizontal: 10),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(18)),
    ),
  );

  /// **Singleton instance** for global access to styling.
  ///
  /// Ensures all parts of the app use the same [AppStyles] instance,
  /// maintaining consistency and preventing duplicate style objects.
  static final AppStyles _instance = AppStyles._internal();

  /// **Private constructor** for singleton pattern implementation.
  ///
  /// Prevents direct instantiation of [AppStyles], ensuring only the
  /// singleton factory constructor can create instances.
  AppStyles._internal();

  /// **Factory constructor** returns the singleton instance.
  ///
  /// This is the **primary way** to access [AppStyles] throughout the app.
  /// Guarantees that all styling operations use the same configuration.
  ///
  /// **Usage Example:**
  /// ```dart
  /// final styles = AppStyles(); // Always returns the same instance
  /// ```
  factory AppStyles() {
    return _instance;
  }

  /// **Primary brand color accessor.**
  ///
  /// Returns the main orange color (#FF914D) used throughout the app for
  /// primary UI elements, branding, and key interactive components.
  ///
  /// **Usage:** Apply to buttons, highlights, borders, and brand elements.
  Color getPrimaryColor() {
    return _primaryColor;
  }

  /// **Small text style** for compact labels and metadata.
  ///
  /// 12px bold text in primary color. Use for item quantities, category
  /// tags, and other small informational text.
  TextStyle get titleStyle {
    return _titleStyle;
  }

  /// **Category heading style** for section titles.
  ///
  /// 18px bold text in primary color. Use for category names, section
  /// headers, and prominent content labels.
  TextStyle get catTitleStyle {
    return _catTitleStyle;
  }

  /// **Dropdown menu text style** for menu options.
  ///
  /// 14px bold white text. Use for dropdown items and menu content
  /// displayed on colored backgrounds.
  TextStyle get dropTextStyle {
    return _dropTextStyle;
  }

  /// **Form label text style** for input field labels.
  ///
  /// 12px bold text in primary color. Use for form field labels,
  /// input descriptions, and field hints.
  TextStyle get formTextStyle {
    return _formTextStyle;
  }

  /// **Form field content style** for user input text.
  ///
  /// 14px bold black text. Use for input field content, editable text,
  /// and user-entered data display.
  TextStyle get formFieldStyle {
    return _formFillTextStyle;
  }

  /// **App bar text style** for navigation headers.
  ///
  /// 16px bold black text. Use for app bar titles, navigation labels,
  /// and header content.
  TextStyle get appBarTextStyle {
    return _appBartTextStyle;
  }

  /// **Body text style** for general content.
  ///
  /// 14px normal weight text. Use for descriptions, content text,
  /// and general body copy throughout the app.
  TextStyle get bodyStyle {
    return _bodyTextStyle;
  }

  /// **Secondary color accessor** for subtle UI elements.
  ///
  /// Returns semi-transparent orange for backgrounds, disabled states,
  /// and overlay effects while maintaining brand consistency.
  Color getSecondaryColor() {
    return _secondaryColor;
  }

  /// **Standard button style** for primary actions.
  ///
  /// Rounded button style with primary color background. Use for main
  /// action buttons like Add, Save, Edit throughout the app.
  ButtonStyle get buttonStyle {
    return _buttonStyle;
  }

  /// **Button text style** for button labels.
  ///
  /// 16px bold white text. Use for text displayed on colored action
  /// buttons to ensure proper contrast and readability.
  TextStyle get buttonTextStyle {
    return buttonTexStyle;
  }

  /// **Raised button style** for prominent secondary actions.
  ///
  /// Enhanced button style with elevation and larger size. Use for
  /// important secondary actions like "Create Group" and "Join Group".
  ButtonStyle get raisedButtonStyle {
    return _raisedButtonStyleCustom;
  }
}
