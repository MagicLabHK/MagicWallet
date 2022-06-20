import 'package:flutter/material.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

class CustomKeyboard{
  static final FocusNode _nodeText1 = FocusNode();
  static final FocusNode _nodeText2 = FocusNode();
  static final FocusNode _nodeText3 = FocusNode();
  static final FocusNode numericKeyboard = FocusNode();
  static final FocusNode _nodeText5 = FocusNode();
  static final FocusNode _nodeText6 = FocusNode();

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