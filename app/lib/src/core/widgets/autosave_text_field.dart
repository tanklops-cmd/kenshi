import 'dart:async';

import 'package:flutter/material.dart';

class AutosaveEdit {
  const AutosaveEdit({
    required this.value,
    required this.startedAt,
    required this.lastEditedAt,
  });

  final String value;
  final DateTime startedAt;
  final DateTime lastEditedAt;
}

class AutosaveTextField extends StatefulWidget {
  const AutosaveTextField({
    required this.initialValue,
    required this.onSave,
    this.fieldKey,
    this.hintText,
    this.autofocus = false,
    this.readOnly = false,
    this.singleLine = false,
    this.dismissOnTapOutside = false,
    this.onFocusLost,
    this.autosaveDelay = const Duration(milliseconds: 600),
    super.key,
  });

  final String initialValue;
  final Future<void> Function(AutosaveEdit edit) onSave;
  final Key? fieldKey;
  final String? hintText;
  final bool autofocus;
  final bool readOnly;
  final bool singleLine;
  final bool dismissOnTapOutside;
  final ValueChanged<String>? onFocusLost;
  final Duration autosaveDelay;

  @override
  State<AutosaveTextField> createState() => _AutosaveTextFieldState();
}

class _AutosaveTextFieldState extends State<AutosaveTextField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  Timer? _debounceTimer;
  bool _hasUnsavedChanges = false;
  bool _isSaving = false;
  bool _hasSaved = false;
  bool _saveFailed = false;
  bool _focusLossReported = false;
  DateTime? _editingStartedAt;
  DateTime? _lastEditedAt;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _focusNode = FocusNode()..addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(AutosaveTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focusNode.hasFocus &&
        !_hasUnsavedChanges &&
        widget.initialValue != _controller.text) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    if (_hasUnsavedChanges) {
      unawaited(_saveValueBeforeDispose(_currentEdit()));
    }
    _focusNode
      ..removeListener(_handleFocusChange)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveValueBeforeDispose(AutosaveEdit edit) async {
    try {
      await widget.onSave(edit);
    } on Object {
      // The screen is already leaving; the next edit will retry normally.
    }
  }

  void _handleChanged(String value) {
    final editedAt = DateTime.now().toUtc();
    _editingStartedAt ??= editedAt;
    _lastEditedAt = editedAt;
    _hasUnsavedChanges = true;
    _hasSaved = false;
    _saveFailed = false;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.autosaveDelay, () {
      unawaited(_save());
    });
    setState(() {});
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      _focusLossReported = false;
      return;
    }

    _debounceTimer?.cancel();
    unawaited(_save().whenComplete(_reportFocusLossIfReady));
  }

  void _reportFocusLossIfReady() {
    if (!_focusNode.hasFocus &&
        !_hasUnsavedChanges &&
        !_isSaving &&
        !_focusLossReported) {
      _focusLossReported = true;
      widget.onFocusLost?.call(_controller.text);
    }
  }

  Future<bool> _save() async {
    if (!_hasUnsavedChanges) {
      return true;
    }
    if (_isSaving) {
      return false;
    }

    _hasUnsavedChanges = false;
    if (mounted) {
      setState(() => _isSaving = true);
    }

    try {
      await widget.onSave(_currentEdit());
      if (mounted) {
        setState(() {
          _hasSaved = true;
          _saveFailed = false;
        });
      }
      return true;
    } on Object {
      _hasUnsavedChanges = true;
      if (mounted) {
        setState(() => _saveFailed = true);
      }
      return false;
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
      _reportFocusLossIfReady();
      if (_hasUnsavedChanges) {
        _debounceTimer?.cancel();
        _debounceTimer = Timer(widget.autosaveDelay, () {
          unawaited(_save());
        });
      }
    }
  }

  AutosaveEdit _currentEdit() {
    final now = DateTime.now().toUtc();
    return AutosaveEdit(
      value: _controller.text,
      startedAt: _editingStartedAt ?? now,
      lastEditedAt: _lastEditedAt ?? now,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          key: widget.fieldKey,
          controller: _controller,
          focusNode: _focusNode,
          autofocus: widget.autofocus,
          readOnly: widget.readOnly,
          minLines: widget.singleLine ? 1 : 3,
          maxLines: widget.singleLine ? 1 : null,
          keyboardType: widget.singleLine
              ? TextInputType.text
              : TextInputType.multiline,
          textInputAction: widget.singleLine
              ? TextInputAction.done
              : TextInputAction.newline,
          decoration: InputDecoration(
            hintText: widget.hintText,
            border: const OutlineInputBorder(),
            filled: widget.readOnly,
          ),
          onTapOutside: widget.dismissOnTapOutside
              ? (event) => _focusNode.unfocus()
              : null,
          onChanged: widget.readOnly ? null : _handleChanged,
        ),
        if (_isSaving || _hasSaved || _saveFailed) ...[
          const SizedBox(height: 6),
          Text(
            _isSaving
                ? 'Saving…'
                : _saveFailed
                ? 'Not saved yet'
                : 'Saved just now',
            style: textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
