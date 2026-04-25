import 'package:flutter/material.dart';
import 'package:genai_components/genai_components.dart';

import '../widgets/showcase_section.dart';

class InputsPage extends StatefulWidget {
  const InputsPage({super.key});

  @override
  State<InputsPage> createState() => _InputsPageState();
}

class _InputsPageState extends State<InputsPage> {
  bool? _check1 = false;
  bool? _check2 = true;
  bool? _check3;
  String _radio = 'a';
  bool _toggle = true;
  double _slider = 35;
  RangeValues _range = const RangeValues(20, 70);
  String? _select = 'eur';
  List<String> _multiSelect = ['mario'];
  DateTime? _date;
  DateTimeRange? _dateRange;
  DateTime? _month;
  List<String> _tags = ['design', 'system'];
  String _otp = '';
  Color _color = const Color(0xFF7C3AED);
  List<GenaiUploadedFile> _files = const [];
  String? _comboSingle;
  List<String> _comboMulti = const ['milan', 'rome'];
  final TextEditingController _textareaCtrl =
      TextEditingController(text: 'Testo di prova nella textarea.');

  static const _comboCities = <GenaiSelectOption<String>>[
    GenaiSelectOption(value: 'milan', label: 'Milano'),
    GenaiSelectOption(value: 'rome', label: 'Roma'),
    GenaiSelectOption(value: 'naples', label: 'Napoli'),
    GenaiSelectOption(value: 'turin', label: 'Torino'),
    GenaiSelectOption(value: 'palermo', label: 'Palermo'),
    GenaiSelectOption(value: 'genoa', label: 'Genova'),
    GenaiSelectOption(value: 'bologna', label: 'Bologna'),
    GenaiSelectOption(value: 'florence', label: 'Firenze'),
    GenaiSelectOption(value: 'bari', label: 'Bari'),
    GenaiSelectOption(value: 'catania', label: 'Catania'),
    GenaiSelectOption(value: 'venice', label: 'Venezia'),
    GenaiSelectOption(value: 'verona', label: 'Verona'),
    GenaiSelectOption(value: 'messina', label: 'Messina'),
    GenaiSelectOption(value: 'padua', label: 'Padova'),
    GenaiSelectOption(value: 'trieste', label: 'Trieste'),
    GenaiSelectOption(value: 'brescia', label: 'Brescia'),
    GenaiSelectOption(value: 'parma', label: 'Parma'),
    GenaiSelectOption(value: 'modena', label: 'Modena'),
    GenaiSelectOption(value: 'reggio', label: 'Reggio Emilia'),
    GenaiSelectOption(value: 'taranto', label: 'Taranto'),
    GenaiSelectOption(
      value: 'livorno',
      label: 'Livorno (non disponibile)',
      isDisabled: true,
    ),
  ];

