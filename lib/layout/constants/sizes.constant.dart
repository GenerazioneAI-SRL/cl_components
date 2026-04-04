class Sizes {
  // Spacing scale (base unit: 4px)
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const xxxl = 32.0;

  // Border radius
  static const radiusSm = 6.0;    // tooltip, buttons, badge, chip — squadrati, decisi
  static const radiusMd = 8.0;    // input, select, textarea
  static const radiusLg = 16.0;   // card, stat card — morbide, accoglienti
  static const radiusXl = 20.0;   // container, modal, dialog
  static const radiusFull = 999.0; // pill badge, avatar

  // Legacy aliases (for gradual migration — remove after full migration)
  static const small = 16.0;
  static const medium = 20.0;
  static const large = 24.0;
  static const borderRadius = 12.0;
  static const padding = 18.0;
  static const opacity = 0.1; // Updated from 0.2 to 0.1 for new tint system
  static const verticalPadding = 16.0;
  static const headerOffset = 50.0; // Top bar height (was 80.0)

  // Layout
  static const topBarHeight = 50.0;
  static const sidebarWidth = 175.0;
  static const contentPadding = 22.0;
  static const mobileBreakpoint = 1079.0;
}
