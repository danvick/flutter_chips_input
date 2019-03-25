import 'package:flutter/material.dart';
import 'package:flutter_chips_input/flutter_chips_input.dart';

class ChipsInputFormField<T> extends StatefulWidget {
  final FormFieldValidator<T> validator;
  final InputDecoration decoration;
  final bool enabled;
  final ChipsInputSuggestions findSuggestions;
  final ValueChanged<List<T>> onChanged;
  final ValueChanged<T> onChipTapped;
  final ChipsBuilder<T> chipBuilder;
  final ChipsBuilder<T> suggestionBuilder;
  final List<T> initialValue;
  final int maxChips;
  final FormFieldSetter<T> onSaved;
  final bool autovalidate;

  ChipsInputFormField({
    Key key,
    this.initialValue = const [],
    this.decoration = const InputDecoration(),
    this.enabled = true,
    this.autovalidate = false,
    @required this.chipBuilder,
    @required this.suggestionBuilder,
    @required this.findSuggestions,
    @required this.onChanged,
    this.onChipTapped,
    this.maxChips,
    this.validator,
    this.onSaved,
  })  : assert(maxChips == null || initialValue.length <= maxChips),
        super(key: key);

  @override
  _ChipsInputFormFieldState createState() => _ChipsInputFormFieldState();
}

class _ChipsInputFormFieldState extends State<ChipsInputFormField> {
  @override
  Widget build(BuildContext context) {
    return FormField(
      key: widget.key,
      autovalidate: widget.autovalidate,
      enabled: widget.enabled,
      initialValue: widget.enabled,
      onSaved: widget.onSaved,
      validator: widget.validator,
      builder: (FormFieldState<dynamic> field) {
        return ChipsInput(
          initialValue: widget.initialValue,
          enabled: widget.enabled,
          decoration: widget.decoration.copyWith(
            enabled: widget.enabled,
            errorText: field.errorText,
          ),
          findSuggestions: widget.findSuggestions,
          onChanged: (data) {
            field.didChange(data);
          },
          chipBuilder: widget.chipBuilder,
          suggestionBuilder: widget.suggestionBuilder,
          maxChips: widget.maxChips,
          onChipTapped: widget.onChipTapped,
        );
      },
    );
  }
}
