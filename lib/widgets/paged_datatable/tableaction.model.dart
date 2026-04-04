part of 'paged_datatable.dart';
class TableAction<T extends Object> {
  final Widget content;
  final void Function(Object) _onTapInternal;

  TableAction({
    required this.content,
    required void Function(T) onTap,
  }) : _onTapInternal = ((item) => onTap(item as T));

  void onTap(Object item) => _onTapInternal(item); // Usa la funzione con il cast
}