import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:magic_wallet/utils/constant.dart';
import 'package:magic_wallet/utils/secure_storage.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({Key? key}) : super(key: key);
  static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  final privateKeyFieldController = TextEditingController();
  final nearAccountIdFieldController = TextEditingController();
  final wavesAccountSeedFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SettingsList(
      sections: [
        SettingsSection(
          title: Text('Wallet'),
          tiles: <SettingsTile>[
            SettingsTile(
              leading: Icon(Icons.key),
              title: Text('EVM Private Key'),
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
                        SecureStorage.updatePrivateKey(Constant.chainMoonriver, privateKeyFieldController.text);
                        Navigator.pop(context, 'OK');
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ));
              },
            ),
            SettingsTile(
              leading: Icon(Icons.key),
              title: const Text('Near Wallet Account'),
              onPressed: (BuildContext context) {
                showDialog(context: context, builder: (BuildContext context) => AlertDialog(
                  title: const Text('Near Wallet Account'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nearAccountIdFieldController,
                        decoration: const InputDecoration(hintText: 'Enter Near Account ID'),
                        maxLength: 64,
                      ),
                      TextField(
                        controller: privateKeyFieldController,
                        decoration: const InputDecoration(hintText: 'Enter Near Account Private Key'),
                        maxLength: 96,
                      )
                    ],
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context, 'Cancel'),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        SecureStorage.updateNearWalletAccount(privateKeyFieldController.text, nearAccountIdFieldController.text);
                        Navigator.pop(context, 'OK');
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ));
              },
            ),
            SettingsTile(
              leading: const Icon(Icons.key),
              title: const Text('Waves Wallet Seed'),
              onPressed: (BuildContext context) {
                showDialog(context: context, builder: (BuildContext context) => AlertDialog(
                  title: const Text('Waves Wallet Seed'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: wavesAccountSeedFieldController,
                        decoration: const InputDecoration(hintText: 'Enter Waves Account Seed')
                      ),
                    ],
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context, 'Cancel'),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        SecureStorage.updateWavesSeed(wavesAccountSeedFieldController.text);
                        Navigator.pop(context, 'OK');
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ));
              },
            )
          ],
        ),
      ],
    );
  }
}
