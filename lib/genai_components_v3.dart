/// Genai Components — v3 design system (Forma LMS).
///
/// Coexists with v1 and v2 via import alias. Consumers pick one:
///
/// ```dart
/// import 'package:genai_components/genai_components.dart' as v1;
/// import 'package:genai_components/genai_components_v2.dart' as v2;
/// import 'package:genai_components/genai_components_v3.dart' as v3;
/// ```
///
/// v3 design direction: **decision-first, AI-first, hairline-flat** light
/// dashboards for Forma LMS. Light-only in v3.0; dark mode deferred to v3.1.
/// See `docs/DESIGN_SYSTEM_V3.md` for the full spec and the
/// `Dashboard v3.html` reference bundle for pixel-level detail.
library;

// ─── Tokens ─────────────────────────────────────────────────────────────────
export 'v3/tokens/tokens.dart';

// ─── Theme ──────────────────────────────────────────────────────────────────
export 'v3/theme/theme_extension.dart';
export 'v3/theme/theme_builder.dart';
export 'v3/theme/context_extensions.dart';
export 'v3/theme/presets.dart';

// ─── Foundations ────────────────────────────────────────────────────────────
export 'v3/foundations/animations.dart';
export 'v3/foundations/responsive.dart';
export 'v3/foundations/icons.dart';
export 'v3/foundations/genai_direction.dart';

// ─── Components — Actions ──────────────────────────────────────────────────
export 'v3/components/actions/genai_button.dart';
export 'v3/components/actions/genai_icon_button.dart';
export 'v3/components/actions/genai_link_button.dart';
export 'v3/components/actions/genai_copy_button.dart';
export 'v3/components/actions/genai_split_button.dart';
export 'v3/components/actions/genai_fab.dart';
export 'v3/components/actions/genai_toggle_button.dart';
export 'v3/components/actions/genai_toggle_button_group.dart';
export 'v3/components/actions/genai_button_group.dart';

// ─── Components — Indicators ───────────────────────────────────────────────
export 'v3/components/indicators/genai_badge.dart';
export 'v3/components/indicators/genai_chip.dart';
export 'v3/components/indicators/genai_status_badge.dart';
export 'v3/components/indicators/genai_avatar.dart';
export 'v3/components/indicators/genai_avatar_group.dart';
export 'v3/components/indicators/genai_trend_indicator.dart';
export 'v3/components/indicators/genai_progress_ring.dart';
export 'v3/components/indicators/genai_kbd.dart';

// ─── Components — Feedback ─────────────────────────────────────────────────
export 'v3/components/feedback/genai_alert.dart';
export 'v3/components/feedback/genai_circular_progress.dart';
export 'v3/components/feedback/genai_empty_state.dart';
export 'v3/components/feedback/genai_error_state.dart';
export 'v3/components/feedback/genai_progress_bar.dart';
export 'v3/components/feedback/genai_skeleton.dart';
export 'v3/components/feedback/genai_spinner.dart';
export 'v3/components/feedback/genai_toast.dart';

// ─── Components — Inputs ───────────────────────────────────────────────────
export 'v3/components/inputs/genai_checkbox.dart';
export 'v3/components/inputs/genai_color_picker.dart';
export 'v3/components/inputs/genai_combobox.dart';
export 'v3/components/inputs/genai_date_picker.dart';
export 'v3/components/inputs/genai_file_upload.dart';
export 'v3/components/inputs/genai_label.dart';
export 'v3/components/inputs/genai_otp_input.dart';
export 'v3/components/inputs/genai_radio.dart';
export 'v3/components/inputs/genai_select.dart';
export 'v3/components/inputs/genai_slider.dart';
export 'v3/components/inputs/genai_tag_input.dart';
export 'v3/components/inputs/genai_text_field.dart';
export 'v3/components/inputs/genai_textarea.dart';
export 'v3/components/inputs/genai_toggle.dart';
export 'v3/components/inputs/genai_native_select.dart';
export 'v3/components/inputs/genai_field.dart';
export 'v3/components/inputs/genai_input_group.dart';

// ─── Components — Layout ───────────────────────────────────────────────────
export 'v3/components/layout/genai_card.dart';
export 'v3/components/layout/genai_divider.dart';
export 'v3/components/layout/genai_section.dart';
export 'v3/components/layout/genai_aspect_ratio.dart';
export 'v3/components/layout/genai_accordion.dart';
export 'v3/components/layout/genai_collapsible.dart';
export 'v3/components/layout/genai_scroll_area.dart';
export 'v3/components/layout/genai_resizable.dart';

// ─── Components — Overlay ──────────────────────────────────────────────────
export 'v3/components/overlay/genai_modal.dart';
export 'v3/components/overlay/genai_drawer.dart';
export 'v3/components/overlay/genai_tooltip.dart';
export 'v3/components/overlay/genai_popover.dart';
export 'v3/components/overlay/genai_context_menu.dart';
export 'v3/components/overlay/genai_hover_card.dart';
export 'v3/components/overlay/genai_alert_dialog.dart';
export 'v3/components/overlay/genai_sheet.dart';
export 'v3/components/overlay/genai_dropdown_menu.dart';

// ─── Components — Display (incl. Forma LMS primitives) ─────────────────────
export 'v3/components/display/genai_typography.dart';
export 'v3/components/display/genai_list.dart';
export 'v3/components/display/genai_kpi_card.dart';
export 'v3/components/display/genai_sparkline.dart';
export 'v3/components/display/genai_bar_row.dart';
export 'v3/components/display/genai_focus_card.dart';
export 'v3/components/display/genai_suggestion_item.dart';
export 'v3/components/display/genai_agenda_row.dart';
export 'v3/components/display/genai_formation_card.dart';
export 'v3/components/display/genai_timeline.dart';
export 'v3/components/display/genai_calendar.dart';
export 'v3/components/display/genai_kanban.dart';
export 'v3/components/display/genai_tree_view.dart';
export 'v3/components/display/genai_carousel.dart';
export 'v3/components/display/genai_table.dart';
export 'v3/components/display/genai_item.dart';

// ─── Components — Charts ───────────────────────────────────────────────────
export 'v3/components/charts/genai_bar_chart.dart';
export 'v3/components/charts/genai_org_chart.dart';

// ─── Components — Navigation (incl. AskBar + Topbar) ──────────────────────
export 'v3/components/navigation/genai_app_bar.dart';
export 'v3/components/navigation/genai_ask_bar.dart';
export 'v3/components/navigation/genai_bottom_nav.dart';
export 'v3/components/navigation/genai_breadcrumb.dart';
export 'v3/components/navigation/genai_command_palette.dart';
export 'v3/components/navigation/genai_menubar.dart';
export 'v3/components/navigation/genai_navigation_menu.dart';
export 'v3/components/navigation/genai_navigation_rail.dart';
export 'v3/components/navigation/genai_notification_center.dart';
export 'v3/components/navigation/genai_pagination.dart';
export 'v3/components/navigation/genai_shell.dart';
export 'v3/components/navigation/genai_sidebar.dart';
export 'v3/components/navigation/genai_stepper.dart';
export 'v3/components/navigation/genai_tabs.dart';
export 'v3/components/navigation/genai_topbar.dart';
