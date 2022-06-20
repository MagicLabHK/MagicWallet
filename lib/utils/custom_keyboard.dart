import 'package:flutter/material.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

class CustomKeyboard{
  static final FocusNode numericKeyboard = FocusNode();

  static KeyboardActionsConfig buildNumericKeyboardConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
      keyboardBarColor: Colors.grey[200],
      nextFocus: true,
      actions: [
        KeyboardActionsItem(
          focusNode: numericKeyboard,
          displayArrows: false
        ),
      ],
    );
  }
}