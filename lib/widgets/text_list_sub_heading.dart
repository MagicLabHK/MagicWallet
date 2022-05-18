import 'package:flutter/material.dart';

class ListSubHeadingText extends StatelessWidget {
  final String _header;

  const ListSubHeadingText(this._header, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(_header,
        style: const TextStyle(
            fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20));
  }
}
