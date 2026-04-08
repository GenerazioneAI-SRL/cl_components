# Changelog

## 3.0.1

- refactor: remove unnecessary blank line in breadcrumbs.layout.dart
- update package name and version in pubspec.yaml
- refactor: update imports to use genai_components instead of cl_components
- update package name and version in pubspec.yaml
- commit
- commit
- commit
- commit
- commit
- commit
- commit
- commit
- commit
- commit
- commit
- commit
- commit
- commit
- commit
- commit
- commit
- commit
- commit
- commit
- commit
- commit
- commit
- try edit
- feat: add CLApp and CLAppConfig for app bootstrapping
- feat: add app core - router, layout, api, providers, auth interfaces, models, utils
- fix: resolve duplicate_definition errors in AI assistant code
- feat: replace all widgets with current project widgets v2.0
- feat: add CLFilePicker, CLFileList, CLDataTable to package
- feat: add CLDateField, CLTimeField, CLColorField, CLDropdown to package
- feat: add CLLifecycleProgress, CLConfirmRejectButtons, CLResponsiveGrid, CLInfoBanner, CLAlert
- feat: add CLPageHeader, CLTabView, CLPagination, CLViewToggle, CLPopupMenu, CLBottomNav
- feat: add CLAvatar, CLStatusBadge, CLPill, CLRoleBadge, CLCodeText, CLClipboard
- feat: add CLTextField, CLPasswordField, CLCheckbox, CLFormMode to package
- feat: add CLContainer, CLCard, CLSectionCard to package
- feat: add unified CLButton with 5 variants (solid, ghost, outline, soft, text)
- feat: add text styles to CLThemeData + CLDivider + CLShimmer + CLEmptyState
- feat: initial cl_components package — theme system + structure


## 2.0.0

- **Breaking:** Refactored as standalone library for pub.dev publication
- **CLApp:** Generic app bootstrap with `CLAppConfig` — OIDC, routing, providers out of the box
- **CLTheme:** Light/dark mode with per-module color overrides via `ModuleThemeProvider`
- **GoRouterModular:** Custom routing system wrapping GoRouter — `Module`, `CLRoute`, `ChildRoute`, `ModuleRoute`, `ShellModularRoute`
- **ApiManager:** HTTP wrapper with auto Bearer token, tenant header, multipart upload
- **CLBaseViewModel:** Stacked MVVM base class with page actions, breadcrumbs, lifecycle
- **Layout:** `AppLayout`, `MenuLayout`, `HeaderLayout`, `FooterLayout`, `BreadcrumbsLayout`
- **Charts:** Generic `CLBarChart<T>`, `CLPieChart<T>`, `CLSplineChart<T>`, `CLSplineAreaChart<T>`, `CLAreaChart<T>` with `CLChartSeries<T>`
- **Widgets:** `CLButton`, `CLTextField`, `CLDropdown`, `CLPagination`, `PagedDataTable`, `CLOrgChart`, `CLSurvey`, `CLAiAssistant`, and 30+ reusable components
- **Auth:** Abstract `CLAuthState`, `CLUserInfo`, `CLTenant` interfaces
- **Providers:** `AppState`, `ErrorState`, `ThemeProvider`, `NavigationState`
- **Core models:** `BaseModel`, `Media`, `City`, `Country`, `Province`, `PageAction`

## 1.0.0

- Initial release — internal package via GitHub
