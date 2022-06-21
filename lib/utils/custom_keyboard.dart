import 'package:flutter/material.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

class CustomKeyboard{
  static final FocusNode sendTokenToAddressNode = FocusNode();
  static final FocusNode sendTokenAmountNode = FocusNode();
  static final FocusNode sendTokenGasPriceNode = FocusNode();
  static final FocusNode sendTokenGasNode = FocusNode();

  static KeyboardActionsConfig buildSendTokenKeyboardConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
      keyboardBarColor: Colors.grey[200],
      nextFocus: true,
      actions: [
        KeyboardActionsItem(
            focusNode: sendTokenToAddressNode,
        ),
        KeyboardActionsItem(
            focusNode: sendTokenAmountNode,
        ),
        KeyboardActionsItem(
            focusNode: sendTokenGasPriceNode,
        ),
        KeyboardActionsItem(
            focusNode: sendTokenGasNode,
            displayArrows: false
        ),
      ],
    );
  }
}