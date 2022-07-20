import 'dart:math';

import 'package:flutter/material.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:magic_wallet/utils/secure_storage.dart';

import '../chain_wrapper/chain_wrapper.dart';
import '../utils/custom_keyboard.dart';
import '../utils/logger.dart';

class Web3TransferTokenDialog extends StatefulWidget {
  final String _chainId;
  final String _chainName;
  final String _chainIconUrl;
  final String _tokenAddress;
  final String _tokenSymbol;
  final String _tokenName;
  final int _tokenDecimals;
  final String _tokenIconUrl;
  final String _routerAddress;
  final List<String> _path;
  final int _priceDecimals;

  const Web3TransferTokenDialog(this._chainId, this._chainName, this._chainIconUrl, this._tokenAddress, this._tokenSymbol, this._tokenName, this._tokenDecimals,
      this._tokenIconUrl, this._routerAddress, this._path, this._priceDecimals,
      {Key? key})
      : super(key: key);

  @override
  State<Web3TransferTokenDialog> createState() => _Web3TransferTokenDialogState();
}

class _Web3TransferTokenDialogState extends State<Web3TransferTokenDialog> {
  final _formKey = GlobalKey<FormState>();
  final _toAddressFieldController = TextEditingController();
  final _amountFieldController = TextEditingController(text: "0");
  final _gasPriceTextFieldController = TextEditingController();
  final _gasLimitTextFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    ChainWrapper.getNetworkGasPrice(widget._chainName)
        .then((value) => _gasPriceTextFieldController.text = (value.getInWei / BigInt.from(pow(10, 9))).toStringAsFixed(4));
    SecureStorage.getWalletAddress().then((walletAddress) => ChainWrapper.estimateGas(widget._chainName, walletAddress!, walletAddress, widget._tokenAddress)
        .then((gasLimit) => _gasLimitTextFieldController.text = gasLimit.toString()));

    return Container(
        height: MediaQuery.of(context).size.height * 0.8,
        color: Colors.white,
        child: KeyboardActions(
          config: CustomKeyboard.buildSendTokenKeyboardConfig(context),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(
                height: 20,
              ),
              Padding(padding: const EdgeInsets.all(25.0), child: SizedBox(child: Image.asset(widget._tokenIconUrl), width: 32)),
              const Text('Send Token', style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 96, 96, 96), fontSize: 20)),
              Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: TextFormField(
                            controller: _toAddressFieldController,
                            focusNode: CustomKeyboard.sendTokenToAddressNode,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                filled: true,
                                hintStyle: TextStyle(color: Colors.grey[800]),
                                hintText: "To Address",
                                fillColor: Colors.white70),
                          )),
                      Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: TextFormField(
                            controller: _amountFieldController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            focusNode: CustomKeyboard.sendTokenAmountNode,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                                suffixText: widget._tokenSymbol,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                filled: true,
                                hintStyle: TextStyle(color: Colors.grey[800]),
                                hintText: "Amount",
                                fillColor: Colors.white70),
                          )),
                      Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: TextFormField(
                            controller: _gasPriceTextFieldController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            focusNode: CustomKeyboard.sendTokenGasPriceNode,
                            decoration: InputDecoration(
                                suffixText: "Gwei",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                filled: true,
                                hintStyle: TextStyle(color: Colors.grey[800]),
                                hintText: "Gas Price",
                                fillColor: Colors.white70),
                          )),
                      Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: TextFormField(
                            controller: _gasLimitTextFieldController,
                            keyboardType: TextInputType.number,
                            focusNode: CustomKeyboard.sendTokenGasNode,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                filled: true,
                                hintStyle: TextStyle(color: Colors.grey[800]),
                                hintText: "Gas Limit",
                                fillColor: Colors.white70),
                          )),
                      Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 0, 0),
                          child: Row(children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 2 - 25,
                              height: 50,
                              child: RawMaterialButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    // TODO transfer token form validation
                                  }
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Transaction Sent')),
                                  );
                                  Navigator.pop(context);

                                  Future.wait<String?>([SecureStorage.getWalletAddress(), SecureStorage.getWalletPrivateKey()])
                                      .then((wallet) => ChainWrapper.sendToken(
                                          widget._chainName,
                                          wallet[0]!,
                                          wallet[1]!,
                                          _toAddressFieldController.text,
                                          widget._tokenAddress,
                                          BigInt.from(double.parse(_amountFieldController.text) * pow(10, widget._tokenDecimals)),
                                          BigInt.from(int.parse(_gasLimitTextFieldController.text)),
                                          BigInt.from(double.parse(_gasPriceTextFieldController.text) * pow(10, 9)),
                                          // from Wei to GWei
                                          int.parse(widget._chainId)))
                                      .then((txHash) {
                                    SecureStorage.addTransactionRecord(widget._chainId.toString(), widget._tokenAddress, txHash);
                                    Logger.printConsoleLog(txHash);
                                  });
                                },
                                elevation: 2.0,
                                fillColor: Colors.lightBlue,
                                child: const Text('Confirm', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                                padding: const EdgeInsets.all(15.0),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 2 - 25,
                              height: 50,
                              child: RawMaterialButton(
                                onPressed: () => Navigator.pop(context),
                                elevation: 2.0,
                                fillColor: Colors.lightBlue,
                                child: const Text('Cancel', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                                padding: const EdgeInsets.all(15.0),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                              ),
                            )
                          ]))
                    ],
                  )),
            ],
          ),
        ));
  }
}
