import 'package:flutter/material.dart';
import 'package:genai_components/genai_components_v2.dart';

import '../widgets/showcase_v2_section.dart';

class InputsV2Page extends StatefulWidget {
  const InputsV2Page({super.key});

  @override
  State<InputsV2Page> createState() => _InputsV2PageState();
}

class _InputsV2PageState extends State<InputsV2Page> {
  bool? _checkbox = true;
  bool? _checkboxIndeterminate;
  String _radio = 'a';
  String? _select = 'IT';
  bool _toggle = true;
  double _slider = 40;

  @override
  Widget build(BuildContext context) {
    return ShowcaseV2Scaffold(
      title: 'Inputs',
      description:
          'TextField, Textarea, Select, Combobox, Checkbox, Radio, Toggle, '
          'Slider, Label. Field frame condiviso, ring focus.',
      children: [
        ShowcaseV2Section(
          title: 'GenaiTextField',
          child: Column(children: [
            ShowcaseV2Row(label: 'Default', children: [
              SizedBox(
                width: 280,
                child: GenaiTextField(
                  label: 'Nome',
                  hintText: 'Mario Rossi',
                  onChanged: (v) {},
                ),
              ),
            ]),
            ShowcaseV2Row(label: 'Variants', children: const [
              SizedBox(
                width: 240,
                child: GenaiTextField(
                  label: 'Outline',
                  hintText: 'default',
                ),
              ),
              SizedBox(
                width: 240,
                child: GenaiTextField(
                  label: 'Filled',
                  hintText: 'filled',
                  variant: GenaiTextFieldVariant.filled,
                ),
              ),
              SizedBox(
                width: 240,
                child: GenaiTextField(
                  label: 'Ghost',
                  hintText: 'ghost',
                  variant: GenaiTextFieldVariant.ghost,
                ),
              ),
            ]),
            ShowcaseV2Row(label: 'Stati', children: const [
              SizedBox(
                width: 240,
                child: GenaiTextField(
                  label: 'Required',
                  hintText: 'Obbligatorio',
                  isRequired: true,
                ),
              ),
              SizedBox(
                width: 240,
                child: GenaiTextField(
                  label: 'Disabled',
                  initialValue: 'immutabile',
                  isDisabled: true,
                ),
              ),
              SizedBox(
                width: 240,
                child: GenaiTextField(
                  label: 'Errore',
                  initialValue: 'abc',
                  errorText: 'Almeno 5 caratteri',
                ),
              ),
            ]),
            ShowcaseV2Row(label: 'Modes', children: const [
              SizedBox(
                width: 240,
                child: GenaiTextField.password(label: 'Password'),
              ),
              SizedBox(
                width: 240,
                child: GenaiTextField.search(hintText: 'Cerca...'),
              ),
              SizedBox(
                width: 240,
                child: GenaiTextField.numeric(label: 'Importo', suffixText: '€'),
              ),
            ]),
          ]),
        ),
        ShowcaseV2Section(
          title: 'GenaiTextarea',
          child: ShowcaseV2Row(label: 'Multiline', children: const [
            SizedBox(
              width: 480,
              child: GenaiTextarea(
                label: 'Note',
                hintText: 'Scrivi qualcosa…',
                helperText: 'Max 500 caratteri',
              ),
            ),
          ]),
        ),
        ShowcaseV2Section(
          title: 'GenaiSelect',
          child: ShowcaseV2Row(label: 'Dropdown', children: [
            SizedBox(
              width: 280,
              child: GenaiSelect<String>(
                label: 'Paese',
                value: _select,
                onChanged: (v) => setState(() => _select = v),
                options: const [
                  GenaiSelectOption(value: 'IT', label: 'Italia'),
                  GenaiSelectOption(value: 'FR', label: 'Francia'),
                  GenaiSelectOption(value: 'DE', label: 'Germania'),
                  GenaiSelectOption(value: 'ES', label: 'Spagna'),
                ],
              ),
            ),
          ]),
        ),
        ShowcaseV2Section(
          title: 'GenaiCheckbox',
          child: ShowcaseV2Row(label: 'States', children: [
            GenaiCheckbox(
              value: _checkbox,
              label: 'Accetto',
              onChanged: (v) => setState(() => _checkbox = v),
            ),
            GenaiCheckbox(
              value: _checkboxIndeterminate,
              label: 'Indeterminate',
              onChanged: (v) => setState(() => _checkboxIndeterminate = v),
            ),
            const GenaiCheckbox(
                value: false, label: 'Disabled', isDisabled: true),
            const GenaiCheckbox(
                value: true, label: 'Errore', hasError: true),
          ]),
        ),
        ShowcaseV2Section(
          title: 'GenaiRadio',
          child: ShowcaseV2Row(label: 'Group', children: [
            SizedBox(
              width: 320,
              child: GenaiRadio<String>(
                value: _radio,
                onChanged: (v) => setState(() => _radio = v),
                options: const [
                  GenaiRadioOption(
                      value: 'a',
                      label: 'Opzione A',
                      description: 'Descrizione della scelta A'),
                  GenaiRadioOption(value: 'b', label: 'Opzione B'),
                  GenaiRadioOption(
                      value: 'c', label: 'Disabled', isDisabled: true),
                ],
              ),
            ),
          ]),
        ),
        ShowcaseV2Section(
          title: 'GenaiToggle',
          child: ShowcaseV2Row(label: 'Switch', children: [
            GenaiToggle(
              value: _toggle,
              label: 'Notifiche email',
              description: 'Ricevi un digest settimanale',
              onChanged: (v) => setState(() => _toggle = v),
            ),
            const GenaiToggle(
                value: false, label: 'Disabled', isDisabled: true),
          ]),
        ),
        ShowcaseV2Section(
          title: 'GenaiSlider',
          child: Column(children: [
            ShowcaseV2Row(label: 'Single', children: [
              SizedBox(
                width: 320,
                child: GenaiSlider(
                  value: _slider,
                  min: 0,
                  max: 100,
                  label: 'Intensità',
                  onChanged: (v) => setState(() => _slider = v),
                ),
              ),
            ]),
            ShowcaseV2Row(label: 'Range', children: const [
              SizedBox(
                width: 320,
                child: GenaiSlider.range(
                  rangeValues: RangeValues(20, 70),
                  min: 0,
                  max: 100,
                  label: 'Fascia prezzo',
                ),
              ),
            ]),
          ]),
        ),
        ShowcaseV2Section(
          title: 'GenaiLabel',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              GenaiLabel(text: 'Campo normale'),
              SizedBox(height: 8),
              GenaiLabel(text: 'Campo obbligatorio', isRequired: true),
              SizedBox(height: 8),
              GenaiLabel(text: 'Disabled', isDisabled: true),
            ],
          ),
        ),
        ShowcaseV2Section(
          title: 'In contesto — form',
          subtitle: 'Esempio di form completo con layout verticale.',
          child: GenaiCard.outlined(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const GenaiTextField(label: 'Nome', hintText: 'Mario'),
                SizedBox(height: context.spacing.s12),
                const GenaiTextField(
                    label: 'Email', hintText: 'mario@oneai.it'),
                SizedBox(height: context.spacing.s12),
                const GenaiTextarea(label: 'Messaggio', minLines: 2),
                SizedBox(height: context.spacing.s16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GenaiButton.ghost(label: 'Annulla', onPressed: () {}),
                    SizedBox(width: context.spacing.s8),
                    GenaiButton.primary(label: 'Invia', onPressed: () {}),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
