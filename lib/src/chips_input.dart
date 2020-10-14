import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'suggestions_box_controller.dart';
import 'text_cursor.dart';

typedef ChipsInputSuggestions<T> = FutureOr<List<T>> Function(String query);
typedef ChipSelected<T> = void Function(T data, bool selected);
typedef ChipsBuilder<T> = Widget Function(
    BuildContext context, ChipsInputState<T> state, T data);

const kObjectReplacementChar = 0xFFFD;

extension on TextEditingValue {
  String get normalCharactersText => String.fromCharCodes(
        text.codeUnits.where((ch) => ch != kObjectReplacementChar),
      );

  List<int> get replacementCharacters => text.codeUnits
      .where((ch) => ch == kObjectReplacementChar)
      .toList(growable: false);

  int get replacementCharactersCount => replacementCharacters.length;
}

class ChipsInput<T> extends StatefulWidget {
  ChipsInput({
    Key key,
    this.initialValue = const [],
    this.decoration = const InputDecoration(),
    this.enabled = true,
    @required this.chipBuilder,
    @required this.suggestionBuilder,
    @required this.findSuggestions,
    @required this.onChanged,
    this.onChipTapped,
    this.maxChips,
    this.textStyle,
    this.suggestionsBoxMaxHeight,
    this.inputType = TextInputType.text,
    this.textOverflow = TextOverflow.clip,
    this.obscureText = false,
    this.autocorrect = true,
    this.actionLabel,
    this.inputAction = TextInputAction.done,
    this.keyboardAppearance = Brightness.light,
    this.textCapitalization = TextCapitalization.none,
    this.autofocus = false,
    this.allowChipEditing = false,
    this.focusNode,
  })  : assert(maxChips == null || initialValue.length <= maxChips),
        super(key: key);

  final InputDecoration decoration;
  final TextStyle textStyle;
  final bool enabled;
  final ChipsInputSuggestions findSuggestions;
  final ValueChanged<List<T>> onChanged;
  @Deprecated("Will be removed in the next major version")
  final ValueChanged<T> onChipTapped;
  final ChipsBuilder<T> chipBuilder;
  final ChipsBuilder<T> suggestionBuilder;
  final List<T> initialValue;
  final int maxChips;
  final double suggestionsBoxMaxHeight;
  final TextInputType inputType;
  final TextOverflow textOverflow;
  final bool obscureText;
  final bool autocorrect;
  final String actionLabel;
  final TextInputAction inputAction;
  final Brightness keyboardAppearance;
  final bool autofocus;
  final bool allowChipEditing;
  final FocusNode focusNode;

  // final Color cursorColor;

  final TextCapitalization textCapitalization;

  @override
  ChipsInputState<T> createState() => ChipsInputState<T>();
}

