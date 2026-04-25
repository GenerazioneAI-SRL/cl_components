/// Org chart and genogram — v2 design system.
///
/// This component is theme-agnostic: it owns layout/edge-painting logic and
/// renders consumer-provided node widgets via a `builder` callback. All
/// styling (colors, typography, spacing, radii) lives inside the consumer's
/// node builder and reads from `context.colors`, `context.typography`, etc.
///
/// Because there are no token-bound visual values inside the chart itself,
/// the v2 implementation re-uses the v1 sources rather than duplicating
/// ~4000 LOC of pure layout/quadtree/painter code that would otherwise drift.
/// The public API surface (the `Genai*` classes below) is identical across
/// v1 / v2 / v3.
library;

export '../../../src/components/charts/org_chart/orgchart/org_chart.dart'
    show GenaiOrgChart;
export '../../../src/components/charts/org_chart/orgchart/org_chart_controller.dart'
    show GenaiOrgChartController, ActionOnNodeRemoval;

export '../../../src/components/charts/org_chart/base/edge_painter_utils.dart'
    show
        SolidGraphArrow,
        DashedGraphArrow,
        GraphArrowStyle,
        ConnectionType,
        LineEndingType;
export '../../../src/components/charts/org_chart/common/node_builder_details.dart'
    show NodeBuilderDetails;

export '../../../src/components/charts/org_chart/genogram/genogram.dart'
    show GenaiGenogram;
export '../../../src/components/charts/org_chart/genogram/genogram_controller.dart'
    show GenaiGenogramController;

export '../../../src/components/charts/org_chart/genogram/edge_painter.dart'
    show GenogramEdgePainter, ConnectionPoint, RelationshipType;
export '../../../src/components/charts/org_chart/genogram/genogram_edge_config.dart'
    show GenogramEdgeConfig;
export '../../../src/components/charts/org_chart/genogram/marriage_style.dart'
    show MarriageStyle, MarriageLineStyle, MarriageDecorator, DivorceDecorator;
export '../../../src/components/charts/org_chart/genogram/genogram_enums.dart'
    show Gender, MarriageStatus;
export '../../../src/components/charts/org_chart/base/base_controller.dart'
    show GenaiBaseGraphController, GraphOrientation;
export 'package:custom_interactive_viewer/custom_interactive_viewer.dart'
    show
        CustomInteractiveViewerController,
        InteractionConfig,
        KeyboardConfig,
        ScrollMode,
        ZoomConfig;
