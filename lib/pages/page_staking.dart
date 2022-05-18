import 'package:flutter/material.dart';

class StakingPage extends StatelessWidget {
  const StakingPage({Key? key}) : super(key: key);
  static const TextStyle optionStyle =
  TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Index 1: Stakings',
      style: optionStyle,
    );
  }
}