  @override
  void dispose() {
    _textareaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShowcaseScaffold(
      title: 'Inputs',
      description:
          'TextField (5 varianti) · Checkbox tri-state · Radio · Toggle · Slider/Range · Select (5 modi) · DatePicker · FileUpload · TagInput · OTP · ColorPicker.',
      children: [
        ShowcaseSection(
          title: 'GenaiLabel',
          subtitle:
              'Label stand-alone (shadcn <Label>). Asterisco rosso con isRequired, testo disabilitato, 3 taglie. Con child diventa wrapper label + input.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ShowcaseRow(label: 'Default', children: [
                GenaiLabel(text: 'Nome utente'),
              ]),
              const ShowcaseRow(label: 'isRequired', children: [
                GenaiLabel(text: 'Email', isRequired: true),
              ]),
              const ShowcaseRow(label: 'isDisabled', children: [
                GenaiLabel(text: 'Campo bloccato', isDisabled: true),
              ]),
              const ShowcaseRow(label: 'Sizes', children: [
                GenaiLabel(text: 'Label xs', size: GenaiSize.xs),
                GenaiLabel(text: 'Label sm', size: GenaiSize.sm),
                GenaiLabel(text: 'Label md (default)'),
              ]),
              SizedBox(height: context.spacing.s2),
              const SizedBox(
                width: 360,
                child: GenaiLabel(
                  text: 'Username',
                  htmlFor: 'field-username',
                  isRequired: true,
                  child: GenaiTextField(hint: 'mario.rossi'),
                ),
              ),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'GenaiTextarea',
          subtitle:
              'Multi-line shadcn <Textarea>. Counter con maxLength, autoGrow, helperText/errorText, read-only e disabled.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const GenaiTextarea(
                label: 'Descrizione',
                hintText: 'Scrivi una descrizione breve...',
              ),
              SizedBox(height: context.spacing.s3),
              const GenaiTextarea(
                label: 'Note interne',
                hintText: 'Visibili solo al team.',
                helperText: 'Max 2–3 righe consigliate.',
              ),
              SizedBox(height: context.spacing.s3),
              const GenaiTextarea(
                label: 'Bio',
                hintText: 'Presentati...',
                errorText: 'La bio non può essere vuota.',
                isRequired: true,
              ),
              SizedBox(height: context.spacing.s3),
              GenaiTextarea(
                label: 'Testo sola lettura',
                controller: _textareaCtrl,
                isReadOnly: true,
              ),
              SizedBox(height: context.spacing.s3),
              const GenaiTextarea(
                label: 'Textarea disabilitata',
                hintText: 'Non modificabile.',
                isDisabled: true,
              ),
              SizedBox(height: context.spacing.s3),
              const GenaiTextarea(
                label: 'Commento (con counter)',
                hintText: 'Massimo 200 caratteri',
                maxLength: 200,
              ),
              SizedBox(height: context.spacing.s3),
              const GenaiTextarea(
                label: 'Auto-grow',
                hintText: 'Scrivi a piacere, cresce con il contenuto...',
                autoGrow: true,
                minLines: 2,
              ),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'GenaiTextField',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              GenaiTextField(label: 'Nome', hint: 'Mario', helperText: 'Visibile nel profilo'),
              SizedBox(height: 12),
              GenaiTextField.password(label: 'Password', hint: '••••••••'),
              SizedBox(height: 12),
              GenaiTextField.search(hint: 'Cerca clienti...'),
              SizedBox(height: 12),
              GenaiTextField.numeric(label: 'Importo', hint: '0,00', suffixText: '€'),
              SizedBox(height: 12),
              GenaiTextField.multiline(label: 'Note', hint: 'Aggiungi note...', minLines: 3),
              SizedBox(height: 12),
              GenaiTextField(label: 'Email', initialValue: 'mario@invalido', errorText: 'Email non valida'),
              SizedBox(height: 12),
              GenaiTextField(label: 'Disabled', initialValue: 'Read-only', isDisabled: true),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'GenaiCheckbox — tri-state',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GenaiCheckbox(
                value: _check1,
                label: 'Ricorda credenziali',
                onChanged: (v) => setState(() => _check1 = v),
              ),
              GenaiCheckbox(
                value: _check2,
                label: 'Iscriviti alla newsletter',
                description: 'Riceverai una mail al mese.',
                onChanged: (v) => setState(() => _check2 = v),
              ),
              GenaiCheckbox(
                value: _check3,
                label: 'Indeterminato',
                onChanged: (v) => setState(() => _check3 = v),
              ),
              const GenaiCheckbox(value: true, label: 'Disabilitato', isDisabled: true),
              const GenaiCheckbox(value: false, label: 'Errore', hasError: true),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'GenaiRadioGroup',
          child: GenaiRadioGroup<String>(
            value: _radio,
            onChanged: (v) => setState(() => _radio = v ?? _radio),
            options: const [
              GenaiRadioOption(value: 'a', label: 'Standard', description: 'Spedizione 3-5 giorni'),
              GenaiRadioOption(value: 'b', label: 'Express', description: 'Spedizione 24h'),
              GenaiRadioOption(value: 'c', label: 'Ritiro in negozio', description: 'Disponibile in 2 ore'),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'GenaiToggle',
          child: Column(
            children: [
              GenaiToggle(
                value: _toggle,
                label: 'Notifiche push',
                description: 'Ricevi avvisi sul dispositivo.',
                onChanged: (v) => setState(() => _toggle = v),
              ),
              const GenaiToggle(value: false, label: 'Disabilitato', isDisabled: true),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'GenaiSlider & RangeSlider',
          child: Column(
            children: [
              GenaiSlider(
                value: _slider,
                min: 0,
                max: 100,
                onChanged: (v) => setState(() => _slider = v),
              ),
              const SizedBox(height: 16),
              GenaiRangeSlider(
                values: _range,
                min: 0,
                max: 100,
                onChanged: (v) => setState(() => _range = v),
              ),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'GenaiSelect',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GenaiSelect<String>(
                label: 'Valuta',
                value: _select,
                onChanged: (v) => setState(() => _select = v),
                clearable: true,
                options: const [
                  GenaiSelectOption(value: 'eur', label: 'Euro (EUR)'),
                  GenaiSelectOption(value: 'usd', label: 'US Dollar (USD)'),
                  GenaiSelectOption(value: 'gbp', label: 'British Pound (GBP)'),
                ],
              ),
              const SizedBox(height: 12),
              GenaiSelect<String>.multi(
                label: 'Membri team',
                values: _multiSelect,
                onMultiChanged: (v) => setState(() => _multiSelect = v),
                options: const [
                  GenaiSelectOption(value: 'mario', label: 'Mario Rossi'),
                  GenaiSelectOption(value: 'luca', label: 'Luca Bianchi'),
                  GenaiSelectOption(value: 'anna', label: 'Anna Verdi'),
                ],
              ),
              const SizedBox(height: 12),
              GenaiSelect<String>.searchable(
                label: 'Cerca città',
                hint: 'Digita per cercare',
                onChanged: (_) {},
                options: const [
                  GenaiSelectOption(value: 'mi', label: 'Milano'),
                  GenaiSelectOption(value: 'rm', label: 'Roma'),
                  GenaiSelectOption(value: 'na', label: 'Napoli'),
                  GenaiSelectOption(value: 'to', label: 'Torino'),
                ],
              ),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'GenaiCombobox',
          subtitle:
              'Dropdown con ricerca inline e debounce. Single-select, multi-select con chip, stato empty e opzione disabilitata.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GenaiCombobox<String>(
                label: 'Città (single select)',
                hintText: 'Seleziona una città',
                semanticLabel: 'Seleziona città',
                value: _comboSingle,
                options: _comboCities,
                onChanged: (v) => setState(() => _comboSingle = v),
              ),
              const SizedBox(height: 12),
              GenaiCombobox<String>(
                label: 'Città (multi select)',
                hintText: 'Aggiungi città',
                semanticLabel: 'Seleziona una o più città',
                isMultiple: true,
                values: _comboMulti,
                options: _comboCities,
                onChangedMulti: (v) => setState(() => _comboMulti = v),
              ),
              const SizedBox(height: 12),
              GenaiCombobox<String>(
                label: 'Stato vuoto (emptyText)',
                hintText: 'Prova a cercare "zzz"',
                semanticLabel: 'Combobox con empty state',
                emptyText: 'Nessuna città trovata',
                options: _comboCities,
                onChanged: (_) {},
              ),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'GenaiDatePicker',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GenaiDatePicker(
                label: 'Data',
                value: _date,
                onChanged: (v) => setState(() => _date = v),
              ),
              const SizedBox(height: 12),
              GenaiDateRangePicker(
                label: 'Periodo',
                value: _dateRange,
                onChanged: (v) => setState(() => _dateRange = v),
              ),
              const SizedBox(height: 12),
              GenaiMonthPicker(
                label: 'Mese',
                value: _month,
                onChanged: (v) => setState(() => _month = v),
              ),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'GenaiFileUpload',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GenaiFileUpload(
                label: 'Allegato',
                files: _files,
                onChanged: (v) => setState(() => _files = v),
                onPickRequested: () async => [
                  GenaiUploadedFile(name: 'preventivo.pdf', sizeBytes: 254300),
                ],
              ),
              const SizedBox(height: 12),
              GenaiFileUpload.multi(
                label: 'Allegati multipli',
                files: _files,
                onChanged: (v) => setState(() => _files = v),
                onPickRequested: () async => [
                  GenaiUploadedFile(name: 'logo.png', sizeBytes: 12400),
                  GenaiUploadedFile(name: 'note.txt', sizeBytes: 800),
                ],
              ),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'GenaiTagInput',
          child: GenaiTagInput(
            label: 'Tag',
            tags: _tags,
            onChanged: (v) => setState(() => _tags = v),
            suggestions: const ['flutter', 'design', 'system', 'ui', 'token'],
          ),
        ),
        ShowcaseSection(
          title: 'GenaiOTPInput',
          child: GenaiOTPInput(
            length: 6,
            value: _otp,
            onChanged: (v) => setState(() => _otp = v),
          ),
        ),
        ShowcaseSection(
          title: 'GenaiColorPicker',
          child: GenaiColorPicker(
            label: 'Colore brand',
            value: _color,
            onChanged: (v) => setState(() => _color = v),
          ),
        ),
        const SizedBox(height: 24),
        const Wrap(spacing: 12, children: [
          GenaiBadge.dot(),
          GenaiBadge.text(text: 'Beta'),
        ]),
        const SizedBox(height: 24),
        Wrap(spacing: 12, children: [
          GenaiButton.primary(
              label: 'Reset',
              onPressed: () {
                setState(() {
                  _check1 = false;
                  _check2 = true;
                  _check3 = null;
                  _radio = 'a';
                  _toggle = true;
                  _slider = 35;
                  _range = const RangeValues(20, 70);
                  _select = 'eur';
                  _multiSelect = ['mario'];
                  _date = null;
                  _dateRange = null;
                  _month = null;
                  _tags = ['design', 'system'];
                  _otp = '';
                  _files = const [];
                });
              }),
          Text('OTP: $_otp', style: context.typography.code.copyWith(color: context.colors.textSecondary)),
        ]),
      ],
    );
  }
}
