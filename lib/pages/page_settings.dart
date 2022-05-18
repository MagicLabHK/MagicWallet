import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:magic_wallet/utils/secure_storage.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({Key? key}) : super(key: key);
  static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  final privateKeyFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SettingsList(
      sections: [
        SettingsSection(
          title: Text('Wallet'),
          tiles: <SettingsTile>[
            SettingsTile(
              leading: Icon(Icons.key),
              title: Text('Private Key'),
              onPressed: (BuildContext context) {
                showDialog(context: context, builder: (BuildContext context) => AlertDialog(
                  title: const Text('Private Key'),
                  content: TextField(
                    controller: privateKeyFieldController,
                    decoration: InputDecoration(hintText: 'Enter Private Key'),
                    maxLength: 66,
                    obscureText: true,
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context, 'Cancel'),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        log(privateKeyFieldController.text);
                        SecureStorage.updatePrivateKey(privateKeyFieldController.text);
                        Navigator.pop(context, 'OK');
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ));
              },
            ),
          ],
        ),
      ],
    );
  }
}
