import 'package:flutter/material.dart';
import 'package:cl_components/utils/models/pageaction.model.dart';
import '../models/breadcrumb_item.model.dart';

class NavigationState extends ChangeNotifier {
  final List<BreadcrumbItem> breadcrumbs = [];

  String pageName = "";
  String? initialRoute;

  /// Diventa true quando il CLPageHeader è scrollato fuori dallo schermo.
  /// L'HeaderLayout lo usa per mostrare il titolo con fade-in.
  final ValueNotifier<bool> headerTitleVisible = ValueNotifier<bool>(false);

  void setPageActions(List<PageAction> pageActionsArray) {
    breadcrumbs.last.pageActions = pageActionsArray;
    notifyListeners();
  }

  /// NON tocca mai l'indice 0 (Dashboard)
  void _clearExceptRoot() {
    if (breadcrumbs.length > 1) {
      breadcrumbs.removeRange(1, breadcrumbs.length);
    }
  }

  void addBreadcrumb(BreadcrumbItem item, {String? parentModuleName, String? parentModulePath, bool isNestedInMenu = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      pageName = item.name;
      final idx = breadcrumbs.indexWhere((b) => b.path == item.path);

      if (idx != -1) {
        // clic su un breadcrumb già in lista → tronca tutto ciò che viene dopo
        if (idx + 1 < breadcrumbs.length) {
          breadcrumbs.removeRange(idx + 1, breadcrumbs.length);
        }
        notifyListeners();
        return;
      }

      if (item.isModule) {
        final lastModIdx = breadcrumbs.lastIndexWhere((b) => b.isModule);
        if (lastModIdx != -1) {
          final lastMod = breadcrumbs[lastModIdx];
          final isNested = item.path.startsWith('${lastMod.path}/');
          if (!isNested) {
            // resetto tutto tranne root
            _clearExceptRoot();
          }
        } else {
          // primo modulo in assoluto → mantieni solo root (se c'è)
          _clearExceptRoot();
        }
      } else {
        // È una pagina (non modulo)

        // Se c'è un parent module specificato, gestisci i breadcrumbs di conseguenza
        if (parentModuleName != null && parentModulePath != null) {
          // Cerca se il parent module è già nei breadcrumbs
          final parentModuleIdx = breadcrumbs.indexWhere((b) => b.path == parentModulePath);

          if (parentModuleIdx != -1) {
            // Il modulo parent è già presente, rimuovi tutto dopo di esso
            if (parentModuleIdx < breadcrumbs.length - 1) {
              breadcrumbs.removeRange(parentModuleIdx + 1, breadcrumbs.length);
            }
          } else {
            // Il modulo parent non è presente, resetta e aggiungilo
            _clearExceptRoot();
            breadcrumbs.add(BreadcrumbItem(
              name: parentModuleName,
              path: parentModulePath,
              isModule: true,
              isClickable: false, // Modulo non cliccabile
            ));
          }
        } else if (isNestedInMenu) {
          // Route nidificata in un menu
          // Devo determinare se è una route figlia diretta (da aggiungere) o una route allo stesso livello (da sostituire)
          if (breadcrumbs.isNotEmpty) {
            final lastItem = breadcrumbs.last;
            if (!lastItem.isModule) {
              // Confronta i path per determinare la relazione
              final currentPathParts = item.path.split('/').where((p) => p.isNotEmpty).toList();
              final lastPathParts = lastItem.path.split('/').where((p) => p.isNotEmpty).toList();

              // Verifica prima se il path corrente contiene il path precedente come prefisso
              // (indica che è una route figlia diretta o più profonda)
              final isChildOfLast = item.path.startsWith(lastItem.path + '/');

              if (isChildOfLast) {
                // È una route figlia (diretta o più profonda) → AGGIUNGI
              } else if (currentPathParts.length == lastPathParts.length) {
                // Hanno lo stesso numero di segmenti, verifica se hanno lo stesso parent
                if (currentPathParts.length >= 2) {
                  final currentParent = currentPathParts.sublist(0, currentPathParts.length - 1).join('/');
                  final lastParent = lastPathParts.sublist(0, lastPathParts.length - 1).join('/');

                  if (currentParent == lastParent) {
                    // Stesso parent, stesso livello → SOSTITUISCI
                    breadcrumbs.removeLast();
                  }
                }
              } else {
                // Lunghezze diverse e non è figlia diretta
                // Verifica se hanno un parent comune
                final minLength = currentPathParts.length < lastPathParts.length ? currentPathParts.length : lastPathParts.length;
                if (minLength >= 2) {
                  final currentParent = currentPathParts.sublist(0, minLength - 1).join('/');
                  final lastParent = lastPathParts.sublist(0, minLength - 1).join('/');

                  if (currentParent == lastParent) {
                    // Hanno un parent comune, potrebbero essere allo stesso livello → SOSTITUISCI
                    breadcrumbs.removeLast();
                  }
                }
              }
            }
          }
        } else {
          // Pagina senza parent module E non nidificata in menu (es. pagina top-level)
          // Trova l'ultimo modulo nei breadcrumbs
          final lastModIdx = breadcrumbs.lastIndexWhere((b) => b.isModule);

          if (lastModIdx != -1) {
            final lastMod = breadcrumbs[lastModIdx];
            // Verifica se la pagina corrente appartiene all'ultimo modulo
            final belongsToLastModule = item.path.startsWith('${lastMod.path}/');

            if (!belongsToLastModule) {
              // La pagina appartiene a un modulo diverso → resetto tutto tranne root
              _clearExceptRoot();
            } else {
              // La pagina appartiene allo stesso modulo
              // Se l'ultima voce è anche una pagina (non modulo), sostituiscila
              if (breadcrumbs.isNotEmpty) {
                final lastItem = breadcrumbs.last;
                if (!lastItem.isModule) {
                  breadcrumbs.removeLast();
                }
              }
            }
          } else {
            // Non ci sono moduli nei breadcrumbs, è una pagina top-level
            // Se l'ultima voce è una pagina, sostituiscila
            if (breadcrumbs.isNotEmpty) {
              final lastItem = breadcrumbs.last;
              if (!lastItem.isModule) {
                breadcrumbs.removeLast();
              }
            }
          }
        }
      }

      // aggiungo modulo o pagina
      breadcrumbs.add(item);
      notifyListeners();
    });
  }

  void removeLastBreadcrumb() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // rimuovi solo se rimane almeno il root
      if (breadcrumbs.length > 1) {
        breadcrumbs.removeLast();
        pageName = breadcrumbs.last.name;
        notifyListeners();
      }
    });
  }

  /// Rimuove il modulo corrente (e le sue pagine figlie), ma lascia sempre il root
  void popModule() {
    if (breadcrumbs.isEmpty) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final lastModIdx = breadcrumbs.lastIndexWhere((b) => b.isModule);

      if (lastModIdx > 0) {
        // rimuove dal modulo stesso in poi
        breadcrumbs.removeRange(lastModIdx, breadcrumbs.length);
      } else {
        // era il modulo root → rimuove tutto tranne root
        _clearExceptRoot();
      }
      pageName = breadcrumbs.last.name;
      notifyListeners();
    });
  }

  /// Svuota tutti i breadcrumb tranne il root
  void clearBreadcrumbs() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      breadcrumbs.clear();
      notifyListeners();
    });
  }

  /// Tronca tutto ciò che segue targetPath, ma non tocca mai il root
  void removeUntil(String targetPath) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final idx = breadcrumbs.indexWhere((b) => b.path == targetPath);
      if (idx != -1 && idx < breadcrumbs.length - 1) {
        // se idx è 0, rimuove comunque solo da 1 in poi, preservando root
        breadcrumbs.removeRange(idx + 1, breadcrumbs.length);
        pageName = breadcrumbs.last.name;

        notifyListeners();
      }
    });
  }
}