class ChipsInputState<T> extends State<ChipsInput<T>>
    implements TextInputClient {
  Set<T> _chips = Set<T>();
  List<T> _suggestions;
  StreamController<List<T>> _suggestionsStreamController;
  int _searchId = 0;
  TextEditingValue _value = TextEditingValue();
  // TextEditingValue _receivedRemoteTextEditingValue;
  TextInputConnection _textInputConnection;
  SuggestionsBoxController _suggestionsBoxController;
  LayerLink _layerLink = LayerLink();
  Size size;
  Map<T, String> _enteredTexts = {};

  TextInputConfiguration get textInputConfiguration => TextInputConfiguration(
        inputType: widget.inputType,
        obscureText: widget.obscureText,
        autocorrect: widget.autocorrect,
        actionLabel: widget.actionLabel,
        inputAction: widget.inputAction,
        keyboardAppearance: widget.keyboardAppearance,
        textCapitalization: widget.textCapitalization,
      );

  bool get _hasInputConnection =>
      _textInputConnection != null && _textInputConnection.attached;

  bool get _hasReachedMaxChips =>
      widget.maxChips != null && _chips.length >= widget.maxChips;

  // FocusAttachment _focusAttachment;
  FocusNode _focusNode;

  FocusNode get _effectiveFocusNode =>
      widget.focusNode ?? (_focusNode ??= FocusNode());

  RenderBox get renderBox => context.findRenderObject();

  @override
  void initState() {
    super.initState();
    _chips.addAll(widget.initialValue);
    // _focusAttachment = _effectiveFocusNode.attach(context);
    _suggestionsBoxController = SuggestionsBoxController(context);
    _suggestionsStreamController = StreamController<List<T>>.broadcast();
    _effectiveFocusNode.addListener(_handleFocusChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _initOverlayEntry();
      if (mounted && widget.autofocus && _effectiveFocusNode != null) {
        FocusScope.of(context).autofocus(_effectiveFocusNode);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //TODO: Implement
  }

  void _handleFocusChanged() {
    if (_effectiveFocusNode.hasFocus) {
      _openInputConnection();
      _suggestionsBoxController.open();
    } else {
      _closeInputConnectionIfNeeded();
      _suggestionsBoxController.close();
    }
    if (mounted) {
      setState(() {
        /*rebuild so that _TextCursor is hidden.*/
      });
    }
  }

  void _initOverlayEntry() {
    // _suggestionsBoxController.close();
    _suggestionsBoxController.overlayEntry = OverlayEntry(
      builder: (context) {
        var size = renderBox.size;
        var renderBoxOffset = renderBox.localToGlobal(Offset.zero);
        var topAvailableSpace = renderBoxOffset.dy;
        var bottomAvailableSpace = MediaQuery.of(context).size.height -
            MediaQuery.of(context).viewInsets.bottom -
            renderBoxOffset.dy -
            size.height;
        var _suggestionBoxHeight = max(topAvailableSpace, bottomAvailableSpace);
        var showTop = topAvailableSpace > bottomAvailableSpace;
        // print("showTop: $showTop" );
        var compositedTransformFollowerOffset = Offset.zero;
        if (showTop) {
          // compositedTransformFollowerOffset = Offset(0, -(topAvailableSpace + size.height));
          compositedTransformFollowerOffset = Offset(0, -size.height);
        }

        return StreamBuilder(
          stream: _suggestionsStreamController.stream,
          builder: (
            BuildContext context,
            AsyncSnapshot<List<dynamic>> snapshot,
          ) {
            if (snapshot.hasData && snapshot.data?.length != 0) {
              var suggestionsListView = Material(
                elevation: 4.0,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: _suggestionBoxHeight,
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: snapshot.data?.length ?? 0,
                    itemBuilder: (BuildContext context, int index) {
                      return widget.suggestionBuilder(
                        context,
                        this,
                        _suggestions[index],
                      );
                    },
                  ),
                ),
              );
              return Positioned(
                width: size.width,
                child: CompositedTransformFollower(
                  link: _layerLink,
                  showWhenUnlinked: false,
                  offset: compositedTransformFollowerOffset,
                  child: !showTop
                      ? suggestionsListView
                      : FractionalTranslation(
                          translation: Offset(0, -1),
                          child: suggestionsListView,
                        ),
                ),
              );
            }
            return Container();
          },
        );
      },
    );
  }

  void selectSuggestion(T data) {
    if (!_hasReachedMaxChips) {
      _chips.add(data);
      if (widget.allowChipEditing) {
        var enteredText = _value.normalCharactersText ?? '';
        if (enteredText.isNotEmpty) _enteredTexts[data] = enteredText;
      }
      _updateTextInputState(replaceText: true);

      _suggestions = null;
      _suggestionsStreamController.add(_suggestions);
      if (widget.maxChips == _chips.length) _suggestionsBoxController.close();
    } else {
      _suggestionsBoxController.close();
    }
    widget.onChanged(_chips.toList(growable: false));
  }

  void deleteChip(T data) {
    if (widget.enabled) {
      _chips.remove(data);
      if (_enteredTexts.containsKey(data)) _enteredTexts.remove(data);
      _updateTextInputState();
      widget.onChanged(_chips.toList(growable: false));
    }
  }

  void _openInputConnection() {
    if (!_hasInputConnection) {
      _textInputConnection = TextInput.attach(this, textInputConfiguration)
        ..setEditingState(_value);
    }
    _textInputConnection.show();

    Future.delayed(Duration(milliseconds: 100), () {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        RenderBox renderBox = context.findRenderObject();
        Scrollable.of(context)?.position?.ensureVisible(renderBox);
      });
    });
  }

  void _onSearchChanged(String value) async {
    final localId = ++_searchId;
    final results = await widget.findSuggestions(value);
    if (_searchId == localId && mounted) {
      _suggestions =
          results.where((r) => !_chips.contains(r)).toList(growable: false);
    }
    _suggestionsStreamController.add(_suggestions);
  }

  void _closeInputConnectionIfNeeded() {
    if (_hasInputConnection) {
      _textInputConnection.close();
      _textInputConnection = null;
      // _receivedRemoteTextEditingValue = null;
    }
  }

  @override
  void updateEditingValue(TextEditingValue value) {
    // print("updateEditingValue FIRED with ${value.text}");
    // _receivedRemoteTextEditingValue = value;
    var _oldTextEditingValue = _value;
    if (value.text != _oldTextEditingValue.text) {
      setState(() {
        _value = value;
      });
      if (value.replacementCharactersCount <
          _oldTextEditingValue.replacementCharactersCount) {
        var removedChip = _chips.last;
        _chips = Set.from(_chips.take(value.replacementCharactersCount));
        widget.onChanged(_chips.toList(growable: false));
        var putText = '';
        if (widget.allowChipEditing && _enteredTexts.containsKey(removedChip)) {
          putText = _enteredTexts[removedChip];
          _enteredTexts.remove(removedChip);
        }
        _updateTextInputState(putText: putText);
      }
      _onSearchChanged(_value.normalCharactersText);
    }
  }

  void _updateTextInputState({replaceText = false, putText = ''}) {
    final updatedText =
        String.fromCharCodes(_chips.map((_) => kObjectReplacementChar)) +
            "${replaceText ? '' : _value.normalCharactersText}" +
            putText;
    setState(() {
      _value = _value.copyWith(
        text: updatedText,
        selection: TextSelection.collapsed(offset: updatedText.length),
        //composing: TextRange(start: 0, end: text.length),
      );
    });
    _closeInputConnectionIfNeeded(); //Hack for #34 (https://github.com/danvick/flutter_chips_input/issues/34#issuecomment-684505282). TODO: Find permanent fix
    if (_textInputConnection == null) {
      _textInputConnection = TextInput.attach(this, textInputConfiguration);
    }
    _textInputConnection.setEditingState(_value);
    // _closeInputConnectionIfNeeded(false);
  }

  @override
  void performAction(TextInputAction action) {
    switch (action) {
      case TextInputAction.done:
      case TextInputAction.go:
      case TextInputAction.send:
      case TextInputAction.search:
        if (_suggestions != null && _suggestions.isNotEmpty) {
          selectSuggestion(_suggestions.first);
        } else {
          _effectiveFocusNode.unfocus();
        }
        break;
      default:
        _effectiveFocusNode.unfocus();
        break;
    }
  }

  @override
  void performPrivateCommand(String action, Map<String, dynamic> data) {
    //TODO
  }

  @override
  void didUpdateWidget(ChipsInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    /* if(widget.focusNode != oldWidget.focusNode){
      oldWidget.focusNode.removeListener(_handleFocusChanged);
      _focusAttachment?.detach();
      _focusAttachment = widget.focusNode.attach(context);
      widget.focusNode.addListener(_handleFocusChanged);
    } */
  }

  @override
  void dispose() {
    _closeInputConnectionIfNeeded();
    _suggestionsStreamController.close();
    _suggestionsBoxController.close();
    super.dispose();
  }

  @override
  void updateFloatingCursor(RawFloatingCursorPoint point) {
    // print(point);
  }

  @override
  void connectionClosed() {
    // print('TextInputClient.connectionClosed()');
  }

  @override
  TextEditingValue get currentTextEditingValue => _value;

  // @override
  void showAutocorrectionPromptRect(int start, int end) {}

  @override
  AutofillScope get currentAutofillScope => null;

  @override
  Widget build(BuildContext context) {
    var chipsChildren = _chips
        .map<Widget>((data) => widget.chipBuilder(context, this, data))
        .toList();

    final theme = Theme.of(context);

    chipsChildren.add(
      Container(
        height: 32.0,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Flexible(
              flex: 1,
              child: Text(
                _value.normalCharactersText,
                maxLines: 1,
                overflow: widget.textOverflow,
                style: widget.textStyle ??
                    theme.textTheme.subtitle1.copyWith(height: 1.5),
              ),
            ),
            Flexible(
                flex: 0,
                child: TextCursor(resumed: _effectiveFocusNode.hasFocus)),
          ],
        ),
      ),
    );

    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (SizeChangedLayoutNotification val) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          _suggestionsBoxController.overlayEntry.markNeedsBuild();
        });
        return true;
      },
      child: SizeChangedLayoutNotifier(
        child: Column(
          children: <Widget>[
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                FocusScope.of(context).requestFocus(_effectiveFocusNode);
                _textInputConnection?.show();
              },
              child: InputDecorator(
                decoration: widget.decoration,
                isFocused: _effectiveFocusNode.hasFocus,
                isEmpty: _value.text.length == 0 && _chips.length == 0,
                child: Wrap(
                  children: chipsChildren,
                  spacing: 4.0,
                  runSpacing: 4.0,
                ),
              ),
            ),
            CompositedTransformTarget(
              link: _layerLink,
              child: Container(),
            ),
          ],
        ),
      ),
    );
  }
}
