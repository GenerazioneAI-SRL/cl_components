import 'package:genai_components/src/data_display/table/gen_ai_table_page.dart';
import 'package:genai_components/src/data_display/table/gen_ai_table_query.dart';

/// Abstract data source consumed by `GenAiDataTable`.
///
/// Implementations translate a [GenAiTableQuery] into a [GenAiTablePage].
/// The contract is intentionally minimal: callers can wrap REST endpoints,
/// in-memory lists, GraphQL clients, or local caches behind a single
/// [fetch] method.
///
/// Implementations should:
///  * surface server-side pagination, sort and search by encoding the
///    fields of [GenAiTableQuery] in their wire format,
///  * propagate errors via the returned [Future] (the table renders an
///    error empty-state with a "Riprova" action),
///  * never mutate the supplied query.
// ignore: one_member_abstracts
abstract class GenAiTableDataSource<T> {
  /// Fetches a single page that matches [query].
  Future<GenAiTablePage<T>> fetch(GenAiTableQuery query);
}
