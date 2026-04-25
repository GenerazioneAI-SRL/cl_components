/// Genai Components — v2 design system.
///
/// Coexists with v1 via import alias. Consumers should pick one:
///
/// ```dart
/// import 'package:genai_components/genai_components.dart' as v1;
/// import 'package:genai_components/genai_components_v2.dart' as v2;
/// ```
///
/// v2 design direction: tech + premium + personality. Dark-first, flat + border,
/// restrained palette, data-forward (KPI + sparkline first-class). See
/// `docs/DESIGN_SYSTEM_V2.md` for the full spec.
library;

// ─── Tokens ─────────────────────────────────────────────────────────────────
export 'v2/tokens/tokens.dart';

// ─── Theme ──────────────────────────────────────────────────────────────────
export 'v2/theme/theme_extension.dart';
export 'v2/theme/theme_builder.dart';
export 'v2/theme/context_extensions.dart';
export 'v2/theme/presets.dart';

// ─── Foundations ────────────────────────────────────────────────────────────
export 'v2/foundations/animations.dart';
export 'v2/foundations/responsive.dart';
export 'v2/foundations/icons.dart';
export 'v2/foundations/genai_direction.dart';

// ─── Components — Actions ──────────────────────────────────────────────────
export 'v2/components/actions/genai_button.dart';
export 'v2/components/actions/genai_icon_button.dart';
export 'v2/components/actions/genai_link_button.dart';
export 'v2/components/actions/genai_copy_button.dart';
export 'v2/components/actions/genai_split_button.dart';
export 'v2/components/actions/genai_fab.dart';
export 'v2/components/actions/genai_toggle_button.dart';
export 'v2/components/actions/genai_toggle_button_group.dart';
export 'v2/components/actions/genai_button_group.dart';

// ─── Components — Indicators ───────────────────────────────────────────────
export 'v2/components/indicators/genai_badge.dart';
export 'v2/components/indicators/genai_chip.dart';
export 'v2/components/indicators/genai_status_badge.dart';
export 'v2/components/indicators/genai_avatar.dart';
export 'v2/components/indicators/genai_avatar_group.dart';
export 'v2/components/indicators/genai_trend_indicator.dart';
export 'v2/components/indicators/genai_progress_ring.dart';
export 'v2/components/indicators/genai_kbd.dart';

// ─── Components — Feedback ─────────────────────────────────────────────────
export 'v2/components/feedback/genai_spinner.dart';
export 'v2/components/feedback/genai_progress_bar.dart';
export 'v2/components/feedback/genai_circular_progress.dart';
export 'v2/components/feedback/genai_skeleton.dart';
export 'v2/components/feedback/genai_alert.dart';
export 'v2/components/feedback/genai_toast.dart';
export 'v2/components/feedback/genai_empty_state.dart';
export 'v2/components/feedback/genai_error_state.dart';

// ─── Components — Inputs ───────────────────────────────────────────────────
export 'v2/components/inputs/genai_checkbox.dart';
export 'v2/components/inputs/genai_color_picker.dart';
export 'v2/components/inputs/genai_combobox.dart';
export 'v2/components/inputs/genai_date_picker.dart';
export 'v2/components/inputs/genai_file_upload.dart';
export 'v2/components/inputs/genai_label.dart';
export 'v2/components/inputs/genai_otp_input.dart';
export 'v2/components/inputs/genai_radio.dart';
export 'v2/components/inputs/genai_select.dart';
export 'v2/components/inputs/genai_slider.dart';
export 'v2/components/inputs/genai_tag_input.dart';
export 'v2/components/inputs/genai_text_field.dart';
export 'v2/components/inputs/genai_textarea.dart';
export 'v2/components/inputs/genai_toggle.dart';
export 'v2/components/inputs/genai_native_select.dart';
export 'v2/components/inputs/genai_field.dart';
export 'v2/components/inputs/genai_input_group.dart';

// ─── Components — Layout ───────────────────────────────────────────────────
export 'v2/components/layout/genai_card.dart';
export 'v2/components/layout/genai_divider.dart';
export 'v2/components/layout/genai_section.dart';
export 'v2/components/layout/genai_aspect_ratio.dart';
export 'v2/components/layout/genai_accordion.dart';
export 'v2/components/layout/genai_collapsible.dart';
export 'v2/components/layout/genai_scroll_area.dart';
export 'v2/components/layout/genai_resizable.dart';

// ─── Components — Overlay ──────────────────────────────────────────────────
export 'v2/components/overlay/genai_modal.dart';
export 'v2/components/overlay/genai_drawer.dart';
export 'v2/components/overlay/genai_tooltip.dart';
export 'v2/components/overlay/genai_popover.dart';
export 'v2/components/overlay/genai_context_menu.dart';
export 'v2/components/overlay/genai_hover_card.dart';
export 'v2/components/overlay/genai_alert_dialog.dart';
export 'v2/components/overlay/genai_sheet.dart';
export 'v2/components/overlay/genai_dropdown_menu.dart';

// ─── Components — Display ──────────────────────────────────────────────────
export 'v2/components/display/genai_typography.dart';
export 'v2/components/display/genai_list.dart';
export 'v2/components/display/genai_sparkline.dart';
export 'v2/components/display/genai_kpi_card.dart';
export 'v2/components/display/genai_timeline.dart';
export 'v2/components/display/genai_calendar.dart';
export 'v2/components/display/genai_kanban.dart';
export 'v2/components/display/genai_tree_view.dart';
export 'v2/components/display/genai_table.dart';
export 'v2/components/display/genai_carousel.dart';
export 'v2/components/display/genai_focus_card.dart';
export 'v2/components/display/genai_suggestion_item.dart';
export 'v2/components/display/genai_bar_row.dart';
export 'v2/components/display/genai_agenda_row.dart';
export 'v2/components/display/genai_formation_card.dart';
export 'v2/components/display/genai_item.dart';

// ─── Components — Charts ───────────────────────────────────────────────────
export 'v2/components/charts/genai_bar_chart.dart';
export 'v2/components/charts/genai_org_chart.dart';

// ─── Components — Navigation ───────────────────────────────────────────────
export 'v2/components/navigation/genai_tabs.dart';
export 'v2/components/navigation/genai_breadcrumb.dart';
export 'v2/components/navigation/genai_pagination.dart';
export 'v2/components/navigation/genai_stepper.dart';
export 'v2/components/navigation/genai_bottom_nav.dart';
export 'v2/components/navigation/genai_navigation_rail.dart';
export 'v2/components/navigation/genai_app_bar.dart';
export 'v2/components/navigation/genai_sidebar.dart';
export 'v2/components/navigation/genai_command_palette.dart';
export 'v2/components/navigation/genai_notification_center.dart';
export 'v2/components/navigation/genai_shell.dart';
export 'v2/components/navigation/genai_menubar.dart';
export 'v2/components/navigation/genai_navigation_menu.dart';
export 'v2/components/navigation/genai_ask_bar.dart';
export 'v2/components/navigation/genai_topbar.dart';
